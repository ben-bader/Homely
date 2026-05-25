package com.homely.auth.dto;

import java.util.List;
import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class MeDto {
    private UUID id;
    private String username;
    private List<String> roles;
}
