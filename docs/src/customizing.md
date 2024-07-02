# Customizing Konoha

Konoha is designed to be flexible and customizable to meet the specific needs of different protocols. This guide outlines the primary ways you can customize Konoha for your project.

## Proposals

- **Voting parameters**: Adjust the required voting power and voting period in `constants.cairo`.
- **Custom proposals**: Define new types of custom proposals using `add_custom_proposal_config`.
- **Arbitrary proposals**: Implement complex, custom logic using arbitrary proposals.

For more details, see the [Proposals](./proposals.md) documentation.

## Upgrades

Upgrades in Konoha are primarily customizable through custom and arbitrary proposals. This allows for flexible implementation of upgrade logic specific to your protocol's needs.

For more details, see the [Upgrades](./upgrades.md) documentation.

## Staking

- **Staking curve**: Customize the relationship between stake duration and voting power.
- **Token types**: Define which tokens can be staked.

For more details, see the [Staking](./staking.md) documentation.

## Other Customizations

- **Treasury management**: Customize how the protocol's funds are managed and allocated.
- **Token distribution**: Modify airdrop and vesting mechanisms.

## Planned Customizations

We are continuously working to make Konoha more flexible. If you have specific customization needs not covered here, please contact the Konoha maintainers. We're open to discussing and potentially implementing new customization options to meet your protocol's requirements.
