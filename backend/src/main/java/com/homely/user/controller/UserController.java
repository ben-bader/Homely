package com.homely.user.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.common.enums.RoleType;
import com.homely.user.dto.UserDto;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;


@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    
    @GetMapping("/role/{role}")
    public List<UserDto> byRole(@PathVariable RoleType role) {
        return userService.getByRole(role).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping("/active/{isActive}")
    public List<UserDto> byActiveStatus(@PathVariable boolean isActive) {
        return userService.getByActiveStatus(isActive).stream()
            .map(this::convertToDto)
            .toList();
    }

    @GetMapping
    public List<UserDto> all() {
        return userService.getAll().stream()
            .map(this::convertToDto)
            .toList();
    }

    @DeleteMapping("/{id}")
    public void deactivate(@PathVariable UUID id) {
        userService.deactivate(id);
    }

    @PutMapping("/{id}")
    public void activate(@PathVariable UUID id) {
        userService.activate(id);
    }

    private UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setName(user.getName());
        dto.setPhone(user.getPhone());
        dto.setRole(user.getRole());
        dto.setActive(user.isActive());
        return dto;
    }
}
