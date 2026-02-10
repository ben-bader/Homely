package com.homely.property.service;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;
import com.homely.property.entity.Apartment;
import com.homely.property.entity.Commercial;
import com.homely.property.entity.House;
import com.homely.property.entity.Land;
import com.homely.property.entity.Property;
import com.homely.property.entity.Studio;
import com.homely.property.entity.Villa;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PropertyService {

    private final PropertyRepository propertyRepository;
    private final UserService userService;

    public Property create(Property property,String userEmail) {
        User seller = userService.getByEmail(userEmail);
        if(!seller.getRole().equals("SELLER")){
            throw new RuntimeException("Only sellers can create properties");
        }
        property.setSeller(seller);
         
        PropertyType propertyType = property.getPropertyType();
        
        if (propertyType == null) {
            throw new RuntimeException("Property type is required");
        }
        
        switch (propertyType) {
            case APARTMENT:
                if (property.getApartment() != null) {
                    Apartment apartment = property.getApartment();
                    apartment.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            case HOUSE:
                if (property.getHouse() != null) {
                    House house = property.getHouse();
                    house.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            case VILLA:
                if (property.getVilla() != null) {
                    Villa villa = property.getVilla();
                    villa.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            case STUDIO:
                if (property.getStudio() != null) {
                    Studio studio = property.getStudio();
                    studio.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            case COMMERCIAL:
                if (property.getCommercial() != null) {
                    Commercial commercial = property.getCommercial();
                    commercial.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            case LAND:
                if (property.getLand() != null) {
                    Land land = property.getLand();
                    land.setProperty(property); // Set bidirectional relationship
                }
                break;
                
            default:
                throw new RuntimeException("Unsupported property type: " + propertyType);
        }
        
        return propertyRepository.save(property);
    }

    public Property get(UUID id) {
        return propertyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Property not found"));
    }

    public List<Property> getAll() {
        return propertyRepository.findAll();
    }

    public List<Property> findByPropertyType(PropertyType propertyType) {
        return propertyRepository.findByPropertyType(propertyType);
    }

  public List<Property> search(
        ListingType type,
        BigDecimal minPrice,
        BigDecimal maxPrice,
        String city
) {
    return propertyRepository.search(type, city, minPrice, maxPrice);
}


    public void delete(UUID id) {
        propertyRepository.deleteById(id);
    }
}
