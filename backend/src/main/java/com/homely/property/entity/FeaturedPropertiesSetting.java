package com.homely.property.entity;

import com.homely.common.base.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class FeaturedPropertiesSetting extends BaseEntity {
    @Column(nullable = false)
    private int featuredCount;
}
