# 🚀 SELLER UI - QUICK REFERENCE GUIDE

## File Locations

| File | Purpose |
|------|---------|
| `lib/features/seller/screens/seller_listings_screen.dart` | Displays seller's properties |
| `lib/features/seller/screens/create_property_screen.dart` | 3-step property creation form |
| `lib/features/seller/providers/seller_providers.dart` | Riverpod providers for seller data |
| `lib/features/property/screens/home_screen.dart` | Role-based navigation (MODIFIED) |
| `lib/features/property/repositories/property_repository.dart` | API methods (MODIFIED) |
| `lib/features/profile/screens/profile_screen.dart` | Profile + seller listings (MODIFIED) |
| `lib/features/auth/services/auth_service.dart` | Auth methods (MODIFIED) |

## Common Tasks

### Task: Add Seller Features to New Role
```dart
// In home_screen.dart
if (_userRole == 'SELLER') {
  // Use _buildSellerTabs()
  // Show seller-specific navigation
}
```

### Task: Fetch Seller Listings
```dart
// In any ConsumerWidget
final listingsAsync = ref.watch(sellerListingsProvider);

listingsAsync.when(
  data: (listings) => ListingsList(properties: listings),
  loading: () => LoadingWidget(),
  error: (err, _) => ErrorWidget(error: err),
);
```

### Task: Create Property
```dart
// In create_property_screen.dart
final propertyResponse = await ApiClient.post('/api/properties', 
  body: {
    'title': title,
    'location': location,
    'price': price,
    // ... other fields
  }
);
final propertyId = propertyResponse['id'];
```

### Task: Upload Image
```dart
final videoUploadNotifier = ref.read(
  propertyMediaProvider(propertyId).notifier
);
await videoUploadNotifier.uploadVideo(
  file: imageFile,
  displayOrder: 0,
);
```

### Task: Refresh Seller Listings
```dart
ref.invalidate(sellerListingsProvider);
// or
ref.read(sellerListingsProvider.notifier).refresh();
```

## UI Components Reference

### SellerListingsScreen Components
- `_ListingCard` - Individual property card
- `_EmptyState` - No properties message
- `_ErrorView` - Error display

### CreatePropertyScreen Components
- `_buildBasicInfoStep()` - First step form
- `_buildDetailsStep()` - Second step form
- `_buildMediaStep()` - Image upload step
- `_buildTextField()` - Reusable text field
- `_buildDropdown()` - Property type/status selector
- `_buildCheckbox()` - Boolean fields

### Profile Components
- `_SellerListingsSection` - Shows seller's top 3 properties
- Returns empty if user is not seller

## Navigation Patterns

### Navigate to Create Property
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const CreatePropertyScreen()),
);
```

### Navigate to Property Details
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => PropertyDetailScreen(propertyId: propertyId),
  ),
);
```

### Navigate Back
```dart
Navigator.pop(context); // With optional result
```

## API Integration Checklist

Before testing, ensure backend has:

- [ ] `POST /api/properties` endpoint
- [ ] `GET /api/properties/my-listed` endpoint  
- [ ] `POST /api/media/upload` endpoint
- [ ] `GET /api/media/{propertyId}/media` endpoint
- [ ] User role stored in JWT claims
- [ ] Proper authentication guards

## Error Codes Handled

| Code | Meaning | Handled In |
|------|---------|-----------|
| 400 | Invalid data | `media_repository.dart` |
| 401 | Unauthorized | `media_repository.dart` |
| 403 | Forbidden | `media_repository.dart` |
| 413 | File too large | `media_repository.dart` |
| 500 | Server error | Try-catch blocks |

## Form Validation Rules

| Field | Rule |
|-------|------|
| Title | Required, non-empty |
| Location | Required, non-empty |
| Price | Required, > 0 |
| Images | At least 0 (optional but recommended) |
| All other fields | Can be empty (defaults applied) |

## Status Values

Used in property creation/status update:

```dart
enum PropertyStatus {
  'ACTIVE',    // Actively listed
  'INACTIVE',  // Hidden from listings
  'SOLD',      // Transaction complete
  'RENTED'     // Rented out
}
```

## Listing Type Values

```dart
enum ListingType {
  'BUY',       // For sale
  'RENT'       // For rent
}
```

## Property Type Values

```dart
enum PropertyType {
  'HOUSE',
  'APARTMENT',
  'VILLA',
  'STUDIO',
  'COMMERCIAL',
  'LAND'
}
```

## Debugging Tips

### Check User Role
```dart
final session = await AuthService().getCurrentSession();
print('User role: ${session?.role}'); // Should print 'SELLER'
```

### Check API Response
```dart
try {
  final response = await ApiClient.get('/api/properties/my-listed');
  print('Response: $response');
} catch(e) {
  print('Error: $e');
}
```

### Check Navigation Index
```dart
final idx = ref.watch(navIndexProvider);
print('Current tab: $idx'); // 0-4
```

### Check Image Upload
```dart
// Add logs in create_property_screen.dart
print('Uploading image $i of ${_selectedImages.length}');
print('Upload status: $_isUploading');
```

## Performance Tips

1. **Limit images:** Consider capping at 10 images per property
2. **Compress images:** Using flutter_image_compress (already integrated)
3. **Cache images:** CachedNetworkImage used automatically
4. **Lazy load:** Only load seller listings when tab accessed
5. **Invalidate sparingly:** Only invalidate when necessary

## Testing Commands

### Test API Endpoints
```bash
# In terminal, test endpoint:
curl -X GET http://localhost:8080/api/properties/my-listed \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Test Image Upload
```bash
# Using multipart form-data
curl -X POST http://localhost:8080/api/media/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "propertyId=UUID" \
  -F "displayOrder=0" \
  -F "file=@/path/to/image.jpg"
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Properties not showing | Check: `getCurrentSession()` returns 'SELLER' role |
| Images not uploading | Check: File size < limit, Bearer token valid |
| Navigation not switching | Check: Role is loaded before building tabs |
| Form won't submit | Check: All required fields filled (title, location, price) |
| API 401 errors | Check: Token in SharedPreferences, not expired |

## Next Enhancement Ideas

- [ ] Property editing
- [ ] Batch image operations
- [ ] Property analytics dashboard
- [ ] Scheduled property removal
- [ ] Video upload support
- [ ] Property templates/cloning
- [ ] Auto-pricing suggestions
- [ ] Tenant management
- [ ] Maintenance requests
- [ ] Income tracking
