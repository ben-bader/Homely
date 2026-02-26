# Required Imports for Seller UI

## When files are created/modified, ensure these imports are present:

### create_property_screen.dart
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/media/providers/media_providers.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart';
```

### seller_listings_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/screens/property_detail_screen.dart';
import 'package:mobile/features/seller/providers/seller_providers.dart';
import 'package:mobile/features/seller/screens/create_property_screen.dart';
```

### seller_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/property/models/property.dart';
import 'package:mobile/features/property/repositories/property_repository.dart';
```

### home_screen.dart (NEW IMPORTS TO ADD)
```dart
import 'package:mobile/features/seller/screens/create_property_screen.dart';
import 'package:mobile/features/seller/screens/seller_listings_screen.dart';
```

### profile_screen.dart (NEW IMPORT TO ADD)
```dart
import 'package:mobile/features/seller/providers/seller_providers.dart';
```

---

## Verify all dependencies are in pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1           # ✅ Present
  image_picker: ^1.0.7               # ✅ Present
  google_fonts: ^6.2.1               # ✅ Present
  http: ^1.2.0                       # ✅ Present
  cached_network_image: ^3.3.1       # ✅ Present
  flutter_image_compress: ^2.1.0     # ✅ Present
  # ... rest of dependencies
```

All required packages are already in the project! ✅
