import { useEffect, useState } from "react";import { api } from "../../lib/api";
import { ReportReason } from "@/types/dashboard-types";

const useReportReasons = () => {
  const [reasons, setReasons] = useState<ReportReason[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchReasons = async () => {
    try {
      setLoading(true);
      const response = await api.get<ReportReason[]>("/report-reasons");
      setReasons(response.data);
    } catch (e) {
      setError("Failed to load reasons");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReasons(); }, []);

  return { reasons, loading, error, refetch: fetchReasons };
};
export default useReportReasons;
