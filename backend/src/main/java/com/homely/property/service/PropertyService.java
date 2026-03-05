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
        Property property = propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
        // Force fetch of lazy-loaded subtypes
        if (property.getApartment() != null) property.getApartment().getPropertyId();
        if (property.getHouse() != null) property.getHouse().getPropertyId();
        if (property.getVilla() != null) property.getVilla().getPropertyId();
        if (property.getStudio() != null) property.getStudio().getPropertyId();
        if (property.getCommercial() != null) property.getCommercial().getPropertyId();
        if (property.getLand() != null) property.getLand().getPropertyId();
        return propertyMapper.toDto(property);
    }

    // ================= HOMEPAGE =================
    public List<PropertyDto> getAll() {
        return propertyRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(propertyMapper::toDto)
                .toList();
    }
    public PropertyDto getById(UUID id) {
    Property property = propertyRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Property not found"));
    return propertyMapper.toDto(property);
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
        return propertyRepository.findBySellerEmail(email)
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

    // ================= UPDATE PROPERTY =================
    public PropertyDto update(UUID propertyId, PropertyUpdateRequest request, String userEmail) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        if (property.getSeller() == null || !property.getSeller().getEmail().equals(userEmail)) {
            throw new RuntimeException("Only the owner can update this property");
        }

        if (request.getTitle() != null) property.setTitle(request.getTitle());
        if (request.getDescription() != null) property.setDescription(request.getDescription());
        if (request.getPrice() != null) property.setPrice(request.getPrice());
        if (request.getCurrency() != null) property.setCurrency(request.getCurrency());
        if (request.getListingType() != null) property.setListingType(request.getListingType());
        if (request.getPropertyType() != null) property.setPropertyType(request.getPropertyType());
        if (request.getStatus() != null) property.setStatus(request.getStatus());
        if (request.getAddress() != null) property.setAddress(request.getAddress());
        if (request.getLatitude() != null) property.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) property.setLongitude(request.getLongitude());

        // Subtype updates (create subtype if missing)
        if (request.getApartment() != null) {
            var ar = request.getApartment();
            Apartment a = property.getApartment();
            if (a == null) {
                a = new Apartment();
                a.setProperty(property);
                property.setApartment(a);
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
            }
            l.setAreaSqm(lr.getAreaSqm());
            l.setConstructible(lr.isConstructible());
        }

        Property saved = propertyRepository.save(property);
        return propertyMapper.toDto(saved);
    }

    // ================= DELETE =================
    public void delete(UUID id) {
        propertyRepository.deleteById(id);
    }
    public Property getEntityById(UUID id) {
    return propertyRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Property not found"));
}
public long count(){
        return propertyRepository.count();
    }
}
