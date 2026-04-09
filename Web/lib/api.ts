import axios from "axios";

export const api = axios.create({
  baseURL: "https://unparrying-christene-reductively.ngrok-free.dev/api",
  withCredentials: true,
  headers: {
    "ngrok-skip-browser-warning": "true", 
  },
});


api.interceptors.request.use((config) => {
  const jwt = localStorage.getItem("jwt");

  if (jwt) {
    config.headers.Authorization = `Bearer ${jwt}`;
  }
  
  console.log("📤 Sending request to:", config.baseURL + config.url);
  return config;
}, (error) => {
  console.error("❌ Request error:", error);
  return Promise.reject(error);
});

api.interceptors.response.use((response) => {
  console.log("📥 Response from:", response.config.url, response.data);
  return response;
}, (error) => {
  console.error("❌ Response error:", error.response?.status, error.response?.data || error.message);
  return Promise.reject(error);
});
