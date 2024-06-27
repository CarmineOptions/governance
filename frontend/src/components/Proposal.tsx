import React from "react";
import {
  useAccount,
  useContractRead,
  useContractWrite,
} from "@starknet-react/core";
import { abi } from "../lib/abi";
import { CONTRACT_ADDR } from "../lib/config";
import toast from "react-hot-toast";
import NewcommentCommentForm from "./NewProposalCommentForm";
import Comments from "./Comments";

export default function Proposal({
  proposalId,
  index,
}: {
  proposalId: bigint;
  index: number;
}) {
  const { isConnected } = useAccount();
  const [isNewCommentModalOpen, setIsNewCommentModalOpen] =
    React.useState<boolean>(false);
  const [isCommentModalOpen, setIsCommentModalOpen] =
    React.useState<boolean>(false);
  // Call the contract function get_proposal_details with the proposalId to get the proposal details
  const { data, isLoading } = useContractRead({
    functionName: "get_proposal_details",
    args: [proposalId.toString()],
    abi,
    address: CONTRACT_ADDR,
    watch: true,
  });

  // Convert the proposal type from number to string
  const proposal_type = {
    0: "amm",
    1: "governance",
    2: "CARM token",
    3: "merkle tree root",
    4: "no-op/signal vote",
  };

  const { writeAsync: write_yes } = useContractWrite({
    calls: [
      {
        contractAddress: CONTRACT_ADDR,
        entrypoint: "vote",
        calldata: [proposalId.toString(), 1],
      },
    ],
  });

  const { writeAsync: write_no } = useContractWrite({
    calls: [
      {
        contractAddress: CONTRACT_ADDR,
        entrypoint: "vote",
        calldata: [proposalId.toString(), 2],
      },
    ],
  });

  // Function to vote on a proposal
  async function vote(vote: boolean) {
    // Check if the user is connected to a wallet
    if (!isConnected) {
      // If the user is not connected, display a toast message
      toast.error("Please connect your wallet to vote");
      return;
    }

    // Call the write function to vote on the proposal
    if (vote) {
      // contract.invoke("vote", [proposalId.toString(), 1]);
      // await contract.functions.vote(proposalId.toString(), 1);
      write_yes()
        .then(() => {
          toast.success("Voted Yes");
        })
        .catch((e) => {
          toast.error("Something went wrong");
          console.error(e);
        });
    } else {
      write_no()
        .then(() => {
          toast.success("Voted No");
        })
        .catch((e) => {
          toast.error("Something went wrong");
          console.error(e);
        });
    }
  }


  return isLoading ? (
    <div>loading contract {proposalId?.toString()}</div>
  ) : (
    <div>
      <div className="w-full max-w-[50rem] flex flex-row items-center gap-1 p-2 pl-0 rounded-lg bg-slate-200">
        <div className="self-stretch pl-5 pr-4 mr-4 font-mono border-r grid text-slate-400 place-content-center border-slate-400">
          {index}
        </div>
        <div>Type:</div>
        <div className="flex justify-between items-center gap-20">
          <div
            className="flex-grow font-bold hover:underline cursor-pointer"
            onClick={() => setIsCommentModalOpen(true)}
          >
            {proposal_type[data.valueOf()["to_upgrade"]]}
          </div>
          <div className="flex items-center gap-2">
            <button
              className="px-3 py-2 text-sm font-semibold bg-green-300 rounded-lg transition-all hover:bg-green-400"
              onClick={() => vote(true)}
            >
               Vote Yes
            </button>
            <button
              className="px-3 py-2 text-sm font-semibold bg-red-300 rounded-lg transition-all hover:bg-red-400"
              onClick={() => vote(false)}
            >
              Vote No
            </button>

            <button
              onClick={() => setIsNewCommentModalOpen(true)}
              className="px-3 py-2 text-sm font-semibold bg-orange-300 hover:bg-orange-400  text-black transition-all rounded-lg"
            >
              Comment
            </button>
          </div>
        </div>
      </div>

      {/* Add New Comment Modal */}

      {isNewCommentModalOpen && (
        <dialog className="fixed inset-0 z-50 flex  items-center justify-center w-full h-full p-6 bg-black bg-opacity-50">
          <div className="relative flex flex-col items-center  gap-4 p-8 bg-white rounded-lg">
            {/* Close modal button */}
            <button
              className="absolute right-3 top-3 text-slate-400"
              onClick={() => setIsNewCommentModalOpen(false)}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="w-6 h-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
            <p className="text-xl font-bold">New Comment</p>
            <NewcommentCommentForm propId={proposalId.toString()} setIsModalOpen={setIsNewCommentModalOpen} />
          </div>
        </dialog>
      )}

      {/* Display comments modal */}

      {isCommentModalOpen && (
        <dialog className="fixed inset-0 z-50 flex  items-center justify-center w-full h-full p-6 bg-black bg-opacity-50">
          <div className="relative flex flex-col items-center  gap-4 p-8 bg-white rounded-lg">
            {/* Close modal button */}
            <button
              className="absolute right-3 top-3 text-slate-400"
              onClick={() => setIsCommentModalOpen(false)}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="w-6 h-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
            <p className="text-xl font-bold">Proposal Comments</p>
            <Comments proposalId={proposalId.toString()} />
          </div>
        </dialog>
      )}
    </div>
  );
}
