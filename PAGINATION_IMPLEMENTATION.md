# Pagination Implementation Guide - Homely App

## Overview
This document describes the pagination system implemented across the Homely backend and frontends.

## Key Features
- **Page Size**: 30 items per page (default and recommended)
- **Backward Compatible**: Old non-paginated endpoints still work
- **Scalable**: Supports infinite scroll pattern
- **Consistent**: Same pagination structure across all endpoints

---

## Backend Implementation

### 1. Core Pagination Utility
**File**: `backend/src/main/java/com/homely/common/util/PaginationUtil.java`

Provides utility methods for pagination:
- `toPageResponse(Page<T> page)` - Convert Spring Page to PageResponse
- `toPageResponse(Page<S> page, Function<S, T> mapper)` - Convert with DTO mapping
- `validatePageNumber()` - Ensure valid page number
- `validatePageSize()` - Ensure valid page size (max 100)

### 2. PageResponse DTO
**File**: `backend/src/main/java/com/homely/common/dto/PageResponse.java`

```java
{
  "content": [/* items */],
  "pageNumber": 0,           // 0-indexed
  "pageSize": 30,
  "totalElements": 1250,
  "totalPages": 42,
  "isFirst": true,           // Is this the first page?
  "isLast": false,           // Is this the last page?
  "hasNext": true,           // Are there more pages?
  "hasPrevious": false       // Are there previous pages?
}
```

### 3. Paginated Repository Methods

All repositories now have paginated methods:

```java
// Properties
Page<Property> findAllOrderByBoostThenCreatedAt(Instant now, Pageable pageable);
Page<Property> filterPaginated(..., Pageable pageable);
Page<Property> globalSearchPaginated(String keyword, Pageable pageable);
Page<Property> findBySellerEmail(String email, Pageable pageable);

// Notifications
Page<Notification> findByUserEmailPaginated(String email, Pageable pageable);
Page<Notification> findByUserEmailAndReadFalsePaginated(String email, Pageable pageable);
Page<Notification> findByUserIdPaginated(UUID userId, Pageable pageable);
```

### 4. Service Methods

Services provide paginated methods:

**PropertyService**:
```java
PageResponse<PropertyDto> getAllPaginated(Integer pageNumber, Integer pageSize)
PageResponse<PropertyDto> filterPaginated(..., Integer pageNumber, Integer pageSize)
PageResponse<PropertyDto> searchPaginated(String keyword, Integer pageNumber, Integer pageSize)
PageResponse<PropertyDto> getBySellerEmailPaginated(String email, Integer pageNumber, Integer pageSize)
```

**NotificationService**:
```java
PageResponse<NotificationDto> getAllByEmailPaginated(String email, Integer pageNumber, Integer pageSize)
PageResponse<NotificationDto> getUnreadByEmailPaginated(String email, Integer pageNumber, Integer pageSize)
```

### 5. Controller Endpoints

**PropertyController** (`/api/properties`):
```
GET  /paginated              → Paginated all properties
GET  /filter/paginated       → Paginated filter
GET  /search/paginated       → Paginated search
GET  /my-listed/paginated    → Paginated seller's listings
```

**NotificationController** (`/api/notifications`):
```
GET  /paginated              → Paginated all notifications
GET  /unread/paginated       → Paginated unread notifications
```

### Query Parameters
```
page=0        # Page number (0-indexed, default: 0)
pageSize=30   # Items per page (default: 30, max: 100)
```

---

## Frontend Implementation

### Web Frontend (Next.js + React)

**File**: `web/lib/api.ts`

Added `PaginatedResponse` type:
```typescript
export interface PaginatedResponse<T> {
  content: T[];
  pageNumber: number;
  pageSize: number;
  totalElements: number;
  totalPages: number;
  isFirst: boolean;
  isLast: boolean;
  hasNext: boolean;
  hasPrevious: boolean;
}
```

**File**: `web/app/properties/useProperties.tsx`

Updated hook with pagination support:
```typescript
const {
  properties,        // Current loaded items
  loading,
  error,
  fetchProperties,   // Function to fetch page (0-indexed)
  loadMore,          // Function to load next page
  currentPage,
  pageSize,
  totalPages,
  totalElements,
  hasMore,           // true if more pages available
  // ... other properties
} = useProperties();
```

**Usage Example**:
```tsx
// Fetch first page (automatic on mount)
useEffect(() => {
  // Already called in hook
}, []);

// Load more items (for infinite scroll)
const handleScroll = () => {
  if (hasMore && !loading) {
    loadMore();
  }
};

// Render
<div>
  {properties.map(p => <PropertyCard key={p.id} property={p} />)}
  {hasMore && <button onClick={loadMore}>Load More</button>}
</div>
```

### Mobile Frontend (Flutter)

**File**: `mobile/lib/core/models/paginated_response.dart`

