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
import com.homely.user.mapper.UserMapper;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    @GetMapping("/role/{role}")
    public List<UserDto> byRole(@PathVariable RoleType role) {
        return userService.getByRole(role).stream()
                .map(userMapper::toDto)
                .toList();
    }

    @GetMapping("/active/{isActive}")
    public List<UserDto> byActiveStatus(@PathVariable boolean isActive) {
        return userService.getByActiveStatus(isActive).stream()
                .map(userMapper::toDto)
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
}
