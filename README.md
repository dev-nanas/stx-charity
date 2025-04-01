
# STX-Charity: Blockchain Charity Donation Contract

## Overview

STX-Charity is a decentralized donation platform built on the Stacks blockchain that allows contributors to donate funds with milestone-based releases and an escrow system. The contract ensures secure and transparent transactions while providing the ability for donors to reclaim their contributions if the agreed-upon milestones are not met in time.

## Key Features

- **Decentralized Escrow**: Contributors initiate donations with a milestone-based release system, allowing funds to be unlocked step-by-step.
- **Admin Approval**: Only authorized administrators can approve milestones and release funds to the beneficiaries.
- **Refund Mechanism**: If milestones are not approved in time, the original donor can reclaim their funds after the escrow period expires.
- **Transparent Transactions**: All donation transactions are recorded and transparent on the Stacks blockchain.

## Contract Functions

### 1. **create-donation**
Initiates a new donation escrow with the specified beneficiary, donation amount, and milestone schedule.

- **Inputs**: 
  - `recipient`: The recipient (charity organization).
  - `amount`: Total donation amount.
  - `milestones`: List of milestones to be cleared for fund release.

- **Returns**: Donation ID upon success.

### 2. **release-milestone**
Approves a milestone and releases the corresponding funds to the beneficiary.

- **Inputs**: 
  - `donation-id`: The ID of the donation escrow.

- **Returns**: Success or failure message.

### 3. **claim-refund**
Allows the original donor to reclaim the donation if the escrow expires and milestones have not been approved.

- **Inputs**: 
  - `donation-id`: The ID of the donation escrow.

- **Returns**: Success or failure message.

### 4. **fetch-donation**
Fetches the details of a specific donation based on the donation ID.

- **Inputs**: 
  - `donation-id`: The ID of the donation escrow.

- **Returns**: Donation record details.

### 5. **latest-donation**
Retrieves the most recent donation ID.

- **Returns**: Latest donation ID.

## Error Handling

- **ERROR_NOT_AUTHORIZED (u100)**: The sender is not authorized to perform the action.
- **ERROR_NO_ESCROW (u101)**: No escrow found for the given donation ID.
- **ERROR_FUNDS_RELEASED (u102)**: Funds for the current milestone have already been released.
- **ERROR_TRANSFER_FAILED (u103)**: Transfer of funds failed.
- **ERROR_INVALID_ID (u104)**: Invalid donation ID provided.
- **ERROR_INVALID_AMOUNT (u105)**: Invalid donation amount.
- **ERROR_INVALID_STEP (u106)**: Invalid milestone step.
- **ERROR_ESCROW_EXPIRED (u107)**: The escrow period has expired, and funds can no longer be released.

## Setup

This contract is designed to be deployed on the Stacks blockchain. To interact with the contract, ensure you have the following prerequisites:

- [Stacks CLI](https://docs.stacks.co/build/cli/) installed for deploying and interacting with the contract.
- A wallet compatible with Stacks for making transactions.

## Deployment Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/<username>/stx-charity.git
   cd stx-charity
   ```

2. Deploy the contract to the Stacks blockchain:
   ```bash
   stacks deploy contract stx-charity.clar
   ```

3. Interact with the contract using Stacks CLI or through a front-end application that communicates with the Stacks blockchain.

## Contributing

Feel free to submit pull requests for improvements, bug fixes, or new features. We encourage contributions from the community!

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -am 'Add new feature'`).
5. Push to the branch (`git push origin feature/your-feature-name`).
6. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
