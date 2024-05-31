#[starknet::interface]
trait IDiscussion<TContractState> {
    fn add_comment(ref self: TContractState, prop_id: felt252, ipfs_hash: felt252);
    fn get_comment(self: @TContractState, prop_id: felt252) -> Array<felt252>;
} 

#[starknet::component]
mod discussion {
    use array::ArrayTrait;
    use konoha::proposals::IProposals;

    use core::box::Box;

    #[storage]
    struct Storage {
        comments: LegacyMap::<(felt252, u64), felt252>,
        comment_count: LegacyMap::<felt252, u64>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[embeddable_as(DiscussionImpl)]
    impl Discussions<TContractState, +HasComponent<TContractState>
    > of super::IDiscussion<ComponentState<TContractState>> {
        fn add_comment(ref self: ComponentState<TContractState>, prop_id: felt252, ipfs_hash: felt252) {
            //TODO
            //Check if proposal is live 
            // let is_live = self.is_proposal_live(prop_id);

            // assert(is_live != 1, 'Proposal is not live!');

            //get current comment count 
            let count: u64 = self.comment_count.read(prop_id);

            //store new comment at next index
            self.comments.write((prop_id, count), ipfs_hash);

            //Increment comment count
            self.comment_count.write(prop_id, count + 1);
            
        }

        fn get_comment(self: @ComponentState<TContractState>, prop_id: felt252) -> Array<felt252> {
            //Get comment counts 
            let count: u64 = self.comment_count.read(prop_id);

            //Initialize an array of comments
            let mut arr = ArrayTrait::<felt252>::new();

            //if no comments, return empty array
            if count == 0 {
                return arr;
            }

            // loop over comment count and collect comments
            let mut i: u64 = 0;
            loop {
                if i >= count {
                    break;
                }

                //collect comment at position i
                let com: felt252 = self.comments.read((prop_id, i));
                arr.append(com);
                i += 1;  
            };

            // return array of comments
            arr
        }
    }

    #[generate_trait]
    impl InternalImpl<TContractState, +HasComponent<TContractState>, +IProposals<TContractState>
    > of InternalTrait<TContractState> {
        fn is_proposal_live(ref self: ComponentState<TContractState>, prop_id: felt252 ) -> u8 {
            //Get live proposals
            let live_proposals = self.get_contract().get_live_proposals();

            // Initialize is_live to 0 (0 = false , 1 = true)
            let mut is_live = 0;

            //loop over the array to check if prop_id is in the array
            let mut i = 0;
            loop {
                if i >= live_proposals.len() {
                    break;
                }

                match live_proposals.get(i) {
                    Option::Some(_prop_id) => is_live = 1,
                    Option::None => i += 1
                }

                // let cur = live_proposals.get(i);

                // if cur = prop_id {
                //     is_live = 1;
                // } else {
                //     i += 1;
                // }
            };

            is_live
        }
    }
}