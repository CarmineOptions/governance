import config from "./config.json";

export const NETWORK = config.NETWORK as "mainnet" | "testnet";
export const API_URL = config.API_URL;
export const AMM_ADDRESS = config.AMM_ADDRESS;
export const GOVERNANCE_ADDRESS = config.GOVERNANCE_ADDRESS;
export const ETH_ADDRESS = config.ETH_ADDRESS;
export const USDC_ADDRESS = config.USDC_ADDRESS;
export const BTC_ADDRESS = config.BTC_ADDRESS;
export const STRK_ADDRESS = config.STRK_ADDRESS;
export const ETH_USDC_CALL_ADDRESS = config.ETH_USDC_CALL_ADDRESS;
export const ETH_USDC_PUT_ADDRESS = config.ETH_USDC_PUT_ADDRESS;
export const BTC_USDC_CALL_ADDRESS = config.BTC_USDC_CALL_ADDRESS;
export const BTC_USDC_PUT_ADDRESS = config.BTC_USDC_PUT_ADDRESS;
export const ETH_STRK_CALL_ADDRESS = config.ETH_STRK_CALL_ADDRESS;
export const ETH_STRK_PUT_ADDRESS = config.ETH_STRK_PUT_ADDRESS;
export const STRK_USDC_CALL_ADDRESS = config.STRK_USDC_CALL_ADDRESS;
export const STRK_USDC_PUT_ADDRESS = config.STRK_USDC_PUT_ADDRESS;

export const MAINNET_AUX_CONTRACT_ADDRESS =
    "0x03e174d3d7dce00ad5e15299593a28c3defc660c77220867c921611a3aef4149";

export const LEGACY_AMM =
    "0x076dbabc4293db346b0a56b29b6ea9fe18e93742c73f12348c8747ecfc1050aa";
export const LEGACY_CALL_LP =
    "0x7aba50fdb4e024c1ba63e2c60565d0fd32566ff4b18aa5818fc80c30e749024";
export const LEGACY_PUT_LP =
    "0x18a6abca394bd5f822cfa5f88783c01b13e593d1603e7b41b00d31d2ea4827a";

export const AMM_SWITCH_TIMESTAMP = 1704841200;

export const isTestnet = NETWORK === "testnet";
export const isMainnet = NETWORK === "mainnet";
export const enum AMM_METHODS {
    IS_OPTION_AVAILABLE = "is_option_available",
    GET_POOL_AVAILABLE_BALANCE = "get_pool_available_balance",
    APPROVE = "approve",
    TRADE_OPEN = "trade_open",
    TRADE_CLOSE = "trade_close",
    TRADE_SETTLE = "trade_settle",
    GET_AVAILABLE_OPTIONS = "get_available_options",
    GET_OPTION_TOKEN_ADDRESS = "get_option_token_address",
    GET_ALL_NON_EXPIRED_OPTIONS_WITH_PREMIA = "get_all_non_expired_options_with_premia",
    GET_OPTION_WITH_POSITION_OF_USER = "get_option_with_position_of_user",
    DEPOSIT_LIQUIDITY = "deposit_liquidity",
    GET_USER_POOL_INFOS = "get_user_pool_infos",
    WITHDRAW_LIQUIDITY = "withdraw_liquidity",
    GET_TOTAL_PREMIA = "get_total_premia",
    GET_MAX_LPOOL_BALANCE = "get_max_lpool_balance",
    GET_LOOP_BALANCE = "get_lpool_balance",
    GET_UNDERLYING_FOR_LPTOKENS = "get_underlying_for_lptokens",
    GET_UNLOCKED_CAPITAL = "get_unlocked_capital",
}

export const coreTeamAddresses = [
    "0x583a9d956d65628f806386ab5b12dccd74236a3c6b930ded9cf3c54efc722a1",
    "0x6717eaf502baac2b6b2c6ee3ac39b34a52e726a73905ed586e757158270a0af",
    "0x11d341c6e841426448ff39aa443a6dbb428914e05ba2259463c18308b86233",
    "0x3d1525605db970fa1724693404f5f64cba8af82ec4aab514e6ebd3dec4838ad",
    "0x3c032b19003bdd6f4155a30fffa0bda3a9cae45feb994a721299d7e5096568c",
    // my Testnet wallet
    "0x29af9cf62c9d871453f3b033e514dc790ce578e0e07241d6a5fedf19ceeaf08",
];

export const SLIPPAGE = 0.1;

export const BASE_DIGITS = 18;
export const ETH_DIGITS = 18;
export const USDC_DIGITS = 6;
export const ETH_BASE_VALUE = BigInt(10) ** BigInt(ETH_DIGITS);
export const USDC_BASE_VALUE = BigInt(10) ** BigInt(USDC_DIGITS);
export const BASE_MATH_64_61 = BigInt(2) ** BigInt(61);
export const BASE_MATH_64 = BigInt(2) ** BigInt(64);
export const USDC_PRECISSION = 1000;
export const BASE_API_URL = "https://konoha.vote/discussion-api/api/"
export const TEST_FILE: string = "QmVqyWcuoBpHvt5tT5Gw9eJz2qYJyGKw4NY4yEdFcopK69";


