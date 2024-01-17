use starknet::{ClassHash, ContractAddress};

use governance::types::OptionSide;
use governance::types::OptionType;

use core::starknet::SyscallResultTrait;
use cubit::f128::types::{Fixed, FixedTrait};

#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> u8;
    fn totalSupply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
trait IAMM<TContractState> {
    fn trade_open(
        ref self: TContractState,
        option_type: OptionType,
        strike_price: Fixed,
        maturity: u64,
        option_side: OptionSide,
        option_size: u128,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        limit_total_premia: Fixed,
        tx_deadline: u64,
    ) -> Fixed;
    fn trade_close(
        ref self: TContractState,
        option_type: OptionType,
        strike_price: Fixed,
        maturity: u64,
        option_side: OptionSide,
        option_size: u128,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        limit_total_premia: Fixed,
        tx_deadline: u64,
    ) -> Fixed;
    fn trade_settle(
        ref self: TContractState,
        option_type: OptionType,
        strike_price: Fixed,
        maturity: u64,
        option_side: OptionSide,
        option_size: u128,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
    );
    fn is_option_available(
        self: @TContractState,
        lptoken_address: ContractAddress,
        option_side: OptionSide,
        strike_price: Fixed,
        maturity: u64,
    ) -> bool;
    fn set_trading_halt(ref self: TContractState, new_status: bool);
    fn get_trading_halt(self: @TContractState) -> bool;
    fn set_trading_halt_permission(
        ref self: TContractState, address: ContractAddress, permission: bool
    );
    fn get_trading_halt_permission(self: @TContractState, address: ContractAddress) -> bool;
    fn add_lptoken(
        ref self: TContractState,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
        lptoken_address: ContractAddress,
        volatility_adjustment_speed: Fixed,
        max_lpool_bal: u256,
    );
    fn add_option_both_sides(
        ref self: TContractState,
        maturity: u64,
        strike_price: Fixed,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
        lptoken_address: ContractAddress,
        option_token_address_long: ContractAddress,
        option_token_address_short: ContractAddress,
        initial_volatility: Fixed
    );
    fn add_option_both_sides(
        ref self: TContractState,
        maturity: felt252,
        strike_price: Math64x61_,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
        lptoken_address: ContractAddress,
        option_token_address_long: ContractAddress,
        option_token_address_short: ContractAddress,
        initial_volatility: Math64x61_,
    );
    fn get_option_token_address(
        self: @TContractState,
        lptoken_address: ContractAddress,
        option_side: OptionSide,
        maturity: u64,
        strike_price: Fixed,
    ) -> ContractAddress;
    fn get_lptokens_for_underlying(
        self: @TContractState, pooled_token_addr: ContractAddress, underlying_amt: u256,
    ) -> u256;
    fn get_underlying_for_lptokens(
        self: @TContractState, lptoken_addr: ContractAddress, lpt_amt: u256
    ) -> u256;
    fn get_available_lptoken_addresses(self: @TContractState, order_i: felt252) -> ContractAddress;
    // fn get_all_options(self: @TContractState, lptoken_address: ContractAddress) -> Array<Option_>;
    // fn get_all_non_expired_options_with_premia(
    //     self: @TContractState, lptoken_address: ContractAddress
    // ) -> Array<OptionWithPremia>;
    // fn get_option_with_position_of_user(
    //     self: @TContractState, user_address: ContractAddress
    // ) -> Array<OptionWithUsersPosition>;
    fn get_all_lptoken_addresses(self: @TContractState,) -> Array<ContractAddress>;
    fn get_value_of_pool_position(self: @TContractState, lptoken_address: ContractAddress) -> Fixed;

    fn get_value_of_pool_expired_position(
        self: @TContractState, lptoken_address: ContractAddress
    ) -> Fixed;
    fn get_value_of_pool_non_expired_position(
        self: @TContractState, lptoken_address: ContractAddress
    ) -> Fixed;


    // fn get_value_of_position(
    //     self: @TContractState,
    //     option: Option_,
    //     position_size: u128,
    //     option_type: OptionType,
    //     current_volatility: Fixed,
    // ) -> Fixed;
    // fn get_all_poolinfo(self: @TContractState) -> Array<PoolInfo>;
    // fn get_user_pool_infos(self: @TContractState, user: ContractAddress) -> Array<UserPoolInfo>;
    fn deposit_liquidity(
        ref self: TContractState,
        pooled_token_addr: ContractAddress,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
        amount: u256,
    );
    fn withdraw_liquidity(
        ref self: TContractState,
        pooled_token_addr: ContractAddress,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
        lp_token_amount: u256,
    );
    fn get_unlocked_capital(self: @TContractState, lptoken_address: ContractAddress) -> u256;
    fn expire_option_token_for_pool(
        ref self: TContractState,
        lptoken_address: ContractAddress,
        option_side: OptionSide,
        strike_price: Fixed,
        maturity: u64,
    );
    fn set_max_option_size_percent_of_voladjspd(
        ref self: TContractState, max_opt_size_as_perc_of_vol_adjspd: u128
    );
    fn get_max_option_size_percent_of_voladjspd(self: @TContractState) -> u128;
    fn get_lpool_balance(self: @TContractState, lptoken_address: ContractAddress) -> u256;
    fn get_max_lpool_balance(self: @TContractState, lpt_addr: ContractAddress) -> u256;
    fn set_max_lpool_balance(
        ref self: TContractState, lpt_addr: ContractAddress, max_lpool_bal: u256
    );
    fn get_pool_locked_capital(self: @TContractState, lptoken_address: ContractAddress) -> u256;
    // fn get_available_options(
    //     self: @TContractState, lptoken_address: ContractAddress, order_i: u32
    // ) -> Option_;

