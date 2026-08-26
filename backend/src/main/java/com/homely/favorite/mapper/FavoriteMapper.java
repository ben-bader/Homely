package com.homely.favorite.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.favorite.dto.FavoriteCreateRequest;
import com.homely.favorite.dto.FavoriteDto;
import com.homely.favorite.entity.Favorite;

@Mapper(componentModel = "spring")
public interface FavoriteMapper {

    @Mapping(target = "user", ignore = true)
    @Mapping(target = "property", ignore = true)
    @Mapping(target = "media", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Favorite toEntity(FavoriteCreateRequest request);

    @Mapping(target = "userId", expression = "java(entity.getUser() != null ? entity.getUser().getId() : null)")
    @Mapping(target = "propertyId", expression = "java(entity.getProperty() != null ? entity.getProperty().getId() : null)")
    @Mapping(target = "mediaId", expression = "java(entity.getMedia() != null ? entity.getMedia().getId() : null)")
    FavoriteDto toDto(Favorite entity);

}