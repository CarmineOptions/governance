// This file if possible calls out to Proposals or Upgrades or other files where actual logic resides.
// When Components arrive in Cairo 2.?, it will be refactored to take advantage of them. Random change to rerun CI

use starknet::ContractAddress;
use governance::types::{ContractType, PropDetails, VoteStatus};

#[starknet::interface]
trait IGovernance<TContractState> {
    // PROPOSALS

    fn vote(ref self: TContractState, prop_id: felt252, opinion: felt252);
    fn get_proposal_details(self: @TContractState, prop_id: felt252) -> PropDetails;
    fn get_vote_counts(self: @TContractState, prop_id: felt252) -> (u128, u128);
    fn submit_proposal(
        ref self: TContractState, impl_hash: felt252, to_upgrade: ContractType
    ) -> felt252;
    fn get_proposal_status(self: @TContractState, prop_id: felt252) -> felt252;
    fn get_live_proposals(self: @TContractState) -> Array<felt252>;
    fn get_user_voted(
        self: @TContractState, user_address: ContractAddress, prop_id: felt252
    ) -> VoteStatus;

    // UPGRADES

    fn get_governance_token_address(self: @TContractState) -> ContractAddress;
    fn get_amm_address(self: @TContractState) -> ContractAddress;
    fn apply_passed_proposal(ref self: TContractState, prop_id: felt252);
// AIRDROPS

// in component

// VESTING

// in component
// OPTIONS / ONE-OFF
}


#[starknet::contract]
mod Governance {
    use governance::types::BlockNumber;
    use governance::types::VoteStatus;
    use governance::proposals::Proposals;
    use governance::types::ContractType;
    use governance::types::PropDetails;
    use governance::upgrades::Upgrades;
    use governance::airdrop::airdrop as airdrop_component;
    use governance::vesting::vesting as vesting_component;

    use starknet::ContractAddress;


    component!(path: airdrop_component, storage: airdrop, event: AirdropEvent);
    component!(path: vesting_component, storage: vesting, event: VestingEvent);

    #[abi(embed_v0)]
    impl Airdrop = airdrop_component::AirdropImpl<ContractState>;

    #[abi(embed_v0)]
    impl Vesting = vesting_component::VestingImpl<ContractState>;

    #[storage]
    struct Storage {
        proposal_details: LegacyMap::<felt252, PropDetails>,
        proposal_vote_ends: LegacyMap::<felt252, BlockNumber>,
        proposal_vote_end_timestamp: LegacyMap::<felt252, u64>,
        proposal_voted_by: LegacyMap::<(felt252, ContractAddress), VoteStatus>,
        proposal_total_yay: LegacyMap::<felt252, felt252>,
        proposal_total_nay: LegacyMap::<felt252, felt252>,
        proposal_applied: LegacyMap::<felt252, felt252>, // should be Bool after migration
        proposal_initializer_run: LegacyMap::<u64, bool>,
        investor_voting_power: LegacyMap::<ContractAddress, felt252>,
        total_investor_distributed_power: felt252,
        governance_token_address: ContractAddress,
        amm_address: ContractAddress,
        delegate_hash: LegacyMap::<ContractAddress, felt252>,
        total_delegated_to: LegacyMap::<ContractAddress, u128>,
        #[substorage(v0)]
        airdrop: airdrop_component::Storage,
        #[substorage(v0)]
        vesting: vesting_component::Storage
    }

    // PROPOSALS

    #[derive(starknet::Event, Drop)]
    struct Proposed {
        prop_id: felt252,
        payload: felt252,
        to_upgrade: ContractType,
    }

    #[derive(starknet::Event, Drop)]
    struct Voted {
        prop_id: felt252,
        voter: ContractAddress,
        opinion: VoteStatus
    }

    #[derive(starknet::Event, Drop)]
    #[event]
    enum Event {
        Proposed: Proposed,
        Voted: Voted,
        AirdropEvent: airdrop_component::Event,
        VestingEvent: vesting_component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, govtoken_address: ContractAddress) {
        // This is not used in production on mainnet, because the governance token is already deployed (and distributed).
        self.governance_token_address.write(govtoken_address);
    }

    #[external(v0)]
    impl Governance of super::IGovernance<ContractState> {
        // PROPOSALS

        fn get_proposal_details(self: @ContractState, prop_id: felt252) -> PropDetails {
            Proposals::get_proposal_details(prop_id)
        }

        // This should ideally return VoteCounts, but it seems like structs can't be returned from 
        // C1.0 external fns as they can't be serialized
        // Actually it can, TODO do the same as I did with PropDetails for this
        fn get_vote_counts(self: @ContractState, prop_id: felt252) -> (u128, u128) {
            Proposals::get_vote_counts(prop_id)
        }

        fn submit_proposal(
            ref self: ContractState, impl_hash: felt252, to_upgrade: ContractType
        ) -> felt252 {
            Proposals::submit_proposal(impl_hash, to_upgrade)
        }

        fn vote(ref self: ContractState, prop_id: felt252, opinion: felt252) {
            Proposals::vote(prop_id, opinion)
        }

        fn get_proposal_status(self: @ContractState, prop_id: felt252) -> felt252 {
            Proposals::get_proposal_status(prop_id)
        }

        fn get_live_proposals(self: @ContractState) -> Array<felt252> {
            Proposals::get_live_proposals()
        }

        fn get_user_voted(
            self: @ContractState, user_address: ContractAddress, prop_id: felt252
        ) -> VoteStatus {
            Proposals::get_user_voted(user_address, prop_id)
        }

        // UPGRADES

        fn get_governance_token_address(self: @ContractState) -> ContractAddress {
            self.governance_token_address.read()
        }

        fn get_amm_address(self: @ContractState) -> ContractAddress {
            self.amm_address.read()
        }

        fn apply_passed_proposal(ref self: ContractState, prop_id: felt252) {
            Upgrades::apply_passed_proposal(prop_id)
        }
    }
}
