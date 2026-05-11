import * as React from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogTrigger, DialogClose } from "@/components/ui/dialog";
import { Property, Apartment, House, Commercial, Land, Studio, Villa } from "@/types/dashboard-types";

interface PropertyDetailsProps {
  property: Property | null;
  open: boolean;
  onClose: () => void;
}

export function PropertyDetails({ property, open, onClose }: PropertyDetailsProps) {
  if (!property) return null;

  const renderSubtype = () => {
    switch (property.propertyType) {
      case "APARTMENT":
        const apt = property.apartment as Apartment;
        return (
          <ul>
            <li>Bedrooms: {apt?.bedrooms}</li>
            <li>Bathrooms: {apt?.bathrooms}</li>
            <li>Floor: {apt?.floor}</li>
            <li>Elevator: {apt?.hasElevator ? "Yes" : "No"}</li>
          </ul>
        );
      case "HOUSE":
        const house = property.house as House;
        return (
          <ul>
            <li>Bedrooms: {house?.bedrooms}</li>
            <li>Bathrooms: {house?.bathrooms}</li>
            <li>Garage: {house?.hasGarage ? "Yes" : "No"}</li>
            <li>Land Area: {house?.landAreaSqm} sqm</li>
          </ul>
        );
      case "COMMERCIAL":
        const comm = property.commercial as Commercial;
        return (
          <ul>
            <li>Area: {comm?.areaSqm} sqm</li>
            <li>Business Type: {comm?.businessType}</li>
          </ul>
        );
      case "LAND":
        const land = property.land as Land;
        return (
          <ul>
            <li>Area: {land?.areaSqm} sqm</li>
            <li>Constructible: {land?.constructible ? "Yes" : "No"}</li>
          </ul>
        );
      case "STUDIO":
        const studio = property.studio as Studio;
        return <p>Furnished: {studio?.furnished ? "Yes" : "No"}</p>;
      case "VILLA":
        const villa = property.villa as Villa;
        return (
          <ul>
            <li>Bedrooms: {villa?.bedrooms}</li>
            <li>Bathrooms: {villa?.bathrooms}</li>
            <li>Land Area: {villa?.landAreaSqm} sqm</li>
            <li>Pool: {villa?.hasPool ? "Yes" : "No"}</li>
          </ul>
        );
      default:
        return null;
    }
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{property.title}</DialogTitle>
        </DialogHeader>
        <DialogDescription>
          <p>Address: {property.address}</p>
          <p>Price: {property.price}</p>
          <p>Status: {property.status}</p>
          {renderSubtype()}
        </DialogDescription>
        <DialogClose>Close</DialogClose>
      </DialogContent>
    </Dialog>
  );
}
