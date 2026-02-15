package com.homely.user.controller;

import java.security.Principal;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.user.dto.ProfileDto;
import com.homely.user.dto.ProfileUpdateRequest;
import com.homely.user.entity.Profile;
import com.homely.user.entity.User;
import com.homely.user.mapper.ProfileMapper;
import com.homely.user.repository.UserRepository;
import com.homely.user.service.ProfileService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;
    private final UserRepository userRepository;
    private final ProfileMapper profileMapper;

    @GetMapping("/me")
    public ProfileDto getMyProfile(Principal principal) {
        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return profileMapper.toDto(profileService.getById(user.getId()));
    }

    @PutMapping("/me")
    public ProfileDto updateMyProfile(
            Principal principal,
            @Valid @RequestBody ProfileUpdateRequest request) {
        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        Profile profile = profileService.getById(user.getId());
        profileMapper.updateFromRequest(request, profile);
        return profileMapper.toDto(profileService.update(profile));
    }
}
