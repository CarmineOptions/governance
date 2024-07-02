use array::ArrayTrait;
use core::option::OptionTrait;
use core::result::ResultTrait;
use core::traits::TryInto;
use debug::PrintTrait;

use konoha::vesting::{IVestingDispatcher, IVestingDispatcherTrait, IVesting};
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{
    BlockId, declare, ContractClassTrait, ContractClass, start_prank, start_warp, CheatTarget,
    prank, CheatSpan
};
use starknet::{ContractAddress, get_caller_address};
use super::setup::{deploy_governance_and_both_tokens};

fn test_setup(gov: ContractAddress) {
    let grantee: ContractAddress = 0x1.try_into().unwrap();
    prank(CheatTarget::One(gov), gov, CheatSpan::TargetCalls(4));
    let gov_vesting = IVestingDispatcher { contract_address: gov };
    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);
}

#[test]
#[should_panic(expected : ('not self-call',))]
fn test_unauthorized_add_vesting_schedule() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    test_setup(gov.contract_address);

    let gov_vesting = IVestingDispatcher { contract_address: gov.contract_address };

    let caller = get_caller_address();

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov.contract_address), caller);

    let grantee: ContractAddress = 0x1.try_into().unwrap();

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);
}

#[test]
#[should_panic(expected: ('not yet eligible',))]
fn test_unauthorized_vest_early() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    test_setup(gov.contract_address);

    let gov_vesting = IVestingDispatcher { contract_address: gov.contract_address };

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov.contract_address), gov.contract_address);

    let grantee: ContractAddress = 0x1.try_into().unwrap();

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);

    gov_vesting.vest(grantee, 10);
}

#[test]
#[should_panic(expected: ('nothing to vest',))]
fn test_vest_twice() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    test_setup(gov.contract_address);

    let gov_vesting = IVestingDispatcher { contract_address: gov.contract_address };

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov.contract_address), gov.contract_address);

    let grantee: ContractAddress = 0x1.try_into().unwrap();

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);

    start_warp(CheatTarget::All, 11);

    gov_vesting.vest(grantee, 10);
    gov_vesting.vest(grantee, 10);
}

#[test]
fn test_add_simple_vesting_schedule() {
    let (gov, token_address, _) = deploy_governance_and_both_tokens();
    test_setup(gov.contract_address);

    let gov_vesting = IVestingDispatcher { contract_address: gov.contract_address };
    let tok = IERC20Dispatcher { contract_address: token_address.contract_address };

    let grantee: ContractAddress = 0x1.try_into().unwrap();
    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000001, grantee);

    start_warp(CheatTarget::All, 11); // past first vest
    // anyone can claim for the grantee
    gov_vesting.vest(grantee, 10);
    assert(tok.balance_of(grantee) == 100000, 'vesting unsuccessful');

    // grantee themselves can claim too
    start_prank(CheatTarget::One(gov.contract_address), grantee);
    start_warp(CheatTarget::All, 21); // past second vest
    gov_vesting.vest(grantee, 20);
    assert(tok.balance_of(grantee) == 200000, 'vesting unsuccessful');

    start_warp(CheatTarget::All, 101); // past last vest. no requirement to vest in order
    gov_vesting.vest(grantee, 100);
    // leftover tokens are included in last vest. (remainder after division)
    assert(tok.balance_of(grantee) == 300001, 'vesting unsuccessful');
}
