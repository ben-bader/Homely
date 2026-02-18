import axios from "axios";

export const api = axios.create({
  baseURL: "https://zcvxc076-8082.uks1.devtunnels.ms/api",
  withCredentials: true, // optional but fine
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("jwt");

  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  return config;
});
