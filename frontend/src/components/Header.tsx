import { useAccount, useDisconnect } from "@starknet-react/core";
import React from "react";
import ConnectModal from "./starknet/ConnectModal";

export default function Header() {
  const { address } = useAccount();
  const { disconnect } = useDisconnect();

  return (
    <div className="fixed top-0 left-0 right-0 flex flex-row justify-between p-2 px-4 bg-white border ">
      {address ? (
        <div className="flex flex-col items-end px-6 py-2 bg-zinc-100 rounded-md">
          <p className="font-semibold">{`${address.slice(
            0,
            6,
          )}...${address.slice(-4)}`}</p>
          <p
            onClick={() => disconnect()}
            className="cursor-pointer text-black/50"
          >
            Disconnect
          </p>
        </div>
      ) : (
        <ConnectModal />
      )}
    </div>
  );
}
