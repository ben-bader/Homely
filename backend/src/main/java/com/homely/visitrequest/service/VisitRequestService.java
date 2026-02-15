package com.homely.visitrequest.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.VisitStatus;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
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

    public List<VisitRequest> getByUser(UUID userId) {
        return visitRequestRepository.findByUserId(userId);
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

    public void delete(UUID id) {
        visitRequestRepository.deleteById(id);
    }
}