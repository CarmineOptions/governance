# Proposals

The core of Konoha are proposals. This is one of the two components (the other being [upgrades](upgrades.md)) that should be mixed into every deployed instance.

## Constants

To propose a proposal, you need voting power equivalent to 1/200th of the total supply of voting tokens.

By default, proposals have a one-week voting period

Both values are adjustable in `constants.cairo`.

## Proposal types

Konoha supports three different types of proposals:
- builtin proposals
- custom proposals
- arbitrary proposals

### Builtin proposals

These are for upgrades of the governance contract itself and for replacing the current merkle tree root.

To propose a builtin proposal, call `submit_proposal` with parameters:
- payload – meaning varies based on the `to_upgrade` value.
    - class hash of the new governance contract if `to_upgrade == 1`
    - merkle tree root for the airdrop component if `to_upgrade == 3`
    - no other builtin proposals are supported

### Custom proposals

Custom proposals are best suited for actions that are performed regularly and follow predetermined procedures. While arbitrary proposals can technically be used for any action, doing so may obscure the intent of the proposals, making verification more difficult.

Examples of what custom proposals are for:
- adjust risk parameters of a lending protocol
- adjust the caps on a protocol such as Nimbora
- deposit funds accumulated in treasury to a lending pool or distribute them to tokenholders
- add options to a protocol such as Carmine Options or adjust parameters

To define a custom proposal, either call `add_custom_proposal_config` in the constructor of your contract or use an arbitrary proposal that will call `add_custom_proposal_config` under the hood.

#### Custom proposal configuration

A custom proposal is defined by the following values:
- `target` – the contract to be called when executing
- `selector` – function on the target contract to call
- `library_call` – whether this should be called from the governance contract (`false`) or should be executed in the context of governance as a [library call](https://docs.starknet.io/documentation/architecture_and_concepts/Smart_Contracts/system-calls/#library_call). For most custom proposals, it should be enough to keep this as `false`, unless you need to execute multiple different calls in one proposal.

### Arbitrary proposals

Arbitrary proposals enable the execution of any code with the same permissions and authority as the main governance contract.

To prepare an arbitrary proposal, first declare a class with the function `execute_arbitrary_proposal` and note the class hash. This function will execute in the context of governance (will be library called).

To then propose an arbitrary proposal, call `submit_proposal` with `to_upgrade = 6`, and the payload being the class hash of the previously declared class.

## Customization

Protocols can customize the proposal system in several ways:

1. **Adjust voting parameters**: Modify the `constants.cairo` file to change the required voting power or voting period.

2. **Define custom proposals**: Use the `add_custom_proposal_config` function to define new types of custom proposals specific to your protocol's needs.

3. **Implement arbitrary proposals**: For more complex customizations, create arbitrary proposals that can execute any code within the governance context.

For more detailed customization options, see the [Customizing Konoha](./customizing.md) guide.

## Usage

1. Submit a proposal using `submit_proposal` function.
2. Token holders vote on the proposal during the voting period.
3. If the proposal passes, it can be executed using the `apply_passed_proposal` function (see [Upgrades](./upgrades.md)).
