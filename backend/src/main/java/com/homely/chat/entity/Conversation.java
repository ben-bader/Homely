package com.homely.chat.entity;

import java.util.ArrayList;
import java.util.List;

import com.homely.common.base.BaseEntity;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Conversation extends BaseEntity {

    @ManyToOne
    private Property property;

    @ManyToOne
    private User client;

    @ManyToOne
    private User seller;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL)
    private List<Message> messages = new ArrayList<>();

}