```dart
class PaginatedResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool isFirst;
  final bool isLast;
  final bool hasNext;
  final bool hasPrevious;

  bool get canLoadMore => hasNext;
  int get nextPageNumber => pageNumber + 1;
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) { ... }
}
```

**File**: `mobile/lib/core/network/api_client.dart`

Added pagination helpers:
```dart
// Default page size
static const int defaultPageSize = 30;

// Validate page number (ensures >= 0)
static int validatePageNumber(int? pageNumber) { ... }

// Validate page size (ensures 1-100)
static int validatePageSize(int? pageSize) { ... }
```

**Usage Example**:
```dart
// In your repository/service
Future<PaginatedResponse<PropertyDto>> fetchProperties(int page) async {
  final pageNumber = ApiClient.validatePageNumber(page);
  final pageSize = ApiClient.validatePageSize(30);
  
  final response = await ApiClient.get(
    '/properties/paginated',
    queryParams: {
      'page': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    },
  );
  
  return PaginatedResponse<PropertyDto>.fromJson(
    response,
    (json) => PropertyDto.fromJson(json as Map<String, dynamic>),
  );
}
```

---

## Migration Guide

### For Web Developers

**Before** (Old endpoint):
```tsx
const res = await api.get<Property[]>("/admin/properties");
setProperties(res.data ?? []);
```

**After** (Paginated endpoint):
```tsx
const res = await api.get<PaginatedResponse<Property>>("/admin/properties/paginated", {
  params: { page: 0, pageSize: 30 },
});
setProperties(res.data.content ?? []);
setHasMore(res.data.hasNext);
```

### For Mobile Developers

**Before** (Old endpoint):
```dart
final response = await ApiClient.get('/properties');
final properties = List<PropertyDto>.from(...);
```

**After** (Paginated endpoint):
```dart
final response = await ApiClient.get(
  '/properties/paginated',
  queryParams: {'page': '0', 'pageSize': '30'},
);
final paginatedData = PaginatedResponse<PropertyDto>.fromJson(response, ...);
final properties = paginatedData.content;
```

---

## Backward Compatibility

**Old endpoints still work** (return full lists):

```
GET  /api/properties              (non-paginated)
GET  /api/properties/filter       (non-paginated)
GET  /api/properties/search       (non-paginated)
GET  /api/properties/my-listed    (non-paginated)
GET  /api/notifications           (non-paginated)
GET  /api/notifications/unread    (non-paginated)
```

These are maintained for backward compatibility and can be used if pagination is not needed.

---

## Performance Recommendations

1. **Default to 30 items/page**: Balances UX and performance
2. **Never exceed 100 items/page**: Backend enforces maximum
3. **Lazy load images**: Only load images for visible items
4. **Virtual scrolling**: For large lists, implement virtual scrolling
5. **Cache previous pages**: Store already-loaded pages locally

---

## Database Considerations

- Pagination uses `OFFSET/LIMIT` queries
- For large datasets, ensure proper indexing on sort columns
- Current sorting: `createdAt DESC`, boosted properties first
- Monitor query performance if `totalElements` grows significantly

---

## API Error Handling

All paginated endpoints return standardized errors:
```
400 - Invalid page/pageSize
401 - Unauthorized
404 - Resource not found
500 - Server error
```

---

## Examples

### Fetch Properties (Web)
```typescript
async function getPropertyPage(pageNumber: number = 0) {
  try {
    const response = await api.get<PaginatedResponse<Property>>(
      '/properties/paginated',
      { params: { page: pageNumber, pageSize: 30 } }
    );
    return response.data;
  } catch (error) {
    console.error('Error fetching properties:', error);
  }
}
```

### Fetch Properties (Mobile)
```dart
Future<PaginatedResponse<Property>> getPropertiesPage(int page) async {
  try {
    final data = await ApiClient.get(
      '/properties/paginated',
      queryParams: {
        'page': page.toString(),
        'pageSize': '30',
      },
    );
    return PaginatedResponse.fromJson(data, (json) => Property.fromJson(json));
  } catch (e) {
    print('Error fetching properties: $e');
    rethrow;
  }
}
```

### Infinite Scroll Pattern (Web)
```typescript
const handleScroll = useCallback(() => {
  if (hasMore && !loading && shouldLoadMore()) {
    loadMore();
  }
}, [hasMore, loading, loadMore]);

useEffect(() => {
  window.addEventListener('scroll', handleScroll);
  return () => window.removeEventListener('scroll', handleScroll);
}, [handleScroll]);
```

---

## Summary

✅ 30-item default page size for optimal performance  
✅ Simple, scalable pagination structure  
✅ Backward compatible with old endpoints  
✅ Ready for infinite scroll UI patterns  
✅ Supports all major entities (Properties, Notifications, etc.)  
✅ Production-ready implementation  

