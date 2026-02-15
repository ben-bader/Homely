package com.homely.chat.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.entity.Conversation;

@Mapper(componentModel = "spring")
public interface ConversationMapper {

    @Mapping(target = "propertyId", source = "property.id")
    @Mapping(target = "clientId", source = "client.id")
    @Mapping(target = "sellerId", source = "seller.id")
    ConversationDto toDto(Conversation entity);
}
