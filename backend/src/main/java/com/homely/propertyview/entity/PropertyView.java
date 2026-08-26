package com.homely.propertyview.entity;

import com.homely.common.base.BaseEntity;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "property_views")
@Getter
@Setter
public class PropertyView extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "user_id")
    private com.homely.user.entity.User user; // nullable for anonymous views

    @ManyToOne
    @JoinColumn(name = "property_id", nullable = false)
    private com.homely.property.entity.Property property;

    private String ipAddress; // for anonymous tracking
}