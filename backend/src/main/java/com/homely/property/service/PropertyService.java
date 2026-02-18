package com.homely.property.service;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.*;
import com.homely.property.mapper.*;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserService userService;
    private final PropertyMapper propertyMapper;
    private final ApartmentMapper apartmentMapper;
    private final HouseMapper houseMapper;
    private final VillaMapper villaMapper;
    private final StudioMapper studioMapper;
    private final CommercialMapper commercialMapper;
    private final LandMapper landMapper;

    // ================= CREATE =================
    public PropertyDto create(PropertyCreateRequest request, String userEmail) {

        User seller = userService.getByEmail(userEmail);

        if (!seller.getRole().name().equals("SELLER")) {
            throw new RuntimeException("Only sellers can create properties");
        }

        Property property = propertyMapper.toEntity(request);
        property.setSeller(seller);
        property.setStatus(PropertyStatus.DRAFT);

        attachSubtype(property, request);

        return propertyMapper.toDto(propertyRepository.save(property));
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

    // ================= GET ONE =================
    public PropertyDto get(UUID id) {
        return propertyMapper.toDto(
                propertyRepository.findById(id)
                        .orElseThrow(() -> new RuntimeException("Property not found"))
        );
    }

    // ================= HOMEPAGE =================
    public List<PropertyDto> getAll() {
        return propertyRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    // ================= FILTER =================
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

    return propertyRepository.findAll(spec)
            .stream()
            .map(propertyMapper::toDto)
            .toList();
}


    // ================= GLOBAL SEARCH =================
    public List<PropertyDto> search(String keyword) {
        return propertyRepository.globalSearch(keyword)
                .stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    // ================= SELLER PROPERTIES =================
    public List<PropertyDto> getBySellerEmail(String email) {
        return propertyRepository.findBySeller_Email(email)
                .stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    // ================= UPDATE STATUS =================
    public PropertyDto updateStatus(UUID propertyId, PropertyStatus status) {

        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        property.setStatus(status);

        return propertyMapper.toDto(propertyRepository.save(property));
    }

    // ================= DELETE =================
    public void delete(UUID id) {
        propertyRepository.deleteById(id);
    }
    public Property getEntityById(UUID id) {
    return propertyRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Property not found"));
}

}
