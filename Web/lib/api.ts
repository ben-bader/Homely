import axios from "axios";

export const api = axios.create({
  baseURL: "http://localhost:8082/api",
  //withCredentials: true, // optional but fine
  headers: {
    "ngrok-skip-browser-warning": "true", // 👈 this bypasses the ngrok interstitial
  },
});


api.interceptors.response.use((response) => {
  console.log(response.config.url, response.data);
  return response;
});
api.interceptors.request.use((config) => {
  const jwt = localStorage.getItem("jwt");

  if (jwt) {
    config.headers.Authorization = `Bearer ${jwt}`;
  }

  return config;
});
