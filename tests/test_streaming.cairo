use array::ArrayTrait;
use core::option::OptionTrait;
use core::result::ResultTrait;
use core::traits::TryInto;
use debug::PrintTrait;

use konoha::contract::Governance;
use konoha::contract::{IGovernanceDispatcher, IGovernanceDispatcherTrait};
use konoha::traits::{IGovernanceTokenDispatcher, IGovernanceTokenDispatcherTrait};
use starknet::{get_block_timestamp, get_caller_address, get_contract_address, ContractAddress};
use konoha::vesting::{IVestingDispatcher, IVestingDispatcherTrait, IVesting};
use konoha::streaming::{IStreamingDispatcher, IStreamingDispatcherTrait, IStreaming};

use openzeppelin::token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use snforge_std::{
    BlockId, declare, ContractClassTrait, ContractClass, start_prank, start_warp, CheatTarget,
    prank, CheatSpan
};

use super::setup::{deploy_governance_and_both_tokens};

fn start_stream(gov: ContractAddress){
    prank(CheatTarget::One(gov), gov, CheatSpan::TargetCalls(4));
    let streaming = IStreamingDispatcher { contract_address: gov };
    streaming.add_new_stream(get_caller_address(), 0x2.try_into().unwrap(), 100, 200, 100000);
}

//passing!
#[test]
fn test_add_new_stream() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    start_stream(gov.contract_address);
    let streaming = IStreamingDispatcher { contract_address: gov.contract_address };

    let streamer = get_caller_address();
    let recipient = 0x2.try_into().unwrap();
    let start_time: u64 = 100;
    let end_time: u64 = 200;
    let total_amount: u128 = 100000;
    
    streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);
    //let key = (get_caller_address(), recipient, end_time, start_time);

    let (claimed_amount, stored_total_amount) = streaming.get_stream_info(
        streamer, 
        recipient,
        start_time,
        end_time,
    );

    assert_eq!(streamer, get_caller_address(), "Incorrect streamer addr");
    assert_eq!(recipient, 0x2.try_into().unwrap(), "Incorrect streamer addr");
    assert_eq!(start_time, 100, "Incorrect start time");
    assert_eq!(end_time, 200, "Incorrect end time");
    assert_eq!(claimed_amount, 0, "Incorrect claimed amount after stream creation");
    assert_eq!(stored_total_amount, 100000, "Incorrect total amount stored");
}

//passing!
#[test] 
#[should_panic(expected: ('starts first',))]
fn test_valid_stream_time(){
    let (gov, _, _) = deploy_governance_and_both_tokens();
    start_stream(gov.contract_address);
    let streaming = IStreamingDispatcher { contract_address: gov.contract_address };

    let streamer = get_caller_address();
    let recipient = 0x2.try_into().unwrap();
    let start_time: u64 = 200;
    let end_time: u64 = 100;
    let total_amount: u128 = 100000;

    streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);
}

//passing!
#[test] 
#[should_panic(expected: ('nothing to claim',))]
fn test_claimed_amount(){
    let (gov, _, _) = deploy_governance_and_both_tokens();
    start_stream(gov.contract_address);
    let streaming = IStreamingDispatcher { contract_address: gov.contract_address };

    let streamer = get_caller_address();
    let recipient = 0x2.try_into().unwrap();
    let start_time: u64 = 100;
    let end_time: u64 = 200;
    let total_amount: u128 = 0;
    streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);

    start_warp(CheatTarget::One(gov.contract_address), 150);
    //shouldn't have anything to claim
    streaming.claim_stream(streamer, recipient, start_time, end_time);
}

//passing!
#[test]
#[should_panic(expected: ('stream has not started',))]
fn test_stream_started(){
  let (gov, _, _) = deploy_governance_and_both_tokens();
  start_stream(gov.contract_address);
  let streaming = IStreamingDispatcher { contract_address: gov.contract_address };
  let streamer = get_caller_address();
  let recipient = 0x2.try_into().unwrap();
  let start_time: u64 = 100;
  let end_time: u64 = 200;
  let total_amount: u128 = 100000;
  streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);
  start_warp(CheatTarget::One(gov.contract_address), 50);// before of stream
  
  streaming.claim_stream(streamer, recipient, start_time, end_time);
}

#[test]
fn test_claim_stream() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    start_stream(gov.contract_address);
    let streaming = IStreamingDispatcher { contract_address: gov.contract_address };

    let streamer = get_caller_address();
    let recipient = 0x2.try_into().unwrap();
    let start_time: u64 = 100;
    let end_time: u64 = 200;
    let total_amount: u128 = 100000;

    streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);
    let (claimable_amount, total_amount) = streaming.get_stream_info(
        streamer, 
        recipient,
        start_time,
        end_time,
    );
    start_warp(CheatTarget::One(gov.contract_address), 150);

    streaming.claim_stream(streamer, recipient, start_time, end_time);

    let expected_claimed_amount = (100000 * 50/ 100); //should be 50% since middle of stream
    assert_eq!(total_amount, 100000, "Incorrect total amount after claiming the stream");
    assert_eq!(claimable_amount, 0, "Incorrect claimed amount after claiming the stream");

    let self_dsp = IGovernanceDispatcher { contract_address: gov.contract_address };
    let token_address = self_dsp.get_governance_token_address();
    let erc20 = IERC20Dispatcher { contract_address: token_address };
    
    let balance = erc20.balance_of(recipient);

    assert_eq!(balance, expected_claimed_amount, "Balance should match the expected claimed amount");
}

#[test]
fn test_cancel_stream() {
    let (gov, _, _) = deploy_governance_and_both_tokens();
    start_stream(gov.contract_address);
    let streaming = IStreamingDispatcher { contract_address: gov.contract_address };

    let streamer = get_caller_address();
    let recipient = 0x2.try_into().unwrap();
    let start_time: u64 = 100;
    let end_time: u64 = 200;
    let total_amount: u128 = 100000;

    streaming.add_new_stream(streamer, recipient, start_time, end_time, total_amount);

    start_warp(CheatTarget::One(gov.contract_address), 150);

    //test cancel_stream
    streaming.cancel_stream(recipient, start_time, end_time);

    let (claimed_amount, stored_total_amount) = streaming.get_stream_info(
        streamer, 
        recipient, 
        start_time, 
        end_time);

    assert_eq!(claimed_amount, 0, "Claimed amount should be 0 after canceling the stream");
    assert_eq!(stored_total_amount, 0, "Total amount should be 0 after canceling the stream");

    let unclaimed_amount: u256 = total_amount.into() - claimed_amount.into(); //100000
    let self_dsp = IGovernanceDispatcher { contract_address: gov.contract_address };
    let token_address = self_dsp.get_governance_token_address();
    let erc20 = IERC20Dispatcher { contract_address: token_address };

    // Check the balance of the streamer (caller address) with ERC_20, I couldnt use balance_of
    let balance = erc20.balance_of(get_caller_address());

    assert_eq!(unclaimed_amount.into(), 100000, "Unclaimed amount should be reclaimed correctly");
    assert_eq!(balance, 0, "balance");
}
