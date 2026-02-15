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
}

export enum PurchaseStatus {
  PENDING = "PENDING",
  COMPLETED = "COMPLETED",
  CANCELLED = "CANCELLED",
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
  status: string
  address: string
  latitude: number | null
  longitude: number | null
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
