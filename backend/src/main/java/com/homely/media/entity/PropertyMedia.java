package com.homely.media.entity;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.MediaType;
import com.homely.property.entity.Property;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@RequiredArgsConstructor
public class PropertyMedia extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    @Enumerated(EnumType.STRING)
    private MediaType mediaType;

    private String url;
    private String thumbnailUrl;
    private int displayOrder;
    private int durationSeconds;
}
