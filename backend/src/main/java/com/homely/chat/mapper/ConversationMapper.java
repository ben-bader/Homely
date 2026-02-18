package com.homely.chat.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.AfterMapping;
import org.mapstruct.MappingTarget;

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;

import java.util.Comparator;

@Mapper(componentModel = "spring")
public interface ConversationMapper {

    @Mapping(target = "propertyId", source = "property.id")
    @Mapping(target = "clientId", source = "client.id")
    @Mapping(target = "sellerId", source = "seller.id")
    @Mapping(target = "propertyTitle", expression = "java(entity.getProperty() != null ? entity.getProperty().getTitle() : null)")
    @Mapping(target = "sellerName", expression = "java(entity.getSeller() != null ? entity.getSeller().getName() : null)")
    @Mapping(target = "sellerAvatar", ignore = true) // Profile doesn't have profilePicture field
    @Mapping(target = "lastMessage", ignore = true)
    @Mapping(target = "lastMessageAt", ignore = true)
    @Mapping(target = "unreadCount", ignore = true)
    ConversationDto toDto(Conversation entity);

    @AfterMapping
    default void mapLastMessage(@MappingTarget ConversationDto dto, Conversation entity) {
        if (entity.getMessages() != null && !entity.getMessages().isEmpty()) {
            Message lastMsg = entity.getMessages().stream()
                    .max(Comparator.comparing((Message m) -> m.getCreatedAt() != null ? m.getCreatedAt() : entity.getUpdatedAt()))
                    .orElse(null);
            if (lastMsg != null) {
                dto.setLastMessage(lastMsg.getBody());
                dto.setLastMessageAt(lastMsg.getCreatedAt() != null ? lastMsg.getCreatedAt() : entity.getUpdatedAt());
            }
        }
        // TODO: Calculate unread count based on readAt timestamps
        dto.setUnreadCount(0);
    }
}
