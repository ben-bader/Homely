package com.homely.user.entity;

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
public class Profile {

    @Id
    private UUID userId;

    @MapsId
    @OneToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String bio;
    private String address;
    private boolean verified;
    private String avtarUrl;
    private String idDocumentUrl;
}

