mod testStorage {
    use core::traits::TryInto;
    use starknet::ContractAddress;
    const zero_address: felt252 = 0;
    const GOV_CONTRACT_ADDRESS: felt252 =
        0x0304256e5fade73a6fc8f49ed7c1c43ac34e6867426601b01204e1f7ba05b53d;
    const AMM_CONTRACT_ADDRESS: felt252 =
        0x018890b58b08f341acd1292e8f67edfb01f539c835ef4a2176946a995fe794a5;
}

use core::result::ResultTrait;
use core::serde::Serde;
use core::option::OptionTrait;
use core::traits::{TryInto, Into};
use core::byte_array::ByteArray;
use cubit::f128::types::{Fixed, FixedTrait};
use array::ArrayTrait;
use debug::PrintTrait;
use starknet::ContractAddress;
use snforge_std::{
    BlockId, declare, ContractClassTrait, ContractClass, prank, CheatSpan, CheatTarget, start_roll, stop_roll,
};
use governance::treasury::{ITreasuryDispatcher, ITreasuryDispatcherTrait};
use governance::traits::{
    IERC20Dispatcher, IERC20DispatcherTrait, IAMMDispatcher, IAMMDispatcherTrait
};
use openzeppelin::access::ownable::interface::{IOwnableTwoStep, IOwnableTwoStepDispatcherTrait, IOwnableTwoStepDispatcher};



fn get_important_addresses() -> (ContractAddress, ContractAddress, ContractAddress) {
    let gov_contract_address: ContractAddress = testStorage::GOV_CONTRACT_ADDRESS
        .try_into()
        .unwrap();
    let AMM_contract_address: ContractAddress = testStorage::AMM_CONTRACT_ADDRESS
        .try_into()
        .unwrap();
    let contract = declare("Treasury");
    let mut calldata = ArrayTrait::new();
    gov_contract_address.serialize(ref calldata);
    AMM_contract_address.serialize(ref calldata);

    // Precalculate the address to obtain the contract address before the constructor call (deploy) itself
    let contract_address = contract.precalculate_address(@calldata);

    prank(CheatTarget::One(contract_address), gov_contract_address, CheatSpan::TargetCalls(1));
    let deployed_contract = contract.deploy(@calldata).unwrap();

    return (gov_contract_address, AMM_contract_address, deployed_contract,);
}


