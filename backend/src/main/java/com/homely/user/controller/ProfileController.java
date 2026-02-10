package com.homely.user.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.ProfileUpdateRequest;
import com.homely.user.entity.Profile;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;
import com.homely.user.service.ProfileService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final UserRepository userRepository;

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public List<ProfileDto> getAll() {
        return profileService.getAll()
                .stream()
                .map(this::convertToDto)
                .toList();
    }

    @GetMapping("/me")
    public ProfileDto getMyProfile(Principal principal) {
        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return convertToDto(profileService.getById(user.getId()));
    }

    @PutMapping("/me")
    public ProfileDto updateMyProfile(
            Principal principal,
            @RequestBody ProfileUpdateRequest request) {

        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Profile profile = profileService.getById(user.getId());
        profile.setBio(request.getBio());
        profile.setAddress(request.getAddress());
        profile.setIdDocumentUrl(request.getIdDocumentUrl());

        return convertToDto(profileService.update(profile));
    }

    private ProfileDto convertToDto(Profile profile) {
        ProfileDto dto = new ProfileDto();
        dto.setUserId(profile.getUserId());
        dto.setBio(profile.getBio());
        dto.setAddress(profile.getAddress());
        dto.setVerified(profile.isVerified());
        dto.setIdDocumentUrl(profile.getIdDocumentUrl());
        return dto;
    }
}
