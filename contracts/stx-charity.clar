;; stx-charity: Blockchain Charity Donation Contract
;; ------------------------------------
;; This contract enables a decentralized donation system with escrow functionality.
;; - Users can initiate donation escrows with milestone-based fund release.
;; - An administrator approves milestones to release funds incrementally.
;; - If funds remain unapproved past expiry, donors can reclaim their donation.
;; - Transactions are transparently recorded on the Stacks blockchain.

;; Constants for settings and error codes
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERROR_NOT_AUTHORIZED (err u100))
(define-constant ERROR_NO_ESCROW (err u101))
(define-constant ERROR_FUNDS_RELEASED (err u102))
(define-constant ERROR_TRANSFER_FAILED (err u103))
(define-constant ERROR_INVALID_ID (err u104))
(define-constant ERROR_INVALID_AMOUNT (err u105))
(define-constant ERROR_INVALID_STEP (err u106))
(define-constant ERROR_ESCROW_EXPIRED (err u107))
(define-constant ESCROW_PERIOD u1008) ;; Approx. 7 days in blocks

;; Storage for donation records
(define-map DonationRecords
  { id: uint }
  {
    contributor: principal,
    beneficiary: principal,
    total-funds: uint,
    current-status: (string-ascii 10),
    creation-block: uint,
    expiry-block: uint,
    milestone-schedule: (list 5 uint),
    milestones-cleared: uint
  }
)

(define-data-var latest-donation-id uint u0)

;; Helper functions

;; Ensure a charity is not the sender themselves
(define-private (valid-beneficiary? (recipient principal))
  (not (is-eq recipient tx-sender))
)

;; Validate if a donation ID exists
(define-private (valid-donation-id? (donation-id uint))
  (<= donation-id (var-get latest-donation-id))
)



;; Public Functions

;; Start a new donation escrow
(define-public (create-donation (recipient principal) (amount uint) (milestones (list 5 uint)))
  (let
    (
      (new-id (+ (var-get latest-donation-id) u1))
      (expiry (+ block-height ESCROW_PERIOD))
    )
    (asserts! (> amount u0) ERROR_INVALID_AMOUNT)
    (asserts! (valid-beneficiary? recipient) ERROR_INVALID_STEP)
    (asserts! (> (len milestones) u0) ERROR_INVALID_STEP)
    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      success
        (begin
          (map-set DonationRecords
            { id: new-id }
            {
              contributor: tx-sender,
              beneficiary: recipient,
              total-funds: amount,
              current-status: "pending",
              creation-block: block-height,
              expiry-block: expiry,
              milestone-schedule: milestones,
              milestones-cleared: u0
            }
          )
          (var-set latest-donation-id new-id)
          (ok new-id)
        )
      error ERROR_TRANSFER_FAILED
    )
  )
)

;; Approve milestone and release funds
(define-public (release-milestone (donation-id uint))
  (begin
    (asserts! (valid-donation-id? donation-id) ERROR_INVALID_ID)
    (let
      (
        (donation (unwrap! (map-get? DonationRecords { id: donation-id }) ERROR_NO_ESCROW))
        (steps (get milestone-schedule donation))
        (approved-steps (get milestones-cleared donation))
        (receiver (get beneficiary donation))
        (full-amount (get total-funds donation))
        (release-amount (/ full-amount (len steps)))
      )
      (asserts! (< approved-steps (len steps)) ERROR_FUNDS_RELEASED)
      (asserts! (is-eq tx-sender CONTRACT_OWNER) ERROR_NOT_AUTHORIZED)
      (match (stx-transfer? release-amount (as-contract tx-sender) receiver)
        success
          (begin
            (map-set DonationRecords
              { id: donation-id }
              (merge donation { milestones-cleared: (+ approved-steps u1) })
            )
            (ok true)
          )
        error ERROR_TRANSFER_FAILED
      )
    )
  )
)

;; Reclaim donation if escrow expired
(define-public (claim-refund (donation-id uint))
  (begin
    (asserts! (valid-donation-id? donation-id) ERROR_INVALID_ID)
    (let
      (
        (donation (unwrap! (map-get? DonationRecords { id: donation-id }) ERROR_NO_ESCROW))
        (original-donor (get contributor donation))
        (refund-amount (get total-funds donation))
      )
      (asserts! (is-eq tx-sender CONTRACT_OWNER) ERROR_NOT_AUTHORIZED)
      (asserts! (> block-height (get expiry-block donation)) ERROR_ESCROW_EXPIRED)
      (match (stx-transfer? refund-amount (as-contract tx-sender) original-donor)
        success
          (begin
            (map-set DonationRecords
              { id: donation-id }
              (merge donation { current-status: "refunded" })
            )
            (ok true)
          )
        error ERROR_TRANSFER_FAILED
      )
    )
  )
)

;; Retrieve details of a specific donation
(define-read-only (fetch-donation (donation-id uint))
  (begin
    (asserts! (valid-donation-id? donation-id) ERROR_INVALID_ID)
    (match (map-get? DonationRecords { id: donation-id })
      donation (ok donation)
      ERROR_NO_ESCROW
    )
  )
)

;; Get the most recent donation ID
(define-read-only (latest-donation)
  (ok (var-get latest-donation-id))
)
