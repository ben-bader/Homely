package com.homely.visitrequest.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.VisitStatus;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;
import com.homely.user.service.UserService;
import com.homely.visitrequest.dto.VisitRequestCreateRequest;
import com.homely.visitrequest.dto.VisitRequestDto;
import com.homely.visitrequest.entity.VisitRequest;
import com.homely.visitrequest.mapper.VisitRequestMapper;
import com.homely.visitrequest.repository.VisitRequestRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class VisitRequestService {

    private final VisitRequestRepository visitRequestRepository;
    private final VisitRequestMapper visitRequestMapper;
    private final UserService userService;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;


    public VisitRequestDto create(VisitRequestCreateRequest request, String userEmail) {
        User user = userService.getByEmail(userEmail);
        if (user == null) throw new RuntimeException("User not found: " + userEmail);
        var property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new RuntimeException("Property not found: " + request.getPropertyId()));
        VisitRequest entity = visitRequestMapper.toEntity(request);
        entity.setUser(user);
        entity.setProperty(property);
        entity.setStatus(VisitStatus.PENDING);
        VisitRequest saved = visitRequestRepository.save(entity);
        return visitRequestMapper.toDto(saved);
    }

    public VisitRequest get(UUID id) {
        return visitRequestRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("VisitRequest not found"));
    }

    public List<VisitRequest> getAll() {
        return visitRequestRepository.findAll();
    }

    public List<VisitRequest> getByProperty(UUID propertyId) {
        return visitRequestRepository.findByPropertyId(propertyId);
    }

    public List<VisitRequest> getByUser(User user) {
        return visitRequestRepository.findByUser(user);
    }

    public List<VisitRequest> getByStatus(VisitStatus status) {
        return visitRequestRepository.findByStatus(status);
    }

    public VisitRequestDto updateStatus(UUID id, VisitStatus status) {
        VisitRequest request = get(id);
        request.setStatus(status);
        VisitRequest saved = visitRequestRepository.save(request);
        return visitRequestMapper.toDto(saved);
    }
        public List<VisitRequest> getByUserEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return visitRequestRepository.findByUser(user);
    }

    // --- New method: find requests for a property if current user is the seller ---
    public List<VisitRequest> getByPropertyForSeller(UUID propertyId, String sellerEmail) {
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new RuntimeException("Property not found"));

        if (!property.getSeller().getEmail().equals(sellerEmail)) {
            throw new RuntimeException("Unauthorized: You are not the seller of this property");
        }

        return getByProperty(property.getId());
    }

    public void delete(UUID id) {
        visitRequestRepository.deleteById(id);
    }
}