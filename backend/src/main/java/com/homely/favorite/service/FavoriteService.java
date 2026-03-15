package com.homely.favorite.service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.homely.favorite.dto.FavoriteCreateRequest;
import com.homely.favorite.dto.FavoriteDto;
import com.homely.favorite.entity.Favorite;
import com.homely.favorite.mapper.FavoriteMapper;
import com.homely.favorite.repository.FavoriteRepository;
import com.homely.media.entity.PropertyMedia;
import com.homely.media.repository.PropertyMediaRepository;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final FavoriteMapper favoriteMapper;
    private final UserService userService;
    private final PropertyRepository propertyRepository;
    private final PropertyMediaRepository propertyMediaRepository;

    public FavoriteDto addFavorite(FavoriteCreateRequest request, String userEmail) {
        User user = userService.getByEmail(userEmail);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        Property property = propertyRepository.findById(request.getPropertyId())
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        PropertyMedia media = null;
        if (request.getMediaId() != null) {
            media = propertyMediaRepository.findById(request.getMediaId())
                    .orElseThrow(() -> new IllegalArgumentException("Media not found"));
            // Ensure media belongs to property
            if (!media.getProperty().getId().equals(property.getId())) {
                throw new IllegalArgumentException("Media does not belong to the property");
            }
        }

        if (favoriteRepository.existsByUserAndPropertyAndMedia(user, property, media)) {
            throw new IllegalArgumentException("Favorite already exists");
        }

        Favorite favorite = favoriteMapper.toEntity(request);
        favorite.setUser(user);
        favorite.setProperty(property);
        favorite.setMedia(media);

        Favorite saved = favoriteRepository.save(favorite);
        return favoriteMapper.toDto(saved);
    }

    public void removeFavorite(UUID propertyId, UUID mediaId, String userEmail) {
        User user = userService.getByEmail(userEmail);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        Property property = propertyRepository.findById(propertyId)
                .orElseThrow(() -> new IllegalArgumentException("Property not found"));
        PropertyMedia media = null;
        if (mediaId != null) {
            media = propertyMediaRepository.findById(mediaId)
                    .orElseThrow(() -> new IllegalArgumentException("Media not found"));
        }

        Favorite favorite = favoriteRepository.findByUserAndPropertyAndMedia(user, property, media)
                .orElseThrow(() -> new IllegalArgumentException("Favorite not found"));
        favoriteRepository.delete(favorite);
    }

    public List<FavoriteDto> getUserFavorites(String userEmail) {
        User user = userService.getByEmail(userEmail);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        List<Favorite> favorites = favoriteRepository.findByUser(user);
        return favorites.stream()
                .map(favoriteMapper::toDto)
                .collect(Collectors.toList());
    }

}