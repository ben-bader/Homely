import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import useReportReasons from "@/app/ManageParametres/useReportReasons";
import useBoostPackages from "@/app/boosts/useBoostPackages";
import { Input } from "../../components/ui/input";
import { Button } from "../../components/ui/button";
import { ReportReason, BoostPackage } from "@/types/dashboard-types";
import { Card } from "../../components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "../../components/ui/tabs";
import { useTranslations } from "next-intl";

const ManageParameters = () => {
  const t = useTranslations('parameters');
  const { reasons, loading: reasonsLoading, error: reasonsError, refetch: refetchReasons } = useReportReasons();
  const { packages, loading: packagesLoading, error: packagesError, addPackage, deletePackage } = useBoostPackages();

  const [newReason, setNewReason] = useState("");
  const [newPackage, setNewPackage] = useState({ name: "", description: "", durationDays: "", price: "" });
  const [featuredPropertiesLimit, setFeaturedPropertiesLimit] = useState("");
  const [savingPackage, setSavingPackage] = useState(false);
  const [savingLimit, setSavingLimit] = useState(false);

  useEffect(() => {
    const loadFeaturedLimit = async () => {
      try {
        const { data } = await api.get<number>("/featured-properties-setting");
        setFeaturedPropertiesLimit(data?.toString() || "");
      } catch (error) { console.error("Failed to load featured properties limit", error); }
    };
    loadFeaturedLimit();
  }, []);

  const addReportReason = async () => {
    if (!newReason.trim()) return;
    try { await api.post<ReportReason>("/report-reasons", { reason: newReason }); setNewReason(""); refetchReasons(); }
    catch (error) { console.error("Failed to add report reason", error); }
  };

  const deleteReportReason = async (id: string) => {
    try { await api.delete(`/report-reasons/${id}`); refetchReasons(); }
    catch (error) { console.error("Failed to delete report reason", error); }
  };

  const handleAddPackage = async () => {
    if (!newPackage.name || !newPackage.price || !newPackage.durationDays) { alert(t('packages.validationError')); return; }
    setSavingPackage(true);
    try {
      await addPackage({ name: newPackage.name, description: newPackage.description, durationDays: parseInt(newPackage.durationDays), price: parseFloat(newPackage.price) });
      setNewPackage({ name: "", description: "", durationDays: "", price: "" });
    } catch (error) { console.error("Failed to add package", error); alert(t('packages.addError')); }
    finally { setSavingPackage(false); }
  };

  const handleDeletePackage = async (packageId: number) => {
    if (!confirm(t('packages.deleteConfirm'))) return;
    try { await deletePackage(packageId); }
    catch (error) { console.error("Failed to delete package", error); alert(t('packages.deleteError')); }
  };

  const handleUpdateFeaturedLimit = async () => {
    if (!featuredPropertiesLimit) { alert(t('featured.validationError')); return; }
    setSavingLimit(true);
    try {
      await api.post("/featured-properties-setting", null, { params: { count: parseInt(featuredPropertiesLimit) } });
      alert(t('featured.successMessage'));
    } catch (error) { console.error("Failed to update featured properties limit", error); alert(t('featured.errorMessage')); }
    finally { setSavingLimit(false); }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">{t('title')}</h1>
      <Tabs defaultValue="reasons" className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="reasons">{t('tabs.reasons')}</TabsTrigger>
          <TabsTrigger value="packages">{t('tabs.packages')}</TabsTrigger>
          <TabsTrigger value="featured">{t('tabs.featured')}</TabsTrigger>
        </TabsList>

        <TabsContent value="reasons" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">{t('reasons.title')}</h2>
            {reasonsLoading ? <div className="p-4 text-center">{t('reasons.loading')}</div>
              : reasonsError ? <div className="p-4 text-center text-red-500">{t('reasons.errorPrefix')}{reasonsError}</div>
              : <>
                <div className="flex gap-4 mb-4">
                  <Input type="text" value={newReason} onChange={(e) => setNewReason(e.target.value)} placeholder={t('reasons.placeholder')} />
                  <Button onClick={addReportReason} className="bg-emerald-500 text-white hover:bg-emerald-600">{t('reasons.addButton')}</Button>
                </div>
                <div className="space-y-2">
                  {reasons.map((reason) => (
                    <div key={reason.id} className="flex gap-4 justify-between items-center rounded-md border border-muted p-3 bg-muted/50">
                      <span>{reason.reason}</span>
                      <Button variant="destructive" size="sm" onClick={() => deleteReportReason(reason.id)}>{t('reasons.deleteButton')}</Button>
                    </div>
                  ))}
                </div>
              </>}
          </div>
        </TabsContent>

        <TabsContent value="packages" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">{t('packages.title')}</h2>
            {packagesLoading ? <div className="p-4 text-center">{t('packages.loading')}</div>
              : packagesError ? <div className="p-4 text-center text-red-500">{t('reasons.errorPrefix')}{packagesError}</div>
              : <>
                <Card className="p-4 mb-4 space-y-3 bg-muted/50">
                  <h3 className="font-semibold text-sm">{t('packages.addTitle')}</h3>
                  <Input placeholder={t('packages.namePlaceholder')} value={newPackage.name} onChange={(e) => setNewPackage({ ...newPackage, name: e.target.value })} />
                  <Input placeholder={t('packages.descriptionPlaceholder')} value={newPackage.description} onChange={(e) => setNewPackage({ ...newPackage, description: e.target.value })} />
                  <div className="grid grid-cols-2 gap-3">
                    <Input placeholder={t('packages.durationPlaceholder')} type="number" value={newPackage.durationDays} onChange={(e) => setNewPackage({ ...newPackage, durationDays: e.target.value })} />
                    <Input placeholder={t('packages.pricePlaceholder')} type="number" step="0.01" value={newPackage.price} onChange={(e) => setNewPackage({ ...newPackage, price: e.target.value })} />
                  </div>
                  <Button onClick={handleAddPackage} disabled={savingPackage} className="w-full bg-emerald-500 text-white hover:bg-emerald-600">
                    {savingPackage ? t('packages.adding') : t('packages.addButton')}
                  </Button>
                </Card>
                <div className="space-y-2">
                  {packages.length === 0 ? <div className="p-4 text-center text-muted-foreground">{t('packages.noPackages')}</div>
                    : packages.map((pkg) => (
                      <Card key={pkg.id} className="p-4">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <h3 className="font-semibold">{pkg.name}</h3>
                            {pkg.description && <p className="text-sm text-muted-foreground">{pkg.description}</p>}
                            <div className="flex gap-4 mt-2 text-sm">
                              <span>${pkg.price.toFixed(2)}</span>
                              <span>{pkg.durationDays} {t('packages.days')}</span>
                            </div>
                          </div>
                          <Button variant="destructive" size="sm" onClick={() => handleDeletePackage(pkg.id)}>{t('packages.deleteButton')}</Button>
                        </div>
                      </Card>
                    ))}
                </div>
              </>}
          </div>
        </TabsContent>

        <TabsContent value="featured" className="space-y-4">
          <div className="mt-4">
            <h2 className="text-lg font-semibold mb-4">{t('featured.title')}</h2>
            <Card className="p-6 flex item-center justify-center gap-4">
              <div className="flex gap-4 items-center justify-center">
                <label className="text-sm font-medium">{t('featured.label')}</label>
                <Input placeholder={t('featured.placeholder')} type="number" value={featuredPropertiesLimit} onChange={(e) => setFeaturedPropertiesLimit(e.target.value)} />
                <Button onClick={handleUpdateFeaturedLimit} disabled={savingLimit}>
                  {savingLimit ? t('featured.saving') : t('featured.saveButton')}
                </Button>
              </div>
              <p className="text-sm text-muted-foreground">{t('featured.description')}</p>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export default ManageParameters;