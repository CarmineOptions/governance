import React, { useEffect, useState } from "react";
import { useContractRead } from "@starknet-react/core";
import { abi } from "../lib/abi";
import { fetchIpfsFile } from "../api/apiService";
import { CONTRACT_ADDR, formatIpfsHash } from "../lib/config";
import { CopyIcon, TickIcon } from "../assets/icons/icons";
type CommentProps = {
  address: string;
  text: string;
  starknet_id: string;
}[];
type Props = {
  proposalId: string;
};
export default function Comments({ proposalId }: Props) {
  const [comments, setComments] = useState<CommentProps>([]);
  const [isCopied, setIsCopied] = useState(false);
  const { data, isLoading } = useContractRead({
    functionName: "get_comments",
    args: [proposalId.toString()],
    abi,
    address: CONTRACT_ADDR,
    watch: true,
  });


  console.log(data, "from smart contract")

  useEffect(() => {
    const fetchData = async () => {
      try {
        if (Array.isArray(data)) {
          const ipfsFetchPromises = data.map((item: { ipfs_hash: string }) =>
            fetchIpfsFile(formatIpfsHash(item.ipfs_hash))
          );
          const ipfsResults = await Promise.all(ipfsFetchPromises);

          setComments(ipfsResults);
        }
      } catch (e) {
        console.error("Error fetching from IPFS:", e);
      }
    };

    fetchData();
  }, [data]);

  function handleCopyClick(address: string) {
    if (!address) return;
    navigator.clipboard.writeText(address);
    setIsCopied(true);
  }


  return isLoading ? (
    <div>loading.... </div>
  ) : (
    <div className="w-[35rem] pt-5">
      <div className="py-2">
        {comments.length > 0 ?
          comments.map(({ address, text, starknet_id }, i) => (
            <div key={i}>
              <div className="grid grid-cols-[1fr_3fr] gap-3 ">
                <p className="text-sm font-[400] ">Senders Address:</p>
                <div className="flex items-center gap-2">
                  <p className="font-[600]  text-sm">{address.slice(0, 20)}</p>
                  <div onClick={() => handleCopyClick(address)}>
                    {isCopied ? <TickIcon /> : <CopyIcon />}
                  </div>
                </div>

                <p className="text-sm font-[400] ">Comment:</p>
                <p className="font-[600]  text-sm">{text}</p>

                <p className="text-sm font-[400]">Token Balance:</p>
                <p className="font-[600]  text-sm">{starknet_id}</p>
              </div>
              <div className="border border-b-gray-200 mt-2" />
            </div>
          )): <div className="flex justify-center items-center"> <p className="text-sm font-extrabold ">No comments available </p> </div>}
      </div>
    </div>
  );
}
