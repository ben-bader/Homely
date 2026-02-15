package com.homely.boost.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.boost.dto.BoostPurchaseCreateRequest;
import com.homely.boost.dto.BoostPurchaseDto;
import com.homely.boost.entity.BoostPurchase;
import com.homely.boost.mapper.BoostPurchaseMapper;
import com.homely.boost.repository.BoostPurchaseRepository;
import com.homely.common.enums.PurchaseStatus;
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

    public BoostPurchaseDto create(BoostPurchaseCreateRequest request, String sellerEmail) {
        var seller = userService.getByEmail(sellerEmail);
        if (seller == null) throw new RuntimeException("User not found: " + sellerEmail);
        var property = propertyService.getEntity(request.getPropertyId());
        BoostPurchase entity = boostPurchaseMapper.toEntity(request);
        entity.setSeller(seller);
        entity.setProperty(property);
        entity.setStatus(PurchaseStatus.PENDING);
        BoostPurchase saved = boostPurchaseRepository.save(entity);
        return boostPurchaseMapper.toDto(saved);
    }

    public BoostPurchase getById(UUID id) {
        return boostPurchaseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Boost not found"));
    }

    public List<BoostPurchase> getByStatus(PurchaseStatus status) {
        return boostPurchaseRepository.findByStatus(status);
    }

    public List<BoostPurchase> getBySellerId(UUID sellerId) {
        return boostPurchaseRepository.findBySellerId(sellerId);
    }

    public List<BoostPurchase> getAll() {
        return boostPurchaseRepository.findAll();
    }
}
