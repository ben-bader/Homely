import '../entities/property_view/property_view_entity.dart';

abstract class IPropertyViewRepository {
  Future<PropertyViewEntity> trackView(String propertyId);
  Future<int> getViewCount(String propertyId);
  Future<List<PropertyViewEntity>> getViewsByProperty(String propertyId);
  Future<List<PropertyViewEntity>> getViewsByUser(String userId);
}
