import { Router } from "express";
import { submitProposal } from "./ipfs";

const router = Router();

router.post("/submit", submitProposal);

export default router;
