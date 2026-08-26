package com.homely.user.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.user.entity.Profile;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {
}
