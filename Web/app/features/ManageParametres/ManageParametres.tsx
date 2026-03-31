import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import useReportReasons from "@/app/features/ManageParametres/useReportReasons";
import  useBoostPackages from "@/app/features/boosts/useBoostPackages";
import { Input } from "../../../components/ui/input";
import { Button } from "../../../components/ui/button";
import { ReportReason, BoostPackage } from "@/types/dashboard-types";
import { Card } from "../../../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../../components/ui/tabs";

const ManageParameters = () => {
  const { reasons, loading: reasonsLoading, error: reasonsError, refetch: refetchReasons } = useReportReasons();
  const { packages, loading: packagesLoading, error: packagesError, addPackage, deletePackage, refetch: refetchPackages } = useBoostPackages();
  
  const [newReason, setNewReason] = useState("");
  const [newPackage, setNewPackage] = useState({ name: "", description: "", durationDays: "", price: "" });
  const [featuredPropertiesLimit, setFeaturedPropertiesLimit] = useState("");
  const [savingPackage, setSavingPackage] = useState(false);
  const [savingLimit, setSavingLimit] = useState(false);

  // Load featured properties limit
  useEffect(() => {
    const loadFeaturedLimit = async () => {
      try {
        const { data } = await api.get<number>("/featured-properties-setting");
        setFeaturedPropertiesLimit(data?.toString() || "");
      } catch (error) {
        console.error("Failed to load featured properties limit", error);
      }
    };
    loadFeaturedLimit();
  }, []);

  // Handle adding report reason
  const addReportReason = async () => {
    if (!newReason.trim()) return;
    try {
      await api.post<ReportReason>("/report-reasons", { reason: newReason });
      setNewReason("");
      refetchReasons();
    } catch (error) {
      console.error("Failed to add report reason", error);
    }
  };

  // Handle deleting report reason
  const deleteReportReason = async (id: string) => {
    try {
      await api.delete(`/report-reasons/${id}`);
      refetchReasons();
    } catch (error) {
      console.error("Failed to delete report reason", error);
    }
  };

  // Handle adding boost package
  const handleAddPackage = async () => {
    if (!newPackage.name || !newPackage.price || !newPackage.durationDays) {
      alert("Please fill in all required fields");
      return;
    }
    setSavingPackage(true);
    try {
      await addPackage({
        name: newPackage.name,
        description: newPackage.description,
        durationDays: parseInt(newPackage.durationDays),
        price: parseFloat(newPackage.price),
      });
      setNewPackage({ name: "", description: "", durationDays: "", price: "" });
    } catch (error) {
      console.error("Failed to add package", error);
      alert("Failed to add package");
    } finally {
      setSavingPackage(false);
    }
  };

  // Handle deleting boost package
  const handleDeletePackage = async (packageId: number) => {
    if (!confirm("Are you sure you want to delete this package?")) return;
    try {
      await deletePackage(packageId);
    } catch (error) {
      console.error("Failed to delete package", error);
      alert("Failed to delete package");
    }
  };

  // Handle updating featured properties limit
  const handleUpdateFeaturedLimit = async () => {
    if (!featuredPropertiesLimit) {
      alert("Please enter a valid number");
      return;
    }
    setSavingLimit(true);
    try {
      await api.post("/featured-properties-setting", null, {
        params: { count: parseInt(featuredPropertiesLimit) }
      });
      alert("Featured properties limit updated successfully");
    } catch (error) {
      console.error("Failed to update featured properties limit", error);
      alert("Failed to update featured properties limit");
    } finally {
      setSavingLimit(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Manage Parameters</h1>
      
      <Tabs defaultValue="reasons" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="reasons">Report Reasons</TabsTrigger>
          <TabsTrigger value="packages">Boost Packages</TabsTrigger>
          <TabsTrigger value="featured">Featured Properties</TabsTrigger>
        </TabsList>

        {/* Report Reasons Tab */}
        <TabsContent value="reasons" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">Manage Report Reasons</h2>
            {reasonsLoading ? (
              <div className="p-4 text-center">Loading report reasons...</div>
            ) : reasonsError ? (
              <div className="p-4 text-center text-red-500">Error: {reasonsError}</div>
            ) : (
              <>
                <div className="flex gap-4 mb-4">
                  <Input
                    type="text"
                    value={newReason}
                    onChange={(e) => setNewReason(e.target.value)}
                    placeholder="Add new reason"
                  />
                  <Button
                    onClick={addReportReason}
                    className="bg-emerald-500 text-white hover:bg-emerald-600"
                  >
                    Add Reason
                  </Button>
                </div>
                <div className="space-y-2">
                  {reasons.map((reason) => (
                    <div key={reason.id} className="flex gap-4 justify-between items-center rounded-md border border-muted p-3 bg-muted/50">
                      <span>{reason.reason}</span>
                      <Button variant="destructive" size="sm" onClick={() => deleteReportReason(reason.id)}>
                        Delete
                      </Button>
                    </div>
                  ))}
                </div>
              </>
            )}
          </div>
        </TabsContent>

        {/* Boost Packages Tab */}
        <TabsContent value="packages" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">Manage Boost Packages</h2>
            {packagesLoading ? (
              <div className="p-4 text-center">Loading boost packages...</div>
            ) : packagesError ? (
              <div className="p-4 text-center text-red-500">Error: {packagesError}</div>
            ) : (
              <>
                <Card className="p-4 mb-4 space-y-3 bg-muted/50">
                  <h3 className="font-semibold text-sm">Add New Package</h3>
                  <Input
                    placeholder="Package Name (e.g., Basic Boost)"
                    value={newPackage.name}
                    onChange={(e) => setNewPackage({ ...newPackage, name: e.target.value })}
                  />
                  <Input
                    placeholder="Description (optional)"
                    value={newPackage.description}
                    onChange={(e) => setNewPackage({ ...newPackage, description: e.target.value })}
                  />
                  <div className="grid grid-cols-2 gap-3">
                    <Input
                      placeholder="Duration (days)"
                      type="number"
                      value={newPackage.durationDays}
                      onChange={(e) => setNewPackage({ ...newPackage, durationDays: e.target.value })}
                    />
                    <Input
                      placeholder="Price ($)"
                      type="number"
                      step="0.01"
                      value={newPackage.price}
                      onChange={(e) => setNewPackage({ ...newPackage, price: e.target.value })}
                    />
                  </div>
                  <Button
                    onClick={handleAddPackage}
                    disabled={savingPackage}
                    className="w-full bg-emerald-500 text-white hover:bg-emerald-600"
                  >
                    {savingPackage ? "Adding..." : "Add Package"}
                  </Button>
                </Card>

                <div className="space-y-2">
                  {packages.length === 0 ? (
                    <div className="p-4 text-center text-muted-foreground">No boost packages yet</div>
                  ) : (
                    packages.map((pkg) => (
                      <Card key={pkg.id} className="p-4">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <h3 className="font-semibold">{pkg.name}</h3>
                            {pkg.description && <p className="text-sm text-muted-foreground">{pkg.description}</p>}
                            <div className="flex gap-4 mt-2 text-sm">
                              <span>${pkg.price.toFixed(2)}</span>
                              <span>{pkg.durationDays} days</span>
                            </div>
                          </div>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => handleDeletePackage(pkg.id)}
                          >
                            Delete
                          </Button>
                        </div>
                      </Card>
                    ))
                  )}
                </div>
              </>
            )}
          </div>
        </TabsContent>

        {/* Featured Properties Tab */}
        <TabsContent value="featured" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">Featured Properties Count Limit</h2>
            <Card className="p-6 flex item-center justify-center gap-4">
              <div className="flex  gap-4 items-center justify-center">
                <label className="text-sm font-medium">Number of Featured Properties</label>
                <Input
                  placeholder="Enter number"
                  type="number"
                  value={featuredPropertiesLimit}
                  onChange={(e) => setFeaturedPropertiesLimit(e.target.value)}
                />
             
              <Button 
                onClick={handleUpdateFeaturedLimit} 
                disabled={savingLimit}
              >
                {savingLimit ? "Saving..." : "Save Limit"}
              </Button>
               </div>
              <p className="text-sm text-muted-foreground">
                This setting controls the maximum number of properties that can be featured at any time.
              </p>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default ManageParameters;