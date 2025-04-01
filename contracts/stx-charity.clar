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
