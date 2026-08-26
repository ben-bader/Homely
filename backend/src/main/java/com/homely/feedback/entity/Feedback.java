package com.homely.feedback.entity;

import com.homely.common.base.BaseEntity;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "feedbacks")
@Getter
@Setter
public class Feedback extends BaseEntity {

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "property_id", nullable = false)
    private Property property;

    @Column(nullable = false)
    private Integer rating;

    @Column(length = 1000)
    private String comment;
}