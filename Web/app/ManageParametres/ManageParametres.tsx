import { useState, useEffect, useMemo } from "react";
import { api } from "@/lib/api";
import useReportReasons from "@/app/ManageParametres/useReportReasons";
import useBoostPackages from "@/app/boosts/useBoostPackages";
import { Input } from "../../components/ui/input";
import { Button } from "../../components/ui/button";
import { ReportReason, BoostPackage } from "@/types/dashboard-types";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../components/ui/tabs";
import { PaginationFooter } from "@/components/ui/pagination";
import { useTranslations } from "next-intl";
import { Settings, Flag, Rocket, Star, Trash2, Plus } from "lucide-react";

const ITEMS_PER_PAGE = 10;

const ManageParameters = () => {
  const t = useTranslations("parameters");
  const {
    reasons,
    loading: reasonsLoading,
    error: reasonsError,
    refetch: refetchReasons,
  } = useReportReasons();
  const {
    packages,
    loading: packagesLoading,
    error: packagesError,
    addPackage,
    deletePackage,
  } = useBoostPackages();

  const [newReason, setNewReason] = useState("");
  const [newPackage, setNewPackage] = useState({
    name: "",
    description: "",
    durationDays: "",
    price: "",
  });
  const [featuredPropertiesLimit, setFeaturedPropertiesLimit] = useState("");
  const [savingPackage, setSavingPackage] = useState(false);
  const [savingLimit, setSavingLimit] = useState(false);

  // Pagination state — one per tab
  const [reasonsPage, setReasonsPage] = useState(0);
  const [packagesPage, setPackagesPage] = useState(0);

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

  // Reset pages when data changes
  useEffect(() => {
    setReasonsPage(0);
  }, [reasons]);

  useEffect(() => {
    setPackagesPage(0);
  }, [packages]);

  /* ---- Pagination calculations ---- */
  const reasonsTotalPages = Math.ceil(reasons.length / ITEMS_PER_PAGE);
  const paginatedReasons = useMemo(
    () =>
      reasons.slice(
        reasonsPage * ITEMS_PER_PAGE,
        (reasonsPage + 1) * ITEMS_PER_PAGE
      ),
    [reasons, reasonsPage]
  );

  const packagesTotalPages = Math.ceil(packages.length / ITEMS_PER_PAGE);
  const paginatedPackages = useMemo(
    () =>
      packages.slice(
        packagesPage * ITEMS_PER_PAGE,
        (packagesPage + 1) * ITEMS_PER_PAGE
      ),
    [packages, packagesPage]
  );

  /* ---- Handlers ---- */
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

  const deleteReportReason = async (id: string) => {
    try {
      await api.delete(`/report-reasons/${id}`);
      refetchReasons();
    } catch (error) {
      console.error("Failed to delete report reason", error);
    }
  };

  const handleAddPackage = async () => {
    if (!newPackage.name || !newPackage.price || !newPackage.durationDays) {
      alert(t("packages.validationError"));
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
      alert(t("packages.addError"));
    } finally {
      setSavingPackage(false);
    }
  };

  const handleDeletePackage = async (packageId: number) => {
    if (!confirm(t("packages.deleteConfirm"))) return;
    try {
      await deletePackage(packageId);
    } catch (error) {
      console.error("Failed to delete package", error);
      alert(t("packages.deleteError"));
    }
  };

  const handleUpdateFeaturedLimit = async () => {
    if (!featuredPropertiesLimit) {
      alert(t("featured.validationError"));
      return;
    }
    setSavingLimit(true);
    try {
      await api.post("/featured-properties-setting", null, {
        params: { count: parseInt(featuredPropertiesLimit) },
      });
      alert(t("featured.successMessage"));
    } catch (error) {
      console.error("Failed to update featured properties limit", error);
      alert(t("featured.errorMessage"));
    } finally {
      setSavingLimit(false);
    }
  };

  return (
    <div className="px-6 py-6 max-w-4xl mx-auto space-y-6 animate-fade-up">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-lg bg-slate-100 text-slate-600 flex items-center justify-center">
          <Settings className="w-5 h-5" />
        </div>
        <div>
          <h1 className="text-2xl font-semibold text-foreground">
            {t("title")}
          </h1>
          <p className="text-sm text-muted-foreground">
            Configure platform settings and parameters
          </p>
        </div>
      </div>

      <Tabs defaultValue="reasons" className="w-full">
        <TabsList className="bg-white p-1 shadow-sm rounded-lg h-auto">
          <TabsTrigger
            value="reasons"
            className="rounded-md text-xs font-medium data-[state=active]:text-white data-[state=active]:bg-primary data-[state=active]:shadow-sm px-4 py-2 gap-1.5"
          >
            <Flag className="w-3.5 h-3.5" />
            {t("tabs.reasons")}
          </TabsTrigger>
          <TabsTrigger
            value="packages"
            className="rounded-md text-xs font-medium data-[state=active]:text-white data-[state=active]:bg-primary data-[state=active]:shadow-sm px-4 py-2 gap-1.5"
          >
            <Rocket className="w-3.5 h-3.5" />
            {t("tabs.packages")}
          </TabsTrigger>
          <TabsTrigger
            value="featured"
            className="rounded-md text-xs font-medium data-[state=active]:text-white data-[state=active]:bg-primary data-[state=active]:shadow-sm px-4 py-2 gap-1.5"
          >
            <Star className="w-3.5 h-3.5" />
            {t("tabs.featured")}
          </TabsTrigger>
        </TabsList>

        {/* ── REPORT REASONS ── */}
        <TabsContent value="reasons" className="mt-6 space-y-4">
          <div className="bg-card border rounded-xl p-6 space-y-4">
            <h2 className="text-base font-semibold">{t("reasons.title")}</h2>

            {reasonsLoading ? (
              <div className="py-8 text-center text-sm text-muted-foreground">
                {t("reasons.loading")}
              </div>
            ) : reasonsError ? (
              <div className="py-8 text-center text-sm text-red-500">
                {t("reasons.errorPrefix")}
                {reasonsError}
              </div>
            ) : (
              <>
                {/* Add form */}
                <div className="flex gap-3">
                  <Input
                    type="text"
                    value={newReason}
                    onChange={(e) => setNewReason(e.target.value)}
                    placeholder={t("reasons.placeholder")}
                    className="flex-1"
                  />
                  <Button onClick={addReportReason} size="sm" className="gap-1.5">
                    <Plus className="w-3.5 h-3.5" />
                    {t("reasons.addButton")}
                  </Button>
                </div>

                {/* List */}
                <div className="space-y-2">
                  {paginatedReasons.length === 0 ? (
                    <div className="py-8 text-center text-sm text-muted-foreground">
                      No report reasons found.
                    </div>
                  ) : (
                    paginatedReasons.map((reason) => (
                      <div
                        key={reason.id}
                        className="flex items-center justify-between rounded-lg border p-3 hover:bg-muted/30 transition-colors"
                      >
                        <span className="text-sm">{reason.reason}</span>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => deleteReportReason(reason.id)}
                          className="text-muted-foreground hover:text-red-500 h-8 w-8 p-0"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    ))
                  )}
                </div>

                {/* Pagination */}
                <div className="flex justify-between items-center pt-2">
                  <span className="text-xs text-muted-foreground">
                    {reasons.length} {t("tabs.reasons")}
                  </span>
                  <PaginationFooter
                    pageInfo={`Page ${reasonsPage + 1} of ${Math.max(reasonsTotalPages, 1)}`}
                    onPrevious={() =>
                      setReasonsPage((p) => Math.max(0, p - 1))
                    }
                    onNext={() =>
                      setReasonsPage((p) =>
                        Math.min(reasonsTotalPages - 1, p + 1)
                      )
                    }
                    canPrevious={reasonsPage > 0}
                    canNext={reasonsPage < reasonsTotalPages - 1}
                  />
                </div>
              </>
            )}
          </div>
        </TabsContent>

        {/* ── BOOST PACKAGES ── */}
        <TabsContent value="packages" className="mt-6 space-y-4">
          <div className="bg-card border rounded-xl p-6 space-y-4">
            <h2 className="text-base font-semibold">{t("packages.title")}</h2>

            {packagesLoading ? (
              <div className="py-8 text-center text-sm text-muted-foreground">
                {t("packages.loading")}
              </div>
            ) : packagesError ? (
              <div className="py-8 text-center text-sm text-red-500">
                {t("reasons.errorPrefix")}
                {packagesError}
              </div>
            ) : (
              <>
                {/* Add form */}
                <div className="border rounded-lg p-4 bg-muted/20 space-y-3">
                  <h3 className="font-medium text-sm">{t("packages.addTitle")}</h3>
                  <Input
                    placeholder={t("packages.namePlaceholder")}
                    value={newPackage.name}
                    onChange={(e) =>
                      setNewPackage({ ...newPackage, name: e.target.value })
                    }
                  />
                  <Input
                    placeholder={t("packages.descriptionPlaceholder")}
                    value={newPackage.description}
                    onChange={(e) =>
                      setNewPackage({
                        ...newPackage,
                        description: e.target.value,
                      })
                    }
                  />
                  <div className="grid grid-cols-2 gap-3">
                    <Input
                      placeholder={t("packages.durationPlaceholder")}
                      type="number"
                      value={newPackage.durationDays}
                      onChange={(e) =>
                        setNewPackage({
                          ...newPackage,
                          durationDays: e.target.value,
                        })
                      }
                    />
                    <Input
                      placeholder={t("packages.pricePlaceholder")}
                      type="number"
                      step="0.01"
                      value={newPackage.price}
                      onChange={(e) =>
                        setNewPackage({ ...newPackage, price: e.target.value })
                      }
                    />
                  </div>
                  <Button
                    onClick={handleAddPackage}
                    disabled={savingPackage}
                    className="w-full"
                  >
                    {savingPackage ? t("packages.adding") : t("packages.addButton")}
                  </Button>
                </div>

                {/* List */}
                <div className="space-y-3">
                  {packages.length === 0 ? (
                    <div className="py-8 text-center text-sm text-muted-foreground">
                      {t("packages.noPackages")}
                    </div>
                  ) : paginatedPackages.length === 0 ? (
                    <div className="py-8 text-center text-sm text-muted-foreground">
                      {t("packages.noPackages")}
                    </div>
                  ) : (
                    paginatedPackages.map((pkg) => (
                      <div
                        key={pkg.id}
                        className="border rounded-lg p-4 hover:bg-muted/20 transition-colors"
                      >
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <h3 className="font-semibold text-sm">{pkg.name}</h3>
                            {pkg.description && (
                              <p className="text-xs text-muted-foreground mt-0.5">
                                {pkg.description}
                              </p>
                            )}
                            <div className="flex gap-4 mt-2">
                              <span className="text-xs font-medium text-foreground">
                                ${pkg.price.toFixed(2)}
                              </span>
                              <span className="text-xs text-muted-foreground">
                                {pkg.durationDays} {t("packages.days")}
                              </span>
                            </div>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleDeletePackage(pkg.id)}
                            className="text-muted-foreground hover:text-red-500 h-8 w-8 p-0"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </div>
                    ))
                  )}
                </div>

                {/* Pagination */}
                {packages.length > 0 && (
                  <div className="flex justify-between items-center pt-2">
                    <span className="text-xs text-muted-foreground">
                      {packages.length} {t("tabs.packages")}
                    </span>
                    <PaginationFooter
                      pageInfo={`Page ${packagesPage + 1} of ${Math.max(packagesTotalPages, 1)}`}
                      onPrevious={() =>
                        setPackagesPage((p) => Math.max(0, p - 1))
                      }
                      onNext={() =>
                        setPackagesPage((p) =>
                          Math.min(packagesTotalPages - 1, p + 1)
                        )
                      }
                      canPrevious={packagesPage > 0}
                      canNext={packagesPage < packagesTotalPages - 1}
                    />
                  </div>
                )}
              </>
            )}
          </div>
        </TabsContent>

        {/* ── FEATURED PROPERTIES ── */}
        <TabsContent value="featured" className="mt-6">
          <div className="bg-card border rounded-xl p-6">
            <h2 className="text-base font-semibold mb-4">
              {t("featured.title")}
            </h2>
            <div className="max-w-md space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium">
                  {t("featured.label")}
                </label>
                <Input
                  placeholder={t("featured.placeholder")}
                  type="number"
                  value={featuredPropertiesLimit}
                  onChange={(e) => setFeaturedPropertiesLimit(e.target.value)}
                />
                <p className="text-xs text-muted-foreground">
                  {t("featured.description")}
                </p>
              </div>
              <Button
                onClick={handleUpdateFeaturedLimit}
                disabled={savingLimit}
              >
                {savingLimit ? t("featured.saving") : t("featured.saveButton")}
              </Button>
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default ManageParameters;