#[test]
#[fork("SEPOLIA")]
fn test_transfer_token() {
    let (gov_contract_address, _AMM_contract_address, treasury_contract_address) =
        get_important_addresses();
    let user1: ContractAddress = 0x06730c211d67bb7c463190f10baa95529c82de2e32d79dd4cb3b185b6d0ddf86
        .try_into()
        .unwrap();
    let user2: ContractAddress = '0xUser2'.try_into().unwrap();
    let token: ContractAddress = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
        .try_into()
        .unwrap();
    let decimal: u256 = 1_000000000000000000;

    prank(CheatTarget::One(token), user1, CheatSpan::TargetCalls(1));
    IERC20Dispatcher { contract_address: token }.transfer(treasury_contract_address, 1 * decimal);

    let user2_bal_before_transfer = IERC20Dispatcher { contract_address: token }.balanceOf(user2);

    prank(
        CheatTarget::One(treasury_contract_address), gov_contract_address, CheatSpan::TargetCalls(1)
    );
    ITreasuryDispatcher { contract_address: treasury_contract_address }
        .send_tokens_to_address(user2, 1 * decimal, token);

    let user2_bal_after_transfer = IERC20Dispatcher { contract_address: token }.balanceOf(user2);

    assert(user2_bal_before_transfer != user2_bal_after_transfer, 'token transfer Error');
    assert(user2_bal_after_transfer == 1 * decimal, 'Transfer calculation error');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
#[fork("SEPOLIA")]
fn test_send_tokens_to_address_by_unauthorized_caller() {
    let (_gov_contract_address, _AMM_contract_address, treasury_contract_address) =
        get_important_addresses();
    let user1: ContractAddress = 0x06730c211d67bb7c463190f10baa95529c82de2e32d79dd4cb3b185b6d0ddf86
        .try_into()
        .unwrap();
    let user2: ContractAddress = '0xUser2'.try_into().unwrap();
    let token: ContractAddress = 0x049D36570D4e46f48e99674bd3fcc84644DdD6b96F7C741B1562B82f9e004dC7
        .try_into()
        .unwrap();
    let decimal: u256 = 1_000000000000000000;

    prank(CheatTarget::One(token), user1, CheatSpan::TargetCalls(1));
    IERC20Dispatcher { contract_address: token }.transfer(treasury_contract_address, 1 * decimal);

    let user2_bal_before_transfer = IERC20Dispatcher { contract_address: token }.balanceOf(user2);

    prank(CheatTarget::One(treasury_contract_address), user1, CheatSpan::TargetCalls(1));
    ITreasuryDispatcher { contract_address: treasury_contract_address }
        .send_tokens_to_address(user2, 1 * decimal, token);

    let user2_bal_after_transfer = IERC20Dispatcher { contract_address: token }.balanceOf(user2);

    assert(user2_bal_before_transfer != user2_bal_after_transfer, 'token transfer Error');
    assert(user2_bal_after_transfer == 1 * decimal, 'Transfer calculation error');
}

#[test]
fn test_update_AMM_contract() {
    let (gov_contract_address, _AMM_contract_address, treasury_contract_address) =
        get_important_addresses();
    let new_AMM_contract: ContractAddress = '0xnewAMMcontract'.try_into().unwrap();

    prank(
        CheatTarget::One(treasury_contract_address), gov_contract_address, CheatSpan::TargetCalls(1)
    );
    ITreasuryDispatcher { contract_address: treasury_contract_address }
        .update_AMM_address(new_AMM_contract);

    let recorded_AMM_addr = ITreasuryDispatcher { contract_address: treasury_contract_address }
        .get_amm_address();
    assert(new_AMM_contract == recorded_AMM_addr, 'Error updating AMM address');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_update_AMM_contract_by_unauthorized_caller() {
    let (_gov_contract_address, _AMM_contract_address, treasury_contract_address) =
        get_important_addresses();
    let user2: ContractAddress = '0xUser2'.try_into().unwrap();
    let new_AMM_contract: ContractAddress = '0xnewAMMcontract'.try_into().unwrap();

    prank(CheatTarget::One(treasury_contract_address), user2, CheatSpan::TargetCalls(1));
    ITreasuryDispatcher { contract_address: treasury_contract_address }
        .update_AMM_address(new_AMM_contract);
}

#[test]
fn test_ownership_transfer() {
    let (gov_contract_address, _AMM_contract_address, treasury_contract_address) =
        get_important_addresses(); 
    let user2: ContractAddress = '0xUser2'.try_into().unwrap();

    prank(
        CheatTarget::One(treasury_contract_address), gov_contract_address, CheatSpan::TargetCalls(1)
    );
    IOwnableTwoStepDispatcher { contract_address: treasury_contract_address }
        .transfer_ownership(user2);
    assert( IOwnableTwoStepDispatcher { contract_address: treasury_contract_address }.pending_owner() == user2, 'Pending transfer failed');

    prank(
        CheatTarget::One(treasury_contract_address), user2, CheatSpan::TargetCalls(1)
    );
    IOwnableTwoStepDispatcher { contract_address: treasury_contract_address }.accept_ownership();
    assert( IOwnableTwoStepDispatcher { contract_address: treasury_contract_address }.owner() == user2, 'Ownership transfer failed');
}

#[test]
#[fork("MAINNET")]
fn test_provide_liquidity_to_carm_AMM() { 
    let (gov_contract_address, AMM_contract_address, treasury_contract_address) =
        get_important_addresses();
    let prank_user: ContractAddress = 0x03a20d4f7b4229e7c4863dab158b4d076d7f454b893d90a62011882dc4caca2a.try_into().unwrap();
    let pooled_token: ContractAddress =
        0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
        .try_into()
        .unwrap();
    let base_token: ContractAddress =
        0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
        .try_into()
        .unwrap();
    let quote_token: ContractAddress =
        0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8
        .try_into()
        .unwrap();

    let lp_token_addr: ContractAddress = IAMMDispatcher { contract_address: AMM_contract_address }.get_lptoken_address_for_given_option(quote_token, base_token, 0);
    let lpool_bal_before = IAMMDispatcher { contract_address: AMM_contract_address }
        .get_lpool_balance(lp_token_addr);

    prank(CheatTarget::One(pooled_token), prank_user, CheatSpan::TargetCalls(1));
    IERC20Dispatcher { contract_address: pooled_token }
        .transfer(treasury_contract_address, 100000000000000);
        
    prank(
        CheatTarget::One(treasury_contract_address), gov_contract_address, CheatSpan::TargetCalls(1)
    );
    ITreasuryDispatcher { contract_address: treasury_contract_address }
        .provide_liquidity_to_carm_AMM(pooled_token, quote_token, base_token, 0, 100000000000000);

    let lpool_bal_after = IAMMDispatcher { contract_address: AMM_contract_address }
        .get_lpool_balance(lp_token_addr);
    assert(lpool_bal_after > lpool_bal_before, 'Error providing liquidity');
}

// #[test]
// #[fork("MAINNET")]
// fn test_provide_liquidity_to_carm_AMM() {
//     let (gov_contract_address, _AMM_contract_address1, treasury_contract_address) =
//         get_important_addresses();
//     let quote_token: ContractAddress =
//         0x53c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8
//         .try_into()
//         .unwrap();
//     let base_token: ContractAddress =
//         0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
//         .try_into()
//         .unwrap();
//     let pooled_token: ContractAddress =
//         0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
//         .try_into()
//         .unwrap();
//     let newUser: ContractAddress =
//         0x0529420740c3a42dd41f842ac5c03bd0ac4a56780bfd500dfc8488df8d016e2e
//         .try_into()
//         .unwrap();

//     let AMM_hash: felt252 = 0x045fb686c8875f31966e7308d71c03e9ae78f9566a61870a2b616dc225dd3313;
//     let mut calldata1 = ArrayTrait::new();
//     gov_contract_address.serialize(ref calldata1);
//     let AMM_contract_address = ContractClass { class_hash: AMM_hash.try_into().unwrap() }
//         .deploy(@calldata1)
//         .unwrap();

//     let put_lp_token_hash: felt252 =
//         0x06d15bc862ce48375ec98fea84d76ca67b7ac5978d80c848fa5496108783fbc2;
//     let lp_token_name = 'Carmine ETH/USDC call pool';
//     let lp_token_symbol = 'C-ETH/USDC';
//     let mut calldata = ArrayTrait::new();
//     lp_token_name.serialize(ref calldata);
//     lp_token_symbol.serialize(ref calldata);
//     AMM_contract_address.serialize(ref calldata);
//     let put_lp_token_add: ContractAddress = ContractClass {
//         class_hash: put_lp_token_hash.try_into().unwrap()
//     }
//         .deploy(@calldata)
//         .unwrap();

//     prank(CheatTarget::One(AMM_contract_address), gov_contract_address, CheatSpan::TargetCalls(1));
//     IAMMDispatcher { contract_address: AMM_contract_address }
//         .set_max_option_size_percent_of_voladjspd(1_000);

//     prank(CheatTarget::One(pooled_token), newUser, CheatSpan::TargetCalls(2));
//     IERC20Dispatcher { contract_address: pooled_token }
//         .transfer(treasury_contract_address, 6000000000000000);
//     prank(CheatTarget::One(quote_token), newUser, CheatSpan::TargetCalls(2));
//     IERC20Dispatcher { contract_address: quote_token }
//         .transfer(treasury_contract_address, 21921572);

//     prank(CheatTarget::One(pooled_token), gov_contract_address, CheatSpan::TargetCalls(2));
//     IERC20Dispatcher { contract_address: pooled_token }
//         .approve(treasury_contract_address, 5000000000000000);
//     prank(CheatTarget::One(quote_token), gov_contract_address, CheatSpan::TargetCalls(2));
//     IERC20Dispatcher { contract_address: quote_token }.approve(treasury_contract_address, 21921572);

//     prank(CheatTarget::One(AMM_contract_address), gov_contract_address, CheatSpan::TargetCalls(1));
//     IAMMDispatcher { contract_address: AMM_contract_address }
//         .add_lptoken(
//             base_token,
//             quote_token,
//             0,
//             put_lp_token_add,
//             FixedTrait::from_unscaled_felt(5_000),
//             10000000000
//         );

//     let lpool_bal_before = IAMMDispatcher { contract_address: AMM_contract_address }
//         .get_lpool_balance(put_lp_token_add);

//     prank(
//         CheatTarget::One(treasury_contract_address), gov_contract_address, CheatSpan::TargetCalls(1)
//     );
//     ITreasuryDispatcher { contract_address: treasury_contract_address }
//         .provide_liquidity_to_carm_AMM(pooled_token, quote_token, base_token, 0, 21921572);

//     let lpool_bal_after = IAMMDispatcher { contract_address: AMM_contract_address }
//         .get_lpool_balance(put_lp_token_add);
//     assert(lpool_bal_after > lpool_bal_before, 'Error providing liquidity');
// }
