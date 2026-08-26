package com.homely.favorite.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.favorite.dto.FavoriteCreateRequest;
import com.homely.favorite.dto.FavoriteDto;
import com.homely.favorite.service.FavoriteService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping
    public ResponseEntity<FavoriteDto> addFavorite(
            @Valid @RequestBody FavoriteCreateRequest request,
            Principal principal) {
        FavoriteDto favorite = favoriteService.addFavorite(request, principal.getName());
        return ResponseEntity.ok(favorite);
    }

    @DeleteMapping
    public ResponseEntity<Void> removeFavorite(
            @RequestParam UUID propertyId,
            @RequestParam(required = false) UUID mediaId,
            Principal principal) {
        favoriteService.removeFavorite(propertyId, mediaId, principal.getName());
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<FavoriteDto>> getUserFavorites(Principal principal) {
        List<FavoriteDto> favorites = favoriteService.getUserFavorites(principal.getName());
        return ResponseEntity.ok(favorites);
    }

}