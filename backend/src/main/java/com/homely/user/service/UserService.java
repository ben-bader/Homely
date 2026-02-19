package com.homely.user.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.homely.common.enums.RoleType;
import com.homely.user.dto.UserUpdateRequest;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

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
        userRepository.save(user);
    }
    public void activate(UUID id) {
        User user = getById(id);
        user.setActive(true);
        userRepository.save(user);
    }
    public User updateBasicInfo(UUID id, UserUpdateRequest request) {

    User user = getById(id);

    if (request.getName() != null)
        user.setName(request.getName());

    if (request.getPhone() != null)
        user.setPhone(request.getPhone());

    return userRepository.save(user);
}

}

