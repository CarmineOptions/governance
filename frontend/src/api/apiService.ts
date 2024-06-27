import axios from "axios";
import { BASE_API_URL } from "../constants/amm";

type CommentPayload = {
  address: string;
  text: string;
};

export const submitCommentApi = async (payload: CommentPayload) => {
  const { data } = await axios.post(`${BASE_API_URL}/submit`, payload);
  return data;
};



export const fetchIpfsFile = async (file: string) => {
  try {
    const response = await axios.get(`https://ipfs.io/ipfs/${file}`);
    if (response.status === 200) {
      return response.data;
    } else {
      throw new Error(`Failed to fetch IPFS file with status: ${response.status}`);
    }
  } catch (error) {
    console.error('Error fetching IPFS file:', error);
    throw error; // Re-throw the error for further handling if necessary
  }
};
