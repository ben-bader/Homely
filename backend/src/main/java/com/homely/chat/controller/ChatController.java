package com.homely.chat.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.chat.dto.ChatMessageResponse;
import com.homely.chat.dto.ConversationDto;
import com.homely.chat.dto.MessageDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;
import com.homely.chat.mapper.ConversationMapper;
import com.homely.chat.service.ChatService;
import com.homely.media.repository.PropertyMediaRepository;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private static final Logger log = LoggerFactory.getLogger(ChatController.class);

    private final ChatService chatService;
    private final UserService userService;
    private final PropertyMediaRepository propertyMediaRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final ConversationMapper conversationMapper;

    @PostMapping("/conversations/{propertyId}")
    public ConversationDto createConversation(
            @PathVariable UUID propertyId,
            Principal principal) {

        Conversation conversation = chatService.createConversation(propertyId, principal.getName());

        return conversationMapper.toDto(conversation);
    }

    @GetMapping("/conversations")
    public List<com.homely.chat.dto.ConversationDto> getUserConversations(
            Principal principal) {

        User user = userService.getByEmail(principal.getName());

        return chatService.getUserConversations(user.getId())
                .stream()
                .map(conversationMapper::toDto)
                .toList();
    }

    @DeleteMapping("/conversations/{conversationId}")
    public void deleteConversation(
            @PathVariable UUID conversationId,
            Principal principal) {
        User user = userService.getByEmail(principal.getName());
        chatService.deleteConversationIfEmpty(conversationId, user.getId());
    }

    @GetMapping("/messages")
    public List<ChatMessageResponse> getConversationMessages(
            @RequestParam UUID conversationId) {

        return chatService.getConversationMessages(conversationId)
                .stream()
                .map(this::toChatMessageResponse)
                .toList();
    }

    private ChatMessageResponse toChatMessageResponse(Message message) {
        Property property = message.getProperty() != null
                ? message.getProperty()
                : message.getConversation() != null
                        ? message.getConversation().getProperty()
                        : null;

        return new ChatMessageResponse(
                message.getId(),
                message.getConversation().getId(),
                message.getSender().getId().toString(),
                message.getSender().getName(),
                message.getText(),
                message.getType() != null ? message.getType().name() : null,
                property != null ? property.getId() : null,
                property != null ? property.getTitle() : null,
                property != null ? getFirstPropertyImageUrl(property) : null,
                property != null ? formatPropertyPrice(property) : null,
                property != null ? property.getAddress() : null,
                message.getReadAt(),
                message.getCreatedAt());
    }

    private String getFirstPropertyImageUrl(Property property) {
        return propertyMediaRepository.findByPropertyId(property.getId()).stream()
                .findFirst()
                .map(media -> media.getUrl())
                .orElse(null);
    }

    private String formatPropertyPrice(Property property) {
        if (property.getPrice() == null) {
            return null;
        }
        if (property.getCurrency() != null && !property.getCurrency().isBlank()) {
            return property.getCurrency() + " " + property.getPrice().toPlainString();
        }
        return property.getPrice().toPlainString();
    }

    @MessageMapping({"/chat.send", "/chat.sendMessage"})
    public void send(MessageDto mdto, Principal principal) {

        log.info("Received STOMP message from principal={} conversationId={} body=" + mdto.getBody(), principal == null ? "anonymous" : principal.getName(), mdto.getConversationId());

        if (principal == null) {
            throw new RuntimeException("Unauthorized");
        }

        Message message = chatService.sendMessage(mdto, principal.getName());

        ChatMessageResponse response = toChatMessageResponse(message);

        messagingTemplate.convertAndSend(
                "/topic/chat/" + message.getConversation().getId(),
                response);
    }

    @PutMapping("/message/{messageId}")
    public Message editMessage(
            @PathVariable Long messageId,
            @RequestParam String content,
            @RequestParam UUID userId) {

        return chatService.editMessage(messageId, content, userId);
    }

    @DeleteMapping("/message/{messageId}")
    public void deleteMessage(
            @PathVariable Long messageId,
            @RequestParam UUID userId) {

        chatService.deleteMessage(messageId, userId);
    }
}
