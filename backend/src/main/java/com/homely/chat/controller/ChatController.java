package com.homely.chat.controller;

import java.security.Principal;
import java.util.List;
import java.util.UUID;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.dto.MessageDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;
import com.homely.chat.service.ChatService;
import com.homely.user.dto.UserDto;
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

    @PostMapping("/conversations/{propertyId}")
    public ConversationDto create(@PathVariable UUID propertyId, Principal principal) {
        return convertConversationToDto(chatService.createConversation(propertyId, principal.getName()));
    }

    @GetMapping("/messages")
    public List<MessageDto> getConversationMessages(@RequestParam UUID conversationId) {
        return chatService.getConversationMessages(conversationId).stream()
                .map(this::convertMessageToDto)
                .toList();
    }

    @MessageMapping("/chat.send")
    public void send(MessageDto mdto, Principal principal) {

        if (principal == null) throw new RuntimeException("Unauthorized");

        Conversation conversation = chatService.getConversationById(mdto.getConversationId());
        User sender = userService.getByEmail(principal.getName());
        if (!sender.getId().equals(conversation.getClient().getId()) &&
            !sender.getId().equals(conversation.getSeller().getId())) {
            throw new RuntimeException("User not part of the conversation");
        }


        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender);
        message.setBody(mdto.getBody());
        chatService.saveMessage(message);

        MessageDto dto = convertMessageToDto(message);

        // Send to both users
        messagingTemplate.convertAndSendToUser(
                conversation.getClient().getEmail(),
                "/queue/conversations/" + conversation.getId(),
                dto
        );
        messagingTemplate.convertAndSendToUser(
                conversation.getSeller().getEmail(),
                "/queue/conversations/" + conversation.getId(),
                dto
        );

    }

    private ConversationDto convertConversationToDto(Conversation conversation) {
        ConversationDto dto = new ConversationDto();
        dto.setId(conversation.getId());
        dto.setPropertyId(conversation.getProperty().getId());
        dto.setClientId(conversation.getClient().getId());
        dto.setSellerId(conversation.getSeller().getId());
        return dto;
    }

    private MessageDto convertMessageToDto(Message message) {
        MessageDto dto = new MessageDto();
        dto.setId(message.getId());
        dto.setConversationId(message.getConversation().getId());
        dto.setSenderId(message.getSender().getId());
        dto.setBody(message.getBody());
        dto.setAttachments(message.getAttachments());
        dto.setReadAt(message.getReadAt());
        return dto;
    }
}
