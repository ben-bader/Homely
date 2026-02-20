package com.homely.chat.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import com.homely.chat.dto.MessageDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;
import com.homely.chat.mapper.ConversationMapper;
import com.homely.chat.mapper.MessageMapper;
import com.homely.chat.service.ChatService;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final UserService userService;
    private final SimpMessagingTemplate messagingTemplate;
    private final ConversationMapper conversationMapper;
    private final MessageMapper messageMapper;

    @PostMapping("/conversations/{propertyId}")
    public com.homely.chat.dto.ConversationDto createConversation(
            @PathVariable UUID propertyId,
            Principal principal) {

        Conversation conversation =
                chatService.createConversation(propertyId, principal.getName());

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

    @GetMapping("/messages")
    public List<MessageDto> getConversationMessages(
            @RequestParam UUID conversationId) {

        return chatService.getConversationMessages(conversationId)
                .stream()
                .map(messageMapper::toDto)
                .toList();
    }

    // 🔥 REAL TIME SEND
    @MessageMapping("/chat.send")
    public void send(MessageDto mdto, Principal principal) {

        if (principal == null) {
            throw new RuntimeException("Unauthorized");
        }

        Conversation conversation =
                chatService.getConversationById(mdto.getConversationId());

        User sender = userService.getByEmail(principal.getName());

        if (!sender.getId().equals(conversation.getClient().getId())
                && !sender.getId().equals(conversation.getSeller().getId())) {
            throw new RuntimeException("User not part of conversation");
        }

        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender);
        message.setBody(mdto.getBody());
        message.setAttachments(mdto.getAttachments());

        chatService.saveMessage(message);

        MessageDto dto = messageMapper.toDto(message);

        // ✅ SEND TO TOPIC
        messagingTemplate.convertAndSend(
                "/topic/conversations/" + conversation.getId(),
                dto
        );
    }
}
