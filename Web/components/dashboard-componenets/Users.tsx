import React, { useEffect, useState } from "react";
import { api } from "@/lib/api";

type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
};

const Users = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const filteredUsers = users.filter((u) =>
    [u.name, u.email, u.role]
      .join(" ")
      .toLowerCase()
      .includes(search.toLowerCase())
  );

  const fetchUsers = async () => {
    try {
      const res = await api.get<User[]>("/admin/users");
      setUsers(res.data || []);
    } catch (err) {
      console.error("Failed to load users", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const toggleActive = async (user: User) => {
    try {
      if (user.active) {
        await api.put(`/admin/users/${user.id}/deactivate`);
      } else {
        await api.put(`/admin/users/${user.id}/activate`);
      }
      // refresh
      fetchUsers();
    } catch (err) {
      console.error("Failed to update user status", err);
    }
  };

  if (loading) return <div>Loading users…</div>;

  return (
    <div className="px-8">
      <h2 className="text-xl font-semibold mb-2">Users</h2>
      <input
        type="text"
        placeholder="Search users…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-4 py-2 text-sm text-neutral-900 backdrop-blur transition focus:bg-white focus:border-neutral-900 focus:outline-none"
      />
      <table className="w-full table-auto border-collapse">
        <thead>
          <tr>
            <th className="text-left p-2">Name</th>
            <th className="text-left p-2">Email</th>
            <th className="text-left p-2">Role</th>
            <th className="text-left p-2">Status</th>
            <th className="text-left p-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          {filteredUsers.map((u) => (
            <tr key={u.id} className="border-t">
              <td className="p-2">{u.name}</td>
              <td className="p-2">{u.email}</td>
              <td className="p-2">{u.role}</td>
              <td className="p-2">{u.active ? "ACTIVE" : "DEACTIVATED"}</td>
              <td className="p-2">
                <button
                  onClick={() => toggleActive(u)}
                  className="px-3 py-1 rounded bg-neutral-900 text-white"
                >
                  {u.active ? "Deactivate" : "Activate"}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Users;
