import { StarknetIdNavigator } from "starknetid.js";
import { RpcProvider, constants } from "starknet";
import * as dotenv from "dotenv";

dotenv.config();

const NODE_URL: string = process.env.NODE_URL || "";

export const getStarknetId = async (
  address: string
): Promise<string | null> => {
  const provider = new RpcProvider({
    nodeUrl: NODE_URL,
    chainId: constants.StarknetChainId.SN_MAIN
  });

  const starknetIdNavigator = new StarknetIdNavigator(
    provider,
    constants.StarknetChainId.SN_MAIN
  );

  try {
    const domain = await starknetIdNavigator.getStarkName(address);
    const id = await starknetIdNavigator.getStarknetId(domain);
    return id;
  } catch {
    return null;
  }
};
