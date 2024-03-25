// https://github.com/CarmineOptions/carmine-api/blob/master/carmine-api-airdrop/src/merkle_tree.rs

use starknet::ContractAddress;

#[starknet::interface]
trait IAirdrop<TContractState> {
    fn claim(
        ref self: TContractState, claimee: ContractAddress, amount: u128, proof: Array::<felt252>
    );
}

#[starknet::component]
mod airdrop {
    use governance::contract::IGovernance;
    use array::ArrayTrait;
    use hash::LegacyHash;
    use traits::Into;
    use starknet::ContractAddressIntoFelt252;
    use starknet::ContractAddress;
    //use starknet::event::EventEmitter;
    use traits::TryInto;
    use option::OptionTrait;

    use governance::merkle_tree::MerkleTree;
    use governance::merkle_tree::MerkleTreeTrait;

    use governance::contract::Governance;
    use governance::contract::Governance::ContractState;
    use governance::traits::IGovernanceTokenDispatcher;
    use governance::traits::IGovernanceTokenDispatcherTrait;
        
    #[storage]
    struct Storage {
        airdrop_claimed: LegacyMap::<ContractAddress, u128>,
        merkle_root: felt252
    }

    #[derive(starknet::Event, Drop)]
    #[event]
    enum Event {
        Claimed: Claimed
    }

    #[derive(starknet::Event, Drop)]
    struct Claimed {
        address: ContractAddress,
        received: u128
    }
    #[embeddable_as(AirdropImpl)]
    impl Airdrop<
        TContractState, +HasComponent<TContractState>
    > of super::IAirdrop<ComponentState<TContractState>> {
        // Lets claimee claim from merkle tree the amount - claimed_so_far
        fn claim(
            ref self: ComponentState<TContractState>,
            claimee: ContractAddress,
            amount: u128,
            proof: Array::<felt252>
        ) {
            let mut merkle_tree = MerkleTreeTrait::new();
            let amount_felt: felt252 = amount.into();
            let leaf = LegacyHash::hash(claimee.into(), amount_felt);

            let root = merkle_tree.compute_root(leaf, proof.span());
            let state = Governance::unsafe_new_contract_state();
            let stored_root = self.merkle_root.read();
            assert(root == stored_root, 'invalid proof');

            let claimed_so_far: u128 = self.airdrop_claimed.read(claimee);
            assert(claimed_so_far < amount, 'claiming more than eligible for');
            let to_mint = amount - claimed_so_far;

            // Mint
            let govtoken_addr = state.get_governance_token_address();
            IGovernanceTokenDispatcher { contract_address: govtoken_addr }
                .mint(claimee, u256 { high: 0, low: to_mint });

            // Write new claimed amt
            self.airdrop_claimed.write(claimee, to_mint + claimed_so_far);

            // Emit event
            self.emit(Claimed { address: claimee, received: to_mint });
        }
    }
}
