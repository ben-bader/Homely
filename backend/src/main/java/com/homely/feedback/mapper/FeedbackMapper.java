package com.homely.feedback.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.feedback.dto.FeedbackCreateRequest;
import com.homely.feedback.dto.FeedbackDto;
import com.homely.feedback.entity.Feedback;

@Mapper(componentModel = "spring")
public interface FeedbackMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "propertyId", source = "property.id")
    FeedbackDto toDto(Feedback entity);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "property", ignore = true)
    Feedback toEntity(FeedbackCreateRequest request);
}
