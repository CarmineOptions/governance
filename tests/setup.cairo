use array::ArrayTrait;
use core::traits::TryInto;
use debug::PrintTrait;
use starknet::ContractAddress;
use snforge_std::{BlockId, declare, ContractClassTrait, ContractClass, start_prank, CheatTarget};

use governance::contract::IGovernanceDispatcher;
use governance::contract::IGovernanceDispatcherTrait;
use governance::proposals::IProposalsDispatcher;
use governance::proposals::IProposalsDispatcherTrait;
use governance::upgrades::IUpgradesDispatcher;
use governance::upgrades::IUpgradesDispatcherTrait;

fn test_upgrade_root(new_merkle_root: felt) {

    let gov_contract_addr: ContractAddress =
        0x001405ab78ab6ec90fba09e6116f373cda53b0ba557789a4578d8c1ec374ba0f
        .try_into()
        .unwrap();
    
    //let airdrop_contract_addr: ContractAddress = deploy_contract('Airdrop')

    let proposals_dispatcher = IProposalsDispatcher { contract_address: gov_contract_addr };

    let mut top_carm_holders = ArrayTrait::new();
    let marek_address: ContractAddress =
        0x0011d341c6e841426448ff39aa443a6dbb428914e05ba2259463c18308b86233
        .try_into()
        .unwrap();
    top_carm_holders.append(marek_address);
    let scaling_address: ContractAddress =
        0x052df7acdfd3174241fa6bd5e1b7192cd133f8fc30a2a6ed99b0ddbfb5b22dcd
        .try_into()
        .unwrap();
    top_carm_holders.append(scaling_address);
    let ondrej_address: ContractAddress =
        0x0583a9d956d65628f806386ab5b12dccd74236a3c6b930ded9cf3c54efc722a1
        .try_into()
        .unwrap();
    top_carm_holders.append(ondrej_address);
    let carlote_address: ContractAddress =
        0x021b2b25dd73bc60b0549683653081f8963562cbe5cba2d123ec0cbcbf0913e4
        .try_into()
        .unwrap();
    top_carm_holders.append(carlote_address);
    let fifth_address: ContractAddress =
        0x02af7135154dc27d9311b79c57ccc7b3a6ed74efd0c2b81116e8eb49dbf6aaf8
        .try_into()
        .unwrap();
    top_carm_holders.append(fifth_address);
    let sixth_address: ContractAddress =
        0x07824efd915baa421d93909bd7f24e36c022b5cfbc5af6687328848a6490ada7
        .try_into()
        .unwrap();
    top_carm_holders.append(sixth_address);
    let madman_address: ContractAddress =
        0x06717eaf502baac2b6b2c6ee3ac39b34a52e726a73905ed586e757158270a0af
        .try_into()
        .unwrap();
    top_carm_holders.append(madman_address);
    let eighth_address: ContractAddress =
        0x03d1525605db970fa1724693404f5f64cba8af82ec4aab514e6ebd3dec4838ad
        .try_into()
        .unwrap();
    top_carm_holders.append(eighth_address);

    start_prank(CheatTarget::One(gov_contract_addr), scaling_address);
    let new_prop_id = dispatcher.submit_proposal(new_merkle_root, 3);

    loop {
        match top_carm_holders.pop_front() {
            Option::Some(holder) => {
                start_prank(CheatTarget::One(gov_contract_addr), holder);
                dispatcher.vote(new_prop_id, 1);
            },
            Option::None(()) => { break (); },
        }
    };
    assert(dispatcher.get_proposal_status(new_prop_id) == 1, 'proposal not passed!');

    let upgrade_dispatcher = IUpgradesDispatcher { contract_address: gov_contract_addr };
    upgrade_dispatcher.apply_passed_proposal(new_prop_id);
    assert(check_if_healthy(gov_contract_addr), 'new gov not healthy');

}

