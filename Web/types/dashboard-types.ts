// types.ts

export enum ReportStatus {
  OPEN = "OPEN",
  REVIEWED = "REVIEWED",
  RESOLVED = "RESOLVED",
  DISMISSED = "DISMISSED",
}

export enum RoleType {
  ADMIN = "ADMIN",
  USER = "USER",
}

export enum ListingType {
  SALE = "SALE",
  RENT = "RENT",
}

export enum PropertyType {
  APARTMENT = "APARTMENT",
  HOUSE = "HOUSE",
  LAND = "LAND",
  COMMERCIAL = "COMMERCIAL",
  STUDIO = "STUDIO",
  VILLA = "VILLA",
}

export enum PurchaseStatus {
  PENDING = "PENDING",
  COMPLETED = "COMPLETED",
  CANCELLED = "CANCELLED",
}
export enum PropertyStatus {
  AVAILABLE = "AVAILABLE",
    SUSPENDED = "SUSPENDED",
    DRAFT = "DRAFT"
}
// User DTO
export interface User {
  id: string
  email: string
  name: string
  phone: string
  role: RoleType
  isActive: boolean
}

// Property 
export interface Property {
  id: string
  sellerId: string
  title: string
  description: string
  price: number
  currency: string
  listingType: ListingType
  propertyType: PropertyType
  status:PropertyStatus
  address: string
  latitude: number | null
  longitude: number | null
   apartment?: Apartment;
  house?: House;
  commercial?: Commercial;
  land?: Land;
  studio?: Studio;
  villa?: Villa;
}

// Report (backend returns names in DTO)
export interface Report {
  id: string
  reporterId: string
  reporterName?: string | null
  reporterEmail?: string | null
  reportedUserId: string | null
  reportedUserName?: string | null
  reportedUserEmail?: string | null
  reportedPropertyId: string | null
  reportedPropertyTitle?: string | null
  reason: string
  status: ReportStatus
  reviewedByAdminId: string | null
  reviewedByAdminName?: string | null
  reviewedByAdminEmail?: string | null
  createdAt?: string
  updatedAt?: string
}

// Audit log entry for admin actions
export interface AuditLog {
  id: string
  adminId: string
  adminEmail?: string | null
  adminName?: string | null
  action: string
  details: string | null
  createdAt?: string
  updatedAt?: string
}
export enum VisitStatus {
    PENDING="PENDING",
    APPROVED="APPROVED",
    REJECTED="REJECTED",
    COMPLETED="COMPLETED"

}

export type VisitRequest = {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  propertyId: string;
  propertyTitle: string;
  requestedDate: string; // ISO string
  status: VisitStatus;
};
export type BoostStatus = "PENDING" | "COMPLETED" | "FAILED"

export type Boost = {
  id: string
  sellerId: string
  propertyId: string
  propertyTitle: string
  userName: string
  userEmail: string
  amount: number
  currency?: string
  durationDays: number
  status: BoostStatus
}
export interface Apartment {
  propertyId: string;
  bedrooms: number;
  bathrooms: number;
  floor: number;
  hasElevator: boolean;
}

export interface House {
  propertyId: string;
  bedrooms: number;
  bathrooms: number;
  hasGarage: boolean;
  landAreaSqm: number;
}

export interface Commercial {
  propertyId: string;
  areaSqm: number;
  businessType: string;
}

export interface Land {
  propertyId: string;
  areaSqm: number;
  constructible: boolean;
}

export interface Studio {
  propertyId: string;
  furnished: boolean;
}

export interface Villa {
  propertyId: string;
  bedrooms: number;
  bathrooms: number;
  landAreaSqm: number;
  hasPool: boolean;
}