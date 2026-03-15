package com.homely.favorite.entity;

import com.homely.common.base.BaseEntity;
import com.homely.media.entity.PropertyMedia;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "favorites", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "property_id", "media_id"}))
@Getter
@Setter
public class Favorite extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    @ManyToOne
    @JoinColumn(name = "media_id")
    private PropertyMedia media;

}