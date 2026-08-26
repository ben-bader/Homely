package com.homely.user.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.user.entity.Profile;
import com.homely.user.repository.ProfileRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;

    public List<Profile> getAll() {
        return profileRepository.findAll();
    }
    public Profile getById(UUID id) {
        return profileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

    public Profile update(Profile profile) {
        return profileRepository.save(profile);
    }
}