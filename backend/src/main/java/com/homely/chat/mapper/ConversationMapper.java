package com.homely.chat.mapper;

import java.util.Comparator;

import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;

@Mapper(componentModel = "spring")
public interface ConversationMapper {

    @Mapping(target = "propertyId", source = "property.id")
    @Mapping(target = "participantOneId", source = "participantOne.id")
    @Mapping(target = "participantTwoId", source = "participantTwo.id")
    @Mapping(target = "propertyTitle", expression = "java(entity.getProperty() != null ? entity.getProperty().getTitle() : null)")
    @Mapping(target = "participantTwoName", expression = "java(entity.getParticipantTwo() != null ? entity.getParticipantTwo().getName() : null)")
    @Mapping(target = "participantOneName", expression = "java(entity.getParticipantOne() != null ? entity.getParticipantOne().getName() : null)")
    @Mapping(target = "participantTwoAvatar", expression = "java(entity.getParticipantTwo() != null && entity.getParticipantTwo().getProfile() != null ? entity.getParticipantTwo().getProfile().getAvatarUrl() : null)")
    @Mapping(target = "participantOneAvatar", expression = "java(entity.getParticipantOne() != null && entity.getParticipantOne().getProfile() != null ? entity.getParticipantOne().getProfile().getAvatarUrl() : null)")
    @Mapping(target = "lastMessage", ignore = true)
    @Mapping(target = "lastMessageType", ignore = true)
    @Mapping(target = "lastMessageAt", ignore = true)
    @Mapping(target = "unreadCount", ignore = true)
    @Mapping(target = "createdAt", source = "createdAt")
    @Mapping(target = "updatedAt", source = "updatedAt")
    ConversationDto toDto(Conversation entity);

    @AfterMapping
    default void mapLastMessage(@MappingTarget ConversationDto dto, Conversation entity) {
        Message lastMsg = null;
        if (entity.getMessages() != null && !entity.getMessages().isEmpty()) {
            lastMsg = entity.getMessages().stream()
                    .max(Comparator.comparing((Message m) -> m.getCreatedAt() != null ? m.getCreatedAt() : entity.getUpdatedAt()))
                    .orElse(null);
        }
        if (lastMsg == null && entity.getLastMessage() != null) {
            lastMsg = entity.getLastMessage();
        }
        if (lastMsg != null) {
            dto.setLastMessage(lastMsg.getText());
            dto.setLastMessageType(lastMsg.getType() != null ? lastMsg.getType().name() : null);
            dto.setLastMessageAt(lastMsg.getCreatedAt() != null ? lastMsg.getCreatedAt() : entity.getUpdatedAt());
        }
        if (dto.getPropertyTitle() == null && entity.getLastMessage() != null && entity.getLastMessage().getProperty() != null) {
            dto.setPropertyTitle(entity.getLastMessage().getProperty().getTitle());
        }
        dto.setUnreadCount(0);
    }
}
