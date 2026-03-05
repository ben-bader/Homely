package com.homely.moderation.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@RequiredArgsConstructor
@AllArgsConstructor
public class DashboardStats {
    private long users;
    private long properties;
    private long reports;
    private long boosts;
}
