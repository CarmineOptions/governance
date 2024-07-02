# Treasury

## Overview

The Treasury contract manages a protocol's funds, allowing for various financial operations such as token transfers, liquidity provision, and interactions with external protocols like Carmine AMM and ZkLend.

## Standalone Nature

The Treasury is intentionally designed as a standalone contract, separate from the main governance contract. This architectural decision provides several benefits:

- **Enhanced Security**: By isolating the Treasury functionality, the risk of potential vulnerabilities in other parts of the system affecting the funds is reduced.
- **Operational Flexibility**: The standalone nature allows for easier upgrades and modifications to the Treasury without affecting the core governance functionality.

## Key Functions

### Token Management

- `send_tokens_to_address`: Allows sending tokens from the Treasury to a specified address.
- `update_AMM_address`: Updates the address of the AMM contract.

### Liquidity Operations

- `provide_liquidity_to_carm_AMM`: Provides liquidity to the Carmine AMM.
- `withdraw_liquidity`: Withdraws liquidity from the Carmine AMM.
- `deposit_to_zklend`: Deposits tokens to the ZkLend protocol.
- `withdraw_from_zklend`: Withdraws tokens from the ZkLend protocol.

## Integration with Governance

While the Treasury is a standalone contract, it is designed to work closely with the governance system:

1. The governance contract is typically set as the owner of the Treasury.
2. Proposals can be created to execute Treasury functions, allowing for community-driven financial decisions.
3. The Treasury can be upgraded through the governance process if needed.

## External Protocol Interactions

The Treasury is designed to interact with external protocols:

- **Carmine AMM**: For liquidity provision and withdrawal operations.
- **ZkLend**: For deposit and withdrawal operations in the ZkLend lending protocol.

## Token Distribution to Tokenholders

The main Konoha contract is designed for minting and burning of the non-transferable governance token. To distribute tokens to tokenholders, we use an external airdrop contract, specifically the [DeFiSpring contract](https://github.com/starknetfndn/defispring). Here's how to set it up:

1. Deploy the DeFiSpring contract
2. Send tokens from the Treasury to the DeFiSpring contract
3. Add a merkle root to the DeFiSpring contract

This process is executed through an arbitrary proposal. Here's a step-by-step guide:

### 1. Prepare the Arbitrary Proposal

Create a new Cairo file `airdrop_controller.cairo` with the following structure:

```rust
#[starknet::interface]
trait IAirdropController<TContractState> {
    fn execute_arbitrary_proposal(ref self: TContractState);
}

#[starknet::contract]
mod AirdropController {
    use starknet::{ContractAddress, ClassHash};
    use openzeppelin::token::erc20::interface::IERC20Dispatcher;
    use konoha::treasury::ITreasuryDispatcher;
    use defispring::IDefiSpringDispatcher;

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl AirdropController of super::IAirdropController<ContractState> {
        fn execute_arbitrary_proposal(ref self: ContractState) {
            // Contract addresses (replace with actual addresses)
            let governance_address: ContractAddress = 0x123...;
            let treasury_address: ContractAddress = 0x456...;
            let token_to_distribute: ContractAddress = 0x789...;
            
            // 1. Deploy DeFiSpring contract
            let defispring_class_hash: ClassHash = 0xABC...;  // Replace with actual class hash
            let mut calldata = ArrayTrait::new();
            calldata.append(governance_address.into());  // Set governance as owner
            let (defispring_address, _) = starknet::deploy_syscall(
                defispring_class_hash, 0, calldata.span(), false
            ).unwrap();

            // 2. Send tokens from Treasury to DeFiSpring contract
            let amount_to_distribute = 1000000000000000000000;  // Example: 1000 tokens
            let treasury = ITreasuryDispatcher { contract_address: treasury_address };
            treasury.send_tokens_to_address(defispring_address, amount_to_distribute, token_to_distribute);

            // 3. Add merkle root to DeFiSpring contract
            let merkle_root: felt252 = 0xDEF...;  // Replace with actual merkle root
            let defispring = IDefiSpringDispatcher { contract_address: defispring_address };
            defispring.add_root(merkle_root);
        }
    }
}
```

### 2. Submit the Arbitrary Proposal

Declare the AirdropController class and note its class hash.
Submit a proposal with to_upgrade = 6 and the payload being the class hash of the AirdropController.

### 3. Execute the Proposal

Once the proposal passes, call [apply_passed_proposal](./upgrades.md#apply_passed_proposal) on the governance contract to execute the arbitrary proposal. This will:

Deploy the DeFiSpring contract with governance as the owner.
Transfer the specified amount of tokens from the Treasury to the DeFiSpring contract.
Add the merkle root to the DeFiSpring contract, enabling users to claim their allocated tokens.

### 4. Claiming Tokens

After the setup is complete, users can claim their tokens directly from the DeFiSpring contract using the claim function, providing their address, amount, and merkle proof.
This approach ensures that the governance token remains non-transferable within the main Konoha system while still allowing for secure and efficient token distribution when necessary.