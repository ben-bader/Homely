// SELLER UI IMPLEMENTATION GUIDE
// ================================
// This document outlines the complete seller UI implementation for the Homely app

## ✅ IMPLEMENTATION SUMMARY

### 1. SELLER NAVIGATION SYSTEM
Location: lib/features/property/screens/home_screen.dart

**Changes:**
- Modified HomeScreen to detect user role (SELLER vs CLIENT)
- Created two different navigation tab sets:
  - CLIENT: Explore, Tours, Inbox, Favorites, Profile
  - SELLER: Explore, Create (+), Inbox, My Listings, Profile
- Updated _BottomNav to display price indicator (round pill button) for Create action
- Plus button in the middle navigates to CreatePropertyScreen

### 2. SELLER LISTINGS MANAGEMENT
Location: lib/features/seller/screens/seller_listings_screen.dart

**Features:**
- Displays all properties listed by the seller
- Shows property image, title, price, location, and status
- Status badges with color coding (Active=Green, Inactive=Orange, Sold=Red, Rented=Blue)
- Empty state with CTA to create first property
- Refresh button to reload listings
- FAB to quickly add new property

**API Integration:**
- Endpoint: GET /api/properties/my-listed
- Uses seller-specific provider: sellerListingsProvider

### 3. PROPERTY CREATION FORM
Location: lib/features/seller/screens/create_property_screen.dart

**Features:**
- 3-step stepper form:
  STEP 1 - Basic Info:
    - Title, Location, Price
    - Listing Type (BUY/RENT)
    - Property Type (HOUSE/APARTMENT/VILLA/STUDIO/COMMERCIAL/LAND)
    - Description
  
  STEP 2 - Details:
    - Bedrooms, Bathrooms
    - Floor (for apartments), Elevator
    - Area (sqm)
    - Status (ACTIVE/INACTIVE/SOLD/RENTED)
  
  STEP 3 - Media:
    - Multi-image picker
    - Image preview grid
    - Remove individual images
    - Upload progress indicator

**Form Validation:**
- Required fields: title, location, price > 0
- Form state management with setState
- Error handling and user feedback

**Data Flow:**
1. User fills all steps
2. On step 3 submit:
   - POST /api/properties → creates property, returns propertyId
   - For each selected image:
     - POST /api/media/upload (multipart) → uploads image file
   - Refreshes sellerListingsProvider
   - Navigates back to seller listings

### 4. MEDIA UPLOAD INTEGRATION
Location: lib/features/media/providers/media_providers.dart (existing)
Extended by: CreatePropertyScreen

**Backend Endpoints Used:**
- POST /api/media/upload
  Parameters:
    - propertyId (UUID)
    - file (MultipartFile)
    - displayOrder (int)
  Returns:
    - URL of uploaded image

**Implementation Details:**
- Images are picked using image_picker plugin
- Supports multiple image selection
- Each image gets a display order (0, 1, 2...)
- Images are uploaded using http.MultipartRequest
- Bearer token automatically included in headers
- 120-second timeout per upload
- Error handling with specific status codes (413 = file too large)

### 5. PROFILE SCREEN ENHANCEMENT
Location: lib/features/profile/screens/profile_screen.dart (updated)

**New Section Added:**
- "My Listings" section (only for sellers)
- Shows up to 3 most recent properties
- Each listing displays:
  - Property thumbnail (60x60)
  - Title (truncated)
  - Price (formatted)
  - Status badge with color
- Dividers between items
- Gracefully hidden if user is not a seller

### 6. PROVIDER STRUCTURE
Location: lib/features/seller/providers/seller_providers.dart

**Providers:**
- sellerListingsProvider: FutureProvider that fetches seller's properties
- refreshSellerListingsProvider: Trigger to invalidate and refresh listings

**Properties Repository Extension:**
- getSellerListings(): Calls GET /api/properties/my-listed

### 7. AUTHENTICATION
Location: lib/features/auth/services/auth_service.dart (extended)

**New Method:**
- getCurrentSession(): Returns AuthResponse with user data
- Used to determine user role and load appropriate UI

**Data Flow:**
- User logs in → role is stored in SharedPreferences
- HomeScreen checks role on init
- Different navigation shown based on role

## 📱 USER FLOWS

### For Sellers:

**Creating a Property:**
1. Tap "+" button in center of bottom nav
2. Fill in basic info (step 1)
3. Continue to fill details (step 2)
4. Select images (step 3)
5. Submit → API creates property + uploads images
6. Redirected to seller listings

**Managing Listings:**
1. Tap "Listings" in bottom nav (index 3)
2. View all properties in grid format
3. Tap property card to view details
4. Or use FAB to create new property

**Viewing from Profile:**
1. Tap "Profile" in bottom nav
2. Scroll down to "My Listings" section
3. See top 3 properties with thumbnails

## 🔧 TECHNICAL INTEGRATION

### Backend Endpoints Used:
✅ POST /api/properties (create)
✅ GET /api/properties/my-listed (seller listings)
✅ GET /api/properties/{id} (property detail)
✅ POST /api/media/upload (image upload)
✅ GET /api/media/{propertyId}/media (get property media)

### State Management:
- Provider/Riverpod for async state
- FutureProvider for data fetching
- StateProvider for navigation tab
- Automatic invalidation on property creation

### Error Handling:
- Try-catch blocks for API calls
- User-friendly error messages via SnackBar
- Graceful fallbacks (empty states, loading indicators)
- Form validation before submission

## 🎨 UI/UX HIGHLIGHTS

**Design Consistency:**
- Uses existing AppColors palette
- GoogleFonts (Outfit) for typography
- Card-based layout with shadows
- Border radius consistency (12-24px)
- Color-coded status badges

**Responsive:**
- Works on various screen sizes
- Bottom nav preserved across all screens
- Scrollable content for overflow
- Safe area handling

## 📝 NOTES

1. **Role Detection:** HomeScreen determines role on init. Make sure getCurrentSession() in AuthService properly retrieves role from SharedPreferences

2. **Media Upload:** Images are uploaded as videos to the API (using uploadVideo method). This is consistent with existing media handling in the app.

3. **MultipartRequest:** Images sent via HTTP multipart with:
   - Content-Type: video/mp4 (as per backend expectation)
   - Authorization header with Bearer token
   - 120-second timeout

4. **Profile Section:** Seller listings in profile are read-only. Full management done in "My Listings" tab.

5. **API Response:** Create property endpoint should return `propertyId` in response (check backend response format)

## 🚀 NEXT STEPS / ENHANCEMENTS

Potential future improvements:
- Property editing/updates
- Batch image upload
- Property analytics/stats
- Scheduling property removal
- Video upload support
- Property cloning
- Advanced property search for sellers
- Property performance metrics
