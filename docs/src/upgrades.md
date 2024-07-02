# Upgrades

Upgrades are another core part of Konoha's governance system, they work in tandem with the proposals component to execute approved changes.

## Component interface

### `apply_passed_proposal`

This is the main function of the upgrades component. It takes a proposal ID as an argument and executes the upgrade associated with that proposal. The function performs the following steps:

1. Checks if the proposal has passed.
2. Ensures the proposal hasn't been applied before.
3. Retrieves the proposal details.
4. Executes the upgrade based on the proposal type.

It can be called by anyone, e.g. a keeper bot. The only parameter is the `prop_id` of the proposal to apply.

## Security Considerations

- Only passed proposals can be applied.
- Each proposal can only be applied once.

## Usage

1. A proposal is submitted and voted on (see [Proposals](./proposals.md)).
2. If the proposal passes, anyone can call `apply_passed_proposal` to execute the upgrade.
3. The system emits an `Upgraded` event when a proposal is successfully applied.
