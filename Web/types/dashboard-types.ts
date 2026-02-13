// types.ts

export enum ReportStatus {
  PENDING = "PENDING",
  IN_PROGRESS = "IN_PROGRESS",
  RESOLVED = "RESOLVED",
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

// Report  with nested references
export interface Report {
  id: string
  reporterId: string
  reportedUserId: string | null
  reportedPropertyId: string | null
  reason: string
  status: ReportStatus
  reviewedByAdminId: string | null

  // Nested objects fetched from backend
  reporter?: User
  reportedUser?: User
  reportedProperty?: Property
  reviewedByAdmin?: User
}
