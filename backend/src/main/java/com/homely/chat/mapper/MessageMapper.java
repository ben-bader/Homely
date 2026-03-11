package com.homely.chat.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import com.homely.chat.dto.MessageDto;
import com.homely.chat.entity.Message;

@Mapper(componentModel = "spring")
public interface MessageMapper {

    @Mapping(target = "conversationId", source = "conversation.id")
    @Mapping(target = "senderId", source = "sender.id")
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "updatedAt", source = "updatedAt")
    MessageDto toDto(Message entity);
}
