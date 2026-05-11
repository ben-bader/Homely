import '../entities/media/property_media_entity.dart';
import '../entities/property/property_entity.dart';

abstract class IPropertyRepository {
  Future<List<PropertyEntity>> getAll();
  Future<PropertyEntity> getById(String id);
  Future<List<PropertyEntity>> filter(Map<String, String> params);
  Future<List<PropertyEntity>> search(String keyword);
  Future<List<PropertyEntity>> getMyListedProperties();
  Future<PropertyEntity> create(Map<String, dynamic> body);
  Future<PropertyEntity> update(String id, Map<String, dynamic> body);
  Future<PropertyEntity> updateStatus(String id, PropertyStatus status);
  Future<void> delete(String id);
  Future<List<PropertyMediaEntity>> getPropertyMedia(String propertyId);
}
