package com.homely.property.entity;

import java.util.UUID;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapsId;
import jakarta.persistence.OneToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Commercial {

    @Id
    private UUID propertyId;

    @MapsId
    @OneToOne
    @JoinColumn(name = "property_id")
    private Property property;

    private Double areaSqm;
    private String businessType;
}
