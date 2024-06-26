import request from "supertest";
import app from "../src/app";

describe("Submit proposal", () => {
  it("should return 400 if address is missing", async () => {
    const res = await request(app).post("/api/submit").send({
      text: "Proposal text",
      address: ""
    });

    expect(res.statusCode).toEqual(400);
    expect(res.body).toEqual({ error: "Missing text or address" });
  });

  it("should return 400 if text is missing", async () => {
    const res = await request(app).post("/api/submit").send({
      text: "",
      address:
        "0x01d6abf4f5963082fc6c44d858ac2e89434406ed682fb63155d146c5d69c22d6"
    });

    expect(res.statusCode).toEqual(400);
    expect(res.body).toEqual({ error: "Missing text or address" });
  });

  it("should return 400 if text exceeds maximum length", async () => {
    const res = await request(app)
      .post("/api/submit")
      .send({
        text: "a".repeat(10001),
        address:
          "0x01d6abf4f5963082fc6c44d858ac2e89434406ed682fb63155d146c5d69c22d6"
      });

    expect(res.statusCode).toEqual(400);
    expect(res.body).toEqual({
      error: "Text exceeds maximum length of 10000 characters"
    });
  });

  it("should return 400 if address is invalid", async () => {
    const res = await request(app).post("/api/submit").send({
      text: "Proposal text",
      address: "invalid_address"
    });

    expect(res.statusCode).toEqual(400);
    expect(res.body).toEqual({
      error: "Invalid address"
    });
  });

  it("should return IPFS hash if proposal for addresses with starknet ID", async () => {
    const res = await request(app).post("/api/submit").send({
      text: "Proposal text",
      address:
        "0x01d6abf4f5963082fc6c44d858ac2e89434406ed682fb63155d146c5d69c22d6"
    });

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("ipfs_hash");
  });

  it("should return IPFS hash if proposal for addresses with no starknet ID", async () => {
    const res = await request(app).post("/api/submit").send({
      text: "Proposal text",
      address:
        "0x01d6abf4f5963082fc6c44d858ac2e89434406ed682fb63155d146c5d69c22d6"
    });

    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty("ipfs_hash");
  });
});
