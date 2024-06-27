import React, { useMemo } from "react";
import toast from "react-hot-toast";
import { CONTRACT_ADDR } from "../lib/config";
import { useAccount, useContractWrite } from "@starknet-react/core";

export default function NewProposalForm({
  setIsModalOpen,
}: {
  setIsModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
}) {
  const { isConnected } = useAccount();

  // State variables for the payload and to_upgrade
  const [payload, setPayload] = React.useState<string>("");
  const [to_upgrade, setToUpgrade] = React.useState<string>("0");

  // Create a call to submit a proposal
  const calls = useMemo(() => {
    const tx = {
      contractAddress: CONTRACT_ADDR,
      entrypoint: "submit_proposal",
      calldata: [payload.toString(), to_upgrade.toString()],
    };
    return [tx];
  }, [payload, to_upgrade, submitProposal]);

  // Use the useContractWrite hook to write the proposal
  const { writeAsync } = useContractWrite({ calls });

  function submitProposal(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();

    // Check if the user is connected
    if (!isConnected) {
      toast.error("Please connect your wallet");
      return;
    }

    // Check if the payload and to_upgrade fields are filled out
    if (!payload || !to_upgrade) {
      toast.error("Please fill out all fields");
      return;
    }

    // Call the write function to submit the proposal
    writeAsync()
      .then(() => {
        toast.success("Proposal submitted");
      })
      .catch((e) => {
        toast.error("Something went wrong");
        console.error(e);
      })
      .finally(() => {
        setIsModalOpen(false);
      });
  }

  return (
    <form onSubmit={submitProposal}>
      <label htmlFor="#payload">Payload</label>
      <input
        id="#payload"
        type="text"
        placeholder="(integer or hex, e.g.: 1 or 0x1)"
        className="w-full p-2 mb-2 border rounded-lg border-slate-300"
        onChange={(e) => setPayload(e.target.value)}
      />
      <label htmlFor="#to_upgrade">To Upgrade</label>
      <select
        id="#to_upgrade"
        className="w-full p-2 border rounded-lg border-slate-300"
        onChange={(e) => setToUpgrade(e.target.value)}
        defaultValue={to_upgrade}
      >
        <option value="0">amm</option>
        <option value="1">governance</option>
        <option value="2">CARM token</option>
        <option value="3">merkle tree root</option>
        <option value="4">no-op/signal vote</option>
      </select>

      <button
        type="submit"
        className="w-full p-2 mt-4 text-white bg-blue-500 rounded-lg"
      >
        Submit
      </button>
    </form>
  );
}
