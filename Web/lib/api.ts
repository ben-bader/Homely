import axios from "axios";

export const api = axios.create({
  baseURL: "https://unparrying-christene-reductively.ngrok-free.dev/api",
  //withCredentials: true, // optional but fine
  headers: {
    "ngrok-skip-browser-warning": "true", 
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
