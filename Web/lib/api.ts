import axios from "axios";

export const api = axios.create({
  baseURL: "http://localhost:8082/api",
  withCredentials: true, // optional but fine
});

api.interceptors.request.use((config) => {
  const jwt = localStorage.getItem("jwt");

  if (jwt) {
    config.headers.Authorization = `Bearer ${jwt}`;
  }

  return config;
});
