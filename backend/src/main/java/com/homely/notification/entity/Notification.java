package com.homely.notification.entity;

import com.homely.common.base.BaseEntity;
import com.homely.user.entity.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Notification extends BaseEntity {

    @ManyToOne
    private User user;

    private String type;

    @Column(columnDefinition = "TEXT")
    private String payload;

    private boolean read;
}
