use core::option::OptionTrait;
use core::result::ResultTrait;
use array::ArrayTrait;
use core::traits::TryInto;
use debug::PrintTrait;
use starknet::ContractAddress;
use snforge_std::{
    BlockId, declare, ContractClassTrait, ContractClass, start_prank, start_warp, CheatTarget
};

use governance::vesting::{IVestingDispatcher, IVestingDispatcherTrait, IVesting};
use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};

// returns gov addr, token addr
fn test_setup() -> (ContractAddress, ContractAddress) {
    let new_gov_contract: ContractClass = declare('Governance');
    let new_token_contract: ContractClass = declare('MyToken');
    let new_gov_addr: ContractAddress =
        0x001405ab78ab6ec90fba09e6116f373cda53b0ba557789a4578d8c1ec374ba0f
        .try_into()
        .unwrap();
    let mut token_constructor = ArrayTrait::new();
    token_constructor.append(new_gov_addr.into()); // Owner
    let token_address = new_token_contract
        .deploy(@token_constructor)
        .expect('unable to deploy token');
    let mut gov_constructor: Array<felt252> = ArrayTrait::new();
    gov_constructor.append(token_address.into());
    let gov_address = new_gov_contract
        .deploy_at(@gov_constructor, new_gov_addr)
        .expect('unable to deploy gov');

    (gov_address, token_address)
}

#[test]
#[should_panic(expected: ('not self-call',))]
fn test_unauthorized_add_vesting_schedule() {
    let (gov_address, token_address) = test_setup();

    let gov_vesting = IVestingDispatcher { contract_address: gov_address };

    start_warp(CheatTarget::All, 1);

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, 0x1.try_into().unwrap());
}

#[test]
#[should_panic(expected: ('not yet eligible',))]
fn test_unauthorized_vest_early() {
    let (gov_address, token_address) = test_setup();

    let gov_vesting = IVestingDispatcher { contract_address: gov_address };

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov_address), gov_address);

    let grantee: ContractAddress = 0x1.try_into().unwrap();

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);

    gov_vesting.vest(grantee, 10);
}

#[test]
#[should_panic(expected: ('nothing to vest',))]
fn test_vest_twice() {
    let (gov_address, token_address) = test_setup();

    let gov_vesting = IVestingDispatcher { contract_address: gov_address };

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov_address), gov_address);

    let grantee: ContractAddress = 0x1.try_into().unwrap();

    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000000, grantee);

    start_warp(CheatTarget::All, 11);

    gov_vesting.vest(grantee, 10);
    gov_vesting.vest(grantee, 10);
}

#[test]
fn test_add_simple_vesting_schedule() {
    let (gov_address, token_address) = test_setup();

    let gov_vesting = IVestingDispatcher { contract_address: gov_address };
    let tok = IERC20Dispatcher { contract_address: token_address };

    start_warp(CheatTarget::All, 1);
    start_prank(CheatTarget::One(gov_address), gov_address);

    let grantee: ContractAddress = 0x1.try_into().unwrap();
    gov_vesting.add_linear_vesting_schedule(10, 10, 10, 1000001, grantee);

    start_warp(CheatTarget::All, 11); // past first vest
    // anyone can claim for the grantee
    gov_vesting.vest(grantee, 10);
    assert(tok.balance_of(grantee) == 100000, 'vesting unsuccessful');

    // grantee themselves can claim too
    start_prank(CheatTarget::One(gov_address), grantee);
    start_warp(CheatTarget::All, 21); // past second vest
    gov_vesting.vest(grantee, 20);
    assert(tok.balance_of(grantee) == 200000, 'vesting unsuccessful');

    start_warp(CheatTarget::All, 101); // past last vest. no requirement to vest in order
    gov_vesting.vest(grantee, 100);
    // leftover tokens are included in last vest. (remainder after division)
    assert(tok.balance_of(grantee) == 300001, 'vesting unsuccessful');
}