    fn get_lptoken_address_for_given_option(
        self: @TContractState,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        option_type: OptionType,
    ) -> ContractAddress;
    // fn get_pool_definition_from_lptoken_address(
    //     self: @TContractState, lptoken_addres: ContractAddress
    // ) -> Pool;
    fn get_option_volatility(
        self: @TContractState, lptoken_address: ContractAddress, maturity: u64, strike_price: Fixed,
    ) -> Fixed;
    fn get_underlying_token_address(
        self: @TContractState, lptoken_address: ContractAddress
    ) -> ContractAddress;
    fn get_available_lptoken_addresses_usable_index(
        self: @TContractState, starting_index: felt252
    ) -> felt252;
    fn get_pool_volatility_adjustment_speed(
        self: @TContractState, lptoken_address: ContractAddress
    ) -> Fixed;
    fn set_pool_volatility_adjustment_speed(
        ref self: TContractState, lptoken_address: ContractAddress, new_speed: Fixed
    );
    fn get_option_position(
        self: @TContractState,
        lptoken_address: ContractAddress,
        option_side: OptionSide,
        maturity: u64,
        strike_price: Fixed
    ) -> u128;
    // fn get_total_premia(
    //     self: @TContractState, option: Option_, position_size: u256, is_closing: bool
    // ) -> (Fixed, Fixed);

    fn black_scholes(
        self: @TContractState,
        sigma: Fixed,
        time_till_maturity_annualized: Fixed,
        strike_price: Fixed,
        underlying_price: Fixed,
        risk_free_rate_annualized: Fixed,
        is_for_trade: bool, // bool
    ) -> (Fixed, Fixed, bool);
    fn get_current_price(
        self: @TContractState,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress
    ) -> Fixed;
    fn get_terminal_price(
        self: @TContractState,
        quote_token_address: ContractAddress,
        base_token_address: ContractAddress,
        maturity: u64
    ) -> Fixed;

    fn set_pragma_checkpoint(ref self: TContractState, key: felt252);
    fn set_pragma_required_checkpoints(ref self: TContractState);
    fn upgrade(ref self: TContractState, new_implementation: ClassHash);
}

#[starknet::interface]
trait IGovernanceToken<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn decimals(self: @TContractState) -> felt252;
    fn totalSupply(self: @TContractState) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> felt252;
    fn transferFrom(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> felt252;
    fn mint(ref self: TContractState, to: ContractAddress, amount: u256);
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> felt252;
    fn upgrade(ref self: TContractState, new_implementation: felt252);
    fn initializer(
        ref self: TContractState,
        name: felt252,
        symbol: felt252,
        decimals: felt252,
        initial_supply: u256,
        recipient: ContractAddress,
        proxy_admin: ContractAddress
    );
}

#[starknet::interface]
trait IOptionToken<TState> {
    // IERC20
    fn total_supply(self: @TState) -> u256;
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn allowance(self: @TState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TState, spender: ContractAddress, amount: u256) -> bool;

    // IERC20Metadata
    fn name(self: @TState) -> felt252;
    fn symbol(self: @TState) -> felt252;
    fn decimals(self: @TState) -> u8;

    // IERC20SafeAllowance
    fn increase_allowance(ref self: TState, spender: ContractAddress, added_value: u256) -> bool;
    fn decrease_allowance(
        ref self: TState, spender: ContractAddress, subtracted_value: u256
    ) -> bool;

    // IERC20CamelOnly
    fn totalSupply(self: @TState) -> u256;
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(
        ref self: TState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;

    // IERC20CamelSafeAllowance
    fn increaseAllowance(ref self: TState, spender: ContractAddress, addedValue: u256) -> bool;
    fn decreaseAllowance(ref self: TState, spender: ContractAddress, subtractedValue: u256) -> bool;

    // Custom Functions
    fn mint(ref self: TState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TState, account: ContractAddress, amount: u256);
    fn upgrade(ref self: TState, new_class_hash: ClassHash);

    // Ownable Functions
    fn transferOwnership(ref self: TState, newOwner: ContractAddress);
    fn renounceOwnership(ref self: TState);
    fn owner(self: @TState) -> ContractAddress;
    fn transfer_ownership(ref self: TState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TState);

    // Option data
    fn quote_token_address(self: @TState) -> ContractAddress;
    fn base_token_address(self: @TState) -> ContractAddress;
    fn option_type(self: @TState) -> u8;
    fn strike_price(self: @TState) -> Fixed;
    fn maturity(self: @TState) -> u64;
    fn side(self: @TState) -> u8;
}
