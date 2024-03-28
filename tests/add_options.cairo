use super::basic::submit_44_signal_proposals;

use governance::traits::IAMM;
use governance::contract::IGovernanceDispatcher;
use governance::contract::IGovernanceDispatcherTrait;
use governance::traits::{
    IAMMDispatcher, IAMMDispatcherTrait, IERC20Dispatcher, IERC20DispatcherTrait
};

use starknet::{ContractAddress, get_block_timestamp};

use snforge_std::{declare, ContractClassTrait, ContractClass, start_prank, start_warp, CheatTarget};
use cubit::f128::types::{Fixed, FixedTrait};

use debug::PrintTrait;

// #[test]
// #[fork("MAINNET")]
// fn test_add_options() {
//     submit_44_signal_proposals();
//     let gov_contract_addr: ContractAddress =
//         0x001405ab78ab6ec90fba09e6116f373cda53b0ba557789a4578d8c1ec374ba0f
//         .try_into()
//         .unwrap();
//     let dispatcher = IGovernanceDispatcher { contract_address: gov_contract_addr };
//     let marek_address: ContractAddress =
//         0x0011d341c6e841426448ff39aa443a6dbb428914e05ba2259463c18308b86233
//         .try_into()
//         .unwrap();
//     let new_contract: ContractClass = declare('Governance');
//     start_prank(CheatTarget::One(gov_contract_addr), marek_address);
//     let ret = dispatcher.submit_proposal(new_contract.class_hash.into(), 1);
//     dispatcher.vote(ret, 1);
//     let curr_timestamp = get_block_timestamp();
//     let warped_timestamp = curr_timestamp + consteval_int!(60 * 60 * 24 * 7) + 420;
//     start_warp(CheatTarget::One(gov_contract_addr), warped_timestamp);
//     let status = dispatcher.get_proposal_status(ret);
//     dispatcher.apply_passed_proposal(ret);
//     dispatcher.add_0501_options();
//     let amm_addr = 0x076dbabc4293db346b0a56b29b6ea9fe18e93742c73f12348c8747ecfc1050aa
//         .try_into()
//         .unwrap();
//     trade_option(1704412799, marek_address, amm_addr, FixedTrait::from_unscaled_felt(2200));
// }

// buys 0.01 long eth/usdc call
fn trade_option(
    maturity: u64, trader: ContractAddress, amm_addr: ContractAddress, strike_price: Fixed
) {
    let amm = IAMMDispatcher { contract_address: amm_addr };
    start_prank(CheatTarget::One(amm_addr), trader);
    let amt = 184467440737095520;
    let USDC_addr: felt252 = 0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8;
    let ETH_addr: felt252 = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;
    let quote_token_address = USDC_addr.try_into().unwrap();
    let base_token_address = ETH_addr.try_into().unwrap();
    let curr_timestamp = get_block_timestamp();
    let eth = IERC20Dispatcher { contract_address: base_token_address };
    start_prank(CheatTarget::One(base_token_address), trader);
    eth.approve(amm_addr, amt + amt);
    amm
        .trade_open(
            0,
            strike_price,
            maturity.into(),
            0,
            amt.low.into(),
            quote_token_address,
            base_token_address,
            FixedTrait::ONE(),
            (curr_timestamp + 420).into()
        );
}
