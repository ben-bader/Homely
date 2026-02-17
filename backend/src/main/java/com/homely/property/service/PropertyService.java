package com.homely.property.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;
import com.homely.property.dto.PropertyCreateRequest;
import com.homely.property.dto.PropertyDto;
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

    public PropertyDto create(PropertyCreateRequest request, String userEmail) {
        User seller = userService.getByEmail(userEmail);
        if (seller == null) {
            throw new RuntimeException("User not found: " + userEmail);
        }
        if (!"SELLER".equals(seller.getRole().name())) {
            throw new RuntimeException("Only sellers can create properties");
        }

        Property property = propertyMapper.toEntity(request);
        property.setSeller(seller);

        PropertyType propertyType = property.getPropertyType();
        if (propertyType == null) {
            throw new RuntimeException("Property type is required");
        }

        switch (propertyType) {
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
            default -> throw new RuntimeException("Unsupported property type: " + propertyType);
        }

        Property saved = propertyRepository.save(property);
        return propertyMapper.toDto(saved);
    }

    /** Returns DTO for API responses. */
    public PropertyDto get(UUID id) {
        return propertyMapper.toDto(getEntity(id));
    }

    /** Returns entity for internal use (e.g. admin, relations). */
    public Property getEntity(UUID id) {
        return propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
    }

    public List<PropertyDto> getAll() {
        return propertyRepository.findAll().stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    public List<PropertyDto> findByPropertyType(PropertyType propertyType) {
        return propertyRepository.findByPropertyType(propertyType).stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    public List<PropertyDto> search(
            ListingType type,
            BigDecimal minPrice,
            BigDecimal maxPrice,
            String city
    ) {
        return propertyRepository.search(type, city, minPrice, maxPrice).stream()
                .map(propertyMapper::toDto)
                .toList();
    }

    public void delete(UUID id) {
        propertyRepository.deleteById(id);
    }
    public Property updateStatus(UUID propertyId, PropertyStatus status) {
    Property property = propertyRepository.findById(propertyId)
            .orElseThrow(() -> new RuntimeException("Property not found"));
    property.setStatus(status);
    return propertyRepository.save(property);
}

}
