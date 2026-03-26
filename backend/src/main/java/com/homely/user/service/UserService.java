package com.homely.user.service;

import java.util.List;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.homely.common.enums.RoleType;
import com.homely.moderation.entity.LogActivity;
import com.homely.moderation.service.LogActivityService;
import com.homely.user.dto.UserUpdateRequest;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final LogActivityService logActivityService;

    public User getById(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
    public List<User> getAll() {
        return userRepository.findAll();
    }
    public User getByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElse(null);
    }

    public List<User> getByRole(RoleType role) {
    return userRepository.findByRole(role);
    }
    public List<User> getByActiveStatus(boolean isActive) {
        return userRepository.findByIsActive(isActive);
    }

    public void deactivate(UUID id) {
        User user = getById(id);
        user.setActive(false);
        User saved = userRepository.save(user);
        
        // Log user suspension activity
        logActivityService.log(
            saved,
            LogActivity.ActivityType.SUSPEND,
            LogActivity.EntityType.USER,
            id,
            "User account suspended: " + saved.getEmail(),
            "{\"userId\":\"" + id + "\",\"email\":\"" + saved.getEmail() + "\",\"status\":\"suspended\"}"
        );
    }
    public void activate(UUID id) {
        User user = getById(id);
        user.setActive(true);
        User saved = userRepository.save(user);
        
        // Log user reactivation activity
        logActivityService.log(
            saved,
            LogActivity.ActivityType.REACTIVATE,
            LogActivity.EntityType.USER,
            id,
            "User account reactivated: " + saved.getEmail(),
            "{\"userId\":\"" + id + "\",\"email\":\"" + saved.getEmail() + "\",\"status\":\"active\"}"
        );
    }
    
    public void updateFcmToken(UUID id, String fcmToken) {
        User user = getById(id);
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }
    
    public User updateBasicInfo(UUID id, UserUpdateRequest request) {
        User user = getById(id);

        StringBuilder changes = new StringBuilder("{");

        if (request.getName() != null) {
            changes.append("\"name\":\"").append(request.getName()).append("\",");
            user.setName(request.getName());
        }

        if (request.getPhone() != null) {
            changes.append("\"phone\":\"").append(request.getPhone()).append("\",");
            user.setPhone(request.getPhone());
        }

        String changesJson = changes.toString();
        if (changesJson.endsWith(",")) {
            changesJson = changesJson.substring(0, changesJson.length() - 1);
        }
        changesJson += "}";

        User saved = userRepository.save(user);
        
        // Log user update activity
        logActivityService.log(
            saved,
            LogActivity.ActivityType.UPDATE,
            LogActivity.EntityType.USER,
            id,
            "User profile updated",
            changesJson
        );

        return saved;
    }
    
    public void updatePassword(UUID id, String newPassword) {
        User user = getById(id);
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }
    public long count(){
        return userRepository.count();
    }
}
