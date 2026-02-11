import api from "./api";

export const userService = {
  getAllUsers: async () => {
    const response = await api.get("/users");
    return response.data;
  },

  getProfile: async (id: string) => {
    const response = await api.get(`/users/${id}`);
    return response.data;
  }
};