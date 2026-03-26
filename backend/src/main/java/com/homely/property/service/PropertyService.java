package com.homely.property.service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homely.boost.repository.BoostPurchaseRepository;
import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;
import com.homely.media.repository.PropertyMediaRepository;
import com.homely.media.service.MediaService;
import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.service.LogActivityService;
import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.service.NotificationService;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
import com.homely.property.dto.PropertyUpdateRequest;
import com.homely.property.entity.Apartment;
import com.homely.property.entity.Commercial;
import com.homely.property.entity.House;
import com.homely.property.entity.Land;
import com.homely.property.entity.Property;
import com.homely.property.entity.Studio;
import com.homely.property.entity.Villa;
import com.homely.property.mapper.ApartmentMapper;
import com.homely.property.mapper.CommercialMapper;
import com.homely.property.mapper.HouseMapper;
import com.homely.property.mapper.LandMapper;
import com.homely.property.mapper.PropertyMapper;
import com.homely.property.mapper.StudioMapper;
import com.homely.property.mapper.VillaMapper;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final BoostPurchaseRepository boostPurchaseRepository;
    private final UserService userService;
    private final PropertyMapper propertyMapper;
    private final ApartmentMapper apartmentMapper;
    private final HouseMapper houseMapper;
    private final VillaMapper villaMapper;
    private final StudioMapper studioMapper;
    private final CommercialMapper commercialMapper;
    private final LandMapper landMapper;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;
    private final MediaService mediaService;
    private final PropertyMediaRepository propertyMediaRepository;
    private final LogActivityService logActivityService;

    public PropertyDto create(PropertyCreateRequest request, String userEmail) {

        User seller = userService.getByEmail(userEmail);

        if (!seller.getRole().name().equals("SELLER")) {
            throw new RuntimeException("Only sellers can create properties");
        }

        Property property = propertyMapper.toEntity(request);
        property.setSeller(seller);
        property.setStatus(PropertyStatus.DRAFT);

        attachSubtype(property, request);
        
        Property saved = propertyRepository.save(property);
        
        // Log property creation activity
        logActivityService.log(
            seller,
            LogActivity.ActivityType.CREATE,
            LogActivity.EntityType.PROPERTY,
            saved.getId(),
            "Created property: " + saved.getTitle() + " (" + saved.getPropertyType() + ")",
            "{\"propertyId\":\"" + saved.getId() + "\",\"title\":\"" + saved.getTitle() + "\",\"type\":\"" + saved.getPropertyType() + "\"}"
        );
        
        // Send notification to seller confirming property creation
        sendPropertyCreatedNotification(seller, saved);

        PropertyDto dto = propertyMapper.toDto(saved);
        // Populate images for the property (might be empty for new properties)
        List<String> imageUrls = propertyMediaRepository.findByPropertyId(saved.getId())
                .stream()
                .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                .map(media -> media.getUrl())
                .toList();
        dto.setImages(imageUrls);
        
        return enrichWithBoostInfo(dto);
    }

    private void attachSubtype(Property property, PropertyCreateRequest request) {

        PropertyType type = property.getPropertyType();

        if (type == null) {
            throw new RuntimeException("Property type is required");
        }

        switch (type) {
            case APARTMENT -> {
                if (request.getApartment() != null) {
                    Apartment a = apartmentMapper.toEntity(request.getApartment());
                    a.setProperty(property);
                    property.setApartment(a);
                }
            }
            case HOUSE -> {
                if (request.getHouse() != null) {
                    House h = houseMapper.toEntity(request.getHouse());
                    h.setProperty(property);
                    property.setHouse(h);
                }
            }
            case VILLA -> {
                if (request.getVilla() != null) {
                    Villa v = villaMapper.toEntity(request.getVilla());
                    v.setProperty(property);
                    property.setVilla(v);
                }
            }
            case STUDIO -> {
                if (request.getStudio() != null) {
                    Studio s = studioMapper.toEntity(request.getStudio());
                    s.setProperty(property);
                    property.setStudio(s);
                }
            }
            case COMMERCIAL -> {
                if (request.getCommercial() != null) {
                    Commercial c = commercialMapper.toEntity(request.getCommercial());
                    c.setProperty(property);
                    property.setCommercial(c);
                }
            }
            case LAND -> {
                if (request.getLand() != null) {
                    Land l = landMapper.toEntity(request.getLand());
                    l.setProperty(property);
                    property.setLand(l);
                }
            }
        }
    }

    public PropertyDto get(UUID id) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        // Force fetch of lazy-loaded subtypes
        if (property.getApartment() != null) property.getApartment().getPropertyId();
        if (property.getHouse() != null) property.getHouse().getPropertyId();
        if (property.getVilla() != null) property.getVilla().getPropertyId();
        if (property.getStudio() != null) property.getStudio().getPropertyId();
        if (property.getCommercial() != null) property.getCommercial().getPropertyId();
        if (property.getLand() != null) property.getLand().getPropertyId();
        
        PropertyDto dto = propertyMapper.toDto(property);
        
        // Populate images from PropertyMedia
        List<String> imageUrls = mediaService.findByPropertyId(id)
                .stream()
                .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                .map(media -> media.getUrl())
                .toList();
        dto.setImages(imageUrls);
        
        return enrichWithBoostInfo(dto);
    }

    public List<PropertyDto> getAll() {
        return enrichWithBoostInfo(propertyRepository.findAllOrderByBoostThenCreatedAt(java.time.Instant.now())
                .stream()
                .map(property -> {
                    PropertyDto dto = propertyMapper.toDto(property);
                    // Populate images for each property
                    List<String> imageUrls = propertyMediaRepository.findByPropertyId(property.getId())
                            .stream()
                            .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                            .map(media -> media.getUrl())
                            .toList();
                    dto.setImages(imageUrls);
                    return dto;
                })
                .toList());
    }
    public PropertyDto getById(UUID id) {
    Property property = propertyRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Property not found"));
    return enrichWithBoostInfo(propertyMapper.toDto(property));
}

    public List<PropertyDto> filter(
        ListingType type,
        PropertyType propertyType,
        BigDecimal minPrice,
        BigDecimal maxPrice,
        String city,
        Instant fromDate,
        Instant toDate
) {

Specification<Property> spec = (root, query, cb) -> null;

    if (type != null) {
        spec = spec.and((root, query, cb) ->
                cb.equal(root.get("listingType"), type));
    }

    if (propertyType != null) {
        spec = spec.and((root, query, cb) ->
                cb.equal(root.get("propertyType"), propertyType));
    }

    if (city != null) {
        spec = spec.and((root, query, cb) ->
                cb.like(cb.lower(root.get("address")),
                        "%" + city.toLowerCase() + "%"));
    }

    if (minPrice != null) {
        spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("price"), minPrice));
    }

    if (maxPrice != null) {
        spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("price"), maxPrice));
    }

    if (fromDate != null) {
        spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), fromDate));
    }

    if (toDate != null) {
        spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), toDate));
    }

    return enrichWithBoostInfo(propertyRepository.findAll(spec)
            .stream()
            .sorted((p1, p2) -> {
                boolean p1IsBoosted = isBoosted(p1.getId());
                boolean p2IsBoosted = isBoosted(p2.getId());
                
                if (p1IsBoosted && !p2IsBoosted) return -1;
                if (!p1IsBoosted && p2IsBoosted) return 1;
                
                return p2.getCreatedAt().compareTo(p1.getCreatedAt());
            })
            .map(property -> {
                PropertyDto dto = propertyMapper.toDto(property);
                // Populate images for each property
                List<String> imageUrls = propertyMediaRepository.findByPropertyId(property.getId())
                        .stream()
                        .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                        .map(media -> media.getUrl())
                        .toList();
                dto.setImages(imageUrls);
                return dto;
            })
            .toList());
}


    public List<PropertyDto> search(String keyword) {
        return propertyRepository.globalSearch(keyword)
                .stream()
                .sorted((p1, p2) -> {
                    boolean p1IsBoosted = isBoosted(p1.getId());
                    boolean p2IsBoosted = isBoosted(p2.getId());
                    
                    if (p1IsBoosted && !p2IsBoosted) return -1;
                    if (!p1IsBoosted && p2IsBoosted) return 1;
                    
                    return p2.getCreatedAt().compareTo(p1.getCreatedAt());
                })
                .map(property -> {
                    PropertyDto dto = propertyMapper.toDto(property);
                    // Populate images for each property
                    List<String> imageUrls = propertyMediaRepository.findByPropertyId(property.getId())
                            .stream()
                            .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                            .map(media -> media.getUrl())
                            .toList();
                    dto.setImages(imageUrls);
                    return dto;
                })
                .toList();
    }

    public List<PropertyDto> getBySellerEmail(String email) {
        return propertyRepository.findBySellerEmail(email)
                .stream()
                .sorted((p1, p2) -> {
                    boolean p1IsBoosted = isBoosted(p1.getId());
                    boolean p2IsBoosted = isBoosted(p2.getId());
                    
                    if (p1IsBoosted && !p2IsBoosted) return -1;
                    if (!p1IsBoosted && p2IsBoosted) return 1;
                    
                    return p2.getCreatedAt().compareTo(p1.getCreatedAt());
                })
                .map(property -> {
                    PropertyDto dto = propertyMapper.toDto(property);
                    // Populate images for each property
                    List<String> imageUrls = propertyMediaRepository.findByPropertyId(property.getId())
                            .stream()
                            .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                            .map(media -> media.getUrl())
                            .toList();
                    dto.setImages(imageUrls);
                    return dto;
                })
                .toList();
    }

    public PropertyDto updateStatus(UUID propertyId, PropertyStatus status) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        PropertyStatus oldStatus = property.getStatus();
        property.setStatus(status);
        
        Property saved = propertyRepository.save(property);
        
        // Log property status update (this is typically done by admin, but we still track it)
        if (property.getSeller() != null) {
            String changes = String.format("{\"oldStatus\":\"%s\",\"newStatus\":\"%s\"}", oldStatus, status);
            logActivityService.log(
                property.getSeller(),
                LogActivity.ActivityType.UPDATE,
                LogActivity.EntityType.PROPERTY,
                propertyId,
                "Property status changed from " + oldStatus + " to " + status,
                changes
            );
        }
        
        // Send notification to seller about property status change
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("propertyTitle", property.getTitle());
                put("propertyId", saved.getId().toString());
                put("oldStatus", oldStatus.name());
                put("newStatus", status.name());
                put("message", "Your property '" + property.getTitle() + "' status has changed from " + 
                    oldStatus.name() + " to " + status.name());
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(property.getSeller().getId());
            notificationRequest.setType("PROPERTY_STATUS_CHANGED");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);
        } catch (Exception e) {
            // Log but don't fail if notification fails
            System.err.println("Failed to send property status notification: " + e.getMessage());
        }

        PropertyDto dto = propertyMapper.toDto(saved);
        // Populate images for the property
        List<String> imageUrls = propertyMediaRepository.findByPropertyId(saved.getId())
                .stream()
                .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                .map(media -> media.getUrl())
                .toList();
        dto.setImages(imageUrls);
        
        return enrichWithBoostInfo(dto);
    }

    public PropertyDto update(UUID propertyId, PropertyUpdateRequest request, String userEmail) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        if (property.getSeller() == null || !property.getSeller().getEmail().equals(userEmail)) {
            throw new RuntimeException("Only the owner can update this property");
        }

        // Track changes for the log
        StringBuilder changes = new StringBuilder("{");

        if (request.getTitle() != null) { 
            changes.append("\"title\":\"").append(request.getTitle()).append("\",");
            property.setTitle(request.getTitle()); 
        }
        if (request.getDescription() != null) { 
            changes.append("\"description\":\"").append(request.getDescription().substring(0, Math.min(50, request.getDescription().length()))).append("...\",");
            property.setDescription(request.getDescription()); 
        }
        if (request.getPrice() != null) { 
            changes.append("\"price\":\"").append(request.getPrice()).append("\",");
            property.setPrice(request.getPrice()); 
        }
        if (request.getCurrency() != null) { 
            changes.append("\"currency\":\"").append(request.getCurrency()).append("\",");
            property.setCurrency(request.getCurrency()); 
        }
        if (request.getListingType() != null) { 
            changes.append("\"listingType\":\"").append(request.getListingType()).append("\",");
            property.setListingType(request.getListingType()); 
        }
        if (request.getPropertyType() != null) { 
            changes.append("\"propertyType\":\"").append(request.getPropertyType()).append("\",");
            property.setPropertyType(request.getPropertyType()); 
        }
        if (request.getStatus() != null) { 
            changes.append("\"status\":\"").append(request.getStatus()).append("\",");
            property.setStatus(request.getStatus()); 
        }
        if (request.getAddress() != null) { 
            changes.append("\"address\":\"").append(request.getAddress()).append("\",");
            property.setAddress(request.getAddress()); 
        }
        if (request.getLatitude() != null) { 
            changes.append("\"latitude\":\"").append(request.getLatitude()).append("\",");
            property.setLatitude(request.getLatitude()); 
        }
        if (request.getLongitude() != null) { 
            changes.append("\"longitude\":\"").append(request.getLongitude()).append("\",");
            property.setLongitude(request.getLongitude()); 
        }

        // Subtype updates (create subtype if missing)
        if (request.getApartment() != null) {
            var ar = request.getApartment();
            Apartment a = property.getApartment();
            if (a == null) {
                a = new Apartment();
                a.setProperty(property);
                property.setApartment(a);
                changes.append("\"apartment\":\"created\",");
            }
            a.setBedrooms(ar.getBedrooms());
            a.setBathrooms(ar.getBathrooms());
            a.setFloor(ar.getFloor());
            a.setHasElevator(ar.isHasElevator());
        }

        if (request.getHouse() != null) {
            var hr = request.getHouse();
            House h = property.getHouse();
            if (h == null) {
                h = new House();
                h.setProperty(property);
                property.setHouse(h);
                changes.append("\"house\":\"created\",");
            }
            h.setBedrooms(hr.getBedrooms());
            h.setBathrooms(hr.getBathrooms());
            h.setHasGarage(hr.isHasGarage());
            h.setLandAreaSqm(hr.getLandAreaSqm());
        }

        if (request.getVilla() != null) {
            var vr = request.getVilla();
            Villa v = property.getVilla();
            if (v == null) {
                v = new Villa();
                v.setProperty(property);
                property.setVilla(v);
                changes.append("\"villa\":\"created\",");
            }
            v.setBedrooms(vr.getBedrooms());
            v.setBathrooms(vr.getBathrooms());
            v.setLandAreaSqm(vr.getLandAreaSqm());
            v.setHasPool(vr.isHasPool());
        }

        if (request.getStudio() != null) {
            var sr = request.getStudio();
            Studio s = property.getStudio();
            if (s == null) {
                s = new Studio();
                s.setProperty(property);
                property.setStudio(s);
                changes.append("\"studio\":\"created\",");
            }
            s.setFurnished(sr.isFurnished());
        }

        if (request.getCommercial() != null) {
            var cr = request.getCommercial();
            Commercial c = property.getCommercial();
            if (c == null) {
                c = new Commercial();
                c.setProperty(property);
                property.setCommercial(c);
                changes.append("\"commercial\":\"created\",");
            }
            c.setAreaSqm(cr.getAreaSqm());
            c.setBusinessType(cr.getBusinessType());
        }

        if (request.getLand() != null) {
            var lr = request.getLand();
            Land l = property.getLand();
            if (l == null) {
                l = new Land();
                l.setProperty(property);
                property.setLand(l);
                changes.append("\"land\":\"created\",");
            }
            l.setAreaSqm(lr.getAreaSqm());
            l.setConstructible(lr.isConstructible());
        }

        String changesJson = changes.toString();
        if (changesJson.endsWith(",")) {
            changesJson = changesJson.substring(0, changesJson.length() - 1);
        }
        changesJson += "}";

        Property saved = propertyRepository.save(property);
        
        // Log property update activity
        logActivityService.log(
            property.getSeller(),
            LogActivity.ActivityType.UPDATE,
            LogActivity.EntityType.PROPERTY,
            propertyId,
            "Updated property: " + property.getTitle(),
            changesJson
        );
        
        PropertyDto dto = propertyMapper.toDto(saved);
        // Populate images for the property
        List<String> imageUrls = propertyMediaRepository.findByPropertyId(saved.getId())
                .stream()
                .sorted((a, b) -> Integer.compare(a.getDisplayOrder(), b.getDisplayOrder()))
                .map(media -> media.getUrl())
                .toList();
        dto.setImages(imageUrls);
        
        return enrichWithBoostInfo(dto);
    }

    // ================= DELETE =================
    public void delete(UUID id) {
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        
        User seller = property.getSeller();
        String propertyTitle = property.getTitle();
        
        propertyRepository.deleteById(id);
        
        // Log property deletion activity
        if (seller != null) {
            logActivityService.log(
                seller,
                LogActivity.ActivityType.DELETE,
                LogActivity.EntityType.PROPERTY,
                id,
                "Deleted property: " + propertyTitle,
                "{\"propertyId\":\"" + id + "\",\"title\":\"" + propertyTitle + "\"}"
            );
        }
    }
    public Property getEntityById(UUID id) {
    return propertyRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Property not found"));
}
public long count(){
        return propertyRepository.count();
    }
    
    private void sendPropertyCreatedNotification(User seller, Property property) {
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("propertyTitle", property.getTitle());
                put("propertyId", property.getId().toString());
                put("propertyType", property.getPropertyType().name());
                put("status", PropertyStatus.DRAFT.name());
                put("message", "Your property '" + property.getTitle() + "' has been created as a draft.");
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(seller.getId());
            notificationRequest.setType("PROPERTY_CREATED");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);
            
            log.info("Property created notification sent to seller: {}", seller.getEmail());
        } catch (Exception e) {
            log.error("Failed to send property creation notification: {}", e.getMessage(), e);
        }
    }
    
    // ✅ Helper method to check if a property is currently boosted
    private boolean isBoosted(UUID propertyId) {
        Instant now = Instant.now();
        return boostPurchaseRepository.findActiveBoostByProperty(propertyId, now) != null;
    }
    
    // ✅ Helper method to enrich PropertyDto with boost information
    private PropertyDto enrichWithBoostInfo(PropertyDto dto) {
        Instant now = Instant.now();
        var activeBoost = boostPurchaseRepository.findActiveBoostByProperty(dto.getId(), now);
        
        if (activeBoost != null) {
            dto.setIsBoosted(true);
            dto.setBoostExpiryAt(activeBoost.getExpiryAt());
            dto.setBoostId(activeBoost.getId());
        } else {
            dto.setIsBoosted(false);
        }
        
        return dto;
    }
    
    // ✅ Helper method to enrich list of PropertyDtos with boost information
    private List<PropertyDto> enrichWithBoostInfo(List<PropertyDto> dtos) {
        Instant now = Instant.now();
        return dtos.stream().map(dto -> {
            var activeBoost = boostPurchaseRepository.findActiveBoostByProperty(dto.getId(), now);
            
            if (activeBoost != null) {
                dto.setIsBoosted(true);
                dto.setBoostExpiryAt(activeBoost.getExpiryAt());
                dto.setBoostId(activeBoost.getId());
            } else {
                dto.setIsBoosted(false);
            }
            
            return dto;
        }).toList();
    }
}
