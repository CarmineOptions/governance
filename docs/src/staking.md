# Staking

Staking is a crucial component of Konoha, allowing token holders to lock up their tokens in exchange for voting power and potential rewards.

## Key Features

- Flexible staking durations
- Customizable staking curve
- Support for multiple token types

## Customization

Protocols can customize the staking mechanism in by adjusting the **staking curve**: the relationship between stake duration and voting power. This is set in the constructor or through a proposal.


## Usage

Users can stake tokens using the `stake` function, specifying the amount and duration. The `unstake` function is used to withdraw tokens after the locking period.

## Constructor Parameters

The staking component can be customized during deployment by setting the following parameters in the constructor:

- `floating_token_address`: The address of the token that can be staked.
- `curve_points`: Initial set of points defining the staking curve.

## Customization through Proposals

After deployment, the staking mechanism can be further customized through governance proposals. This includes:

- Updating the staking curve
- Changing the floating token address
- Modifying reward distribution parameters

For more advanced customizations, please contact the Konoha maintainers to discuss your specific needs.