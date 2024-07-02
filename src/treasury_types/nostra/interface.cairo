use starknet::ContractAddress;

#[starknet::interface]
trait INostraInterestToken<TContractState> {
    fn mint(self: @TContractState, to: ContractAddress, amount: u256);
    fn burn(
        self: @TContractState, from: ContractAddress, to: ContractAddress, amount: u256
    ) -> u256;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
}

