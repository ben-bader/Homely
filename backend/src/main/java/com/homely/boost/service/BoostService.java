package com.homely.boost.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homely.boost.dto.BoostPurchaseCreateRequest;
import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;
import com.homely.boost.mapper.BoostPurchaseMapper;
import com.homely.boost.repository.BoostPurchaseRepository;
import com.homely.common.enums.PurchaseStatus;
import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.service.NotificationService;
import com.homely.property.service.PropertyService;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BoostService {

    private final BoostPurchaseRepository boostPurchaseRepository;
    private final BoostPurchaseMapper boostPurchaseMapper;
    private final UserService userService;
    private final PropertyService propertyService;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

    public BoostPurchaseDto create(BoostPurchaseCreateRequest request, String sellerEmail) {
        var seller = userService.getByEmail(sellerEmail);
        if (seller == null) {
            throw new RuntimeException("User not found: " + sellerEmail);
        }

        var property = propertyService.getEntityById(request.getPropertyId());

        BoostPurchase entity = boostPurchaseMapper.toEntity(request);
        entity.setSeller(seller);
        entity.setProperty(property);
        entity.setStatus(PurchaseStatus.PENDING);

        BoostPurchase saved = boostPurchaseRepository.save(entity);
        
        // Send notification to seller confirming boost purchase
        try {
            String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
                put("propertyTitle", property.getTitle());
                put("propertyId", property.getId().toString());
                put("boostId", saved.getId().toString());
                put("amount", request.getAmount());
                put("currency", request.getCurrency());
                put("durationDays", request.getDurationDays());
                put("status", PurchaseStatus.PENDING.name());
                put("message", "Your boost for '" + property.getTitle() + "' has been created and is pending approval.");
            }});
            
            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(seller.getId());
            notificationRequest.setType("BOOST_CREATED");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);
        } catch (Exception e) {
            // Log but don't fail if notification fails
            System.err.println("Failed to send boost creation notification: " + e.getMessage());
        }
        
        return boostPurchaseMapper.toDto(saved);
    }

    public BoostPurchase getById(UUID id) {
        return boostPurchaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Boost not found"));
    }

    public List<BoostPurchase> getByStatus(PurchaseStatus status) {
        return boostPurchaseRepository.findByStatus(status);
    }

    public List<BoostPurchase> getMyBoosts(String sellerEmail) {
        var seller = userService.getByEmail(sellerEmail);
        if (seller == null) {
            throw new RuntimeException("User not found: " + sellerEmail);
        }
        return boostPurchaseRepository.findBySellerId(seller.getId());
    }
    public List<BoostPurchase> getAll(){
        return boostPurchaseRepository.findAll();
    }
    public BoostPurchaseDto updateStatus(UUID boostId, PurchaseStatus newStatus) {

    BoostPurchase boost = boostPurchaseRepository.findById(boostId)
            .orElseThrow(() -> new RuntimeException("Boost not found"));

    PurchaseStatus oldStatus = boost.getStatus();
    boost.setStatus(newStatus);

    BoostPurchase saved = boostPurchaseRepository.save(boost);
    
    // Send notification to seller about boost status change
    try {
        String payload = objectMapper.writeValueAsString(new java.util.HashMap<String, Object>() {{
            put("propertyTitle", boost.getProperty().getTitle());
            put("propertyId", boost.getProperty().getId().toString());
            put("boostId", saved.getId().toString());
            put("oldStatus", oldStatus.name());
            put("newStatus", newStatus.name());
            put("message", "Your boost for '" + boost.getProperty().getTitle() + "' has been " + newStatus.name().toLowerCase());
        }});
        
        NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
        notificationRequest.setUserId(boost.getSeller().getId());
        notificationRequest.setType("BOOST_STATUS_CHANGED");
        notificationRequest.setPayload(payload);
        notificationService.create(notificationRequest);
    } catch (Exception e) {
        // Log but don't fail if notification fails
        System.err.println("Failed to send boost status notification: " + e.getMessage());
    }

    return boostPurchaseMapper.toDto(saved);
}
public long count(){
        return boostPurchaseRepository.count();
    }
}
