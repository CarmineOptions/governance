import { getStarknetId } from "../src/starknet";
import { RpcProvider, constants } from "starknet";
import { StarknetIdNavigator } from "starknetid.js";

describe("getStarknetId", () => {
  it("should return the Starknet ID for a valid address", async () => {
    const address =
      "0x01f0d3e6e3b1116fbf69dd670e5c079c8c3b6e5a789f00270ba049b6c22a0d3b";

    const result = await getStarknetId(address);

    expect(result).toBe("0");
  });

  it("should return null if address has no ID", async () => {
    const address =
      "0x01d6abf4f5963082fc6c44d858ac2e89434406ed682fb63155d146c5d69c22d6";

    const result = await getStarknetId(address);

    expect(result).toBe(null);
  });
});
