package com.homely.chat.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.homely.chat.dto.ConversationDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;
import com.homely.chat.repository.ConversationRepository;
import com.homely.chat.repository.MessageRepository;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;

    public Conversation getConversationById(UUID conversationId) {
        return conversationRepository.findById(conversationId).orElseThrow();
    }

    /**
     * Delete a conversation only if it contains no messages.
     * User must be either client or seller on the conversation.
     */
    @Transactional
    public void deleteConversationIfEmpty(UUID conversationId, UUID userId) {
        Conversation conv = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found"));

        // check membership
        if (!conv.getClient().getId().equals(userId) &&
                !conv.getSeller().getId().equals(userId)) {
            throw new RuntimeException("User not part of conversation");
        }

        long count = messageRepository.countByConversationId(conversationId);
        if (count > 0) {
            throw new RuntimeException("Conversation not empty");
        }

        conversationRepository.delete(conv);
    }

    public List<Conversation> getUserConversations(UUID userId) {
        List<Conversation> conversations = conversationRepository.findByClientIdOrSellerId(userId, userId);
        // Force fetch of lazy-loaded relationships
        conversations.forEach(conv -> {
            if (conv.getProperty() != null)
                conv.getProperty().getTitle();
            if (conv.getSeller() != null) {
                conv.getSeller().getName();
                // Profile doesn't have profilePicture field, skip it
            }
            if (conv.getClient() != null) {
                conv.getClient().getName();
            }
            if (conv.getMessages() != null && !conv.getMessages().isEmpty()) {
                conv.getMessages().size(); // Force fetch messages
            }
        });
        return conversations;
    }

    public List<Message> getConversationMessages(UUID conversationId) {
        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
    }

    public Conversation createConversation(UUID propertyId, String clientEmail) {
        Property property = propertyRepository.findById(propertyId).orElseThrow();
        User client = userRepository.findByEmail(clientEmail).orElseThrow();
        User seller = property.getSeller();
        return conversationRepository.findByPropertyAndClient(property, client).orElseGet(() -> {
            Conversation conversation = new Conversation();
            conversation.setProperty(property);
            conversation.setClient(client);
            conversation.setSeller(seller);
            return conversationRepository.save(conversation);
        });
    }

    public Conversation getConversationByPropertyAndClient(UUID propertyId, UUID userId) {
        Property property = propertyRepository.findById(propertyId).orElseThrow();
        User client = userRepository.findById(userId).orElseThrow();
        return conversationRepository.findByPropertyAndClient(property, client)
                .orElse(null);
    }

    @Transactional
    public void saveMessage(Message message) {
        messageRepository.save(message);
    }

    @Transactional
    public Message editMessage(Long messageId, String newContent, UUID userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new RuntimeException("Message not found"));

        // Only sender can edit
        if (!message.getSender().getId().equals(userId)) {
            throw new RuntimeException("You are not allowed to edit this message");
        }

        message.setBody(newContent);
        return messageRepository.save(message);
    }

    @Transactional
    public void deleteMessage(Long messageId, UUID userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new RuntimeException("Message not found"));

        // Only sender can delete
        if (!message.getSender().getId().equals(userId)) {
            throw new RuntimeException("You are not allowed to delete this message");
        }

        messageRepository.delete(message);
    }
    public List<Conversation> getAllConversations(){
        return conversationRepository.findAll();
    }
}
