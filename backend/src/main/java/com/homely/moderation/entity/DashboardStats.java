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
    private int users;
    private int properties;
    private int reports;
    private int boosts;
}
