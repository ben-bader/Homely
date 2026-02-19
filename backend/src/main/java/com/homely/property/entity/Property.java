package com.homely.property.entity;

import java.math.BigDecimal;

import com.homely.common.base.BaseEntity;
import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.PropertyType;
import com.homely.user.entity.User;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Property extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id")
    private User seller;

    private String title;
    private String description;
    private BigDecimal price;
    private String currency;

    @Enumerated(EnumType.STRING)
    private ListingType listingType;

    @Enumerated(EnumType.STRING)
    private PropertyType propertyType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PropertyStatus status;
    private String address;
    private Double latitude;
    private Double longitude;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Apartment apartment;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private House house;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Villa villa;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Studio studio;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Commercial commercial;

    @OneToOne(mappedBy = "property", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Land land;

}
