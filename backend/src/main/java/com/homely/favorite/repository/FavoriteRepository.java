package com.homely.favorite.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.favorite.entity.Favorite;
import com.homely.media.entity.PropertyMedia;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

public interface FavoriteRepository extends JpaRepository<Favorite, UUID> {

    List<Favorite> findByUser(User user);

    Optional<Favorite> findByUserAndPropertyAndMedia(User user, Property property, PropertyMedia media);

    boolean existsByUserAndPropertyAndMedia(User user, Property property, PropertyMedia media);

}