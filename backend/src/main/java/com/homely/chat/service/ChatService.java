package com.homely.chat.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.homely.chat.dto.MessageDto;
import com.homely.chat.entity.Conversation;
import com.homely.chat.entity.Message;
import com.homely.chat.repository.ConversationRepository;
import com.homely.chat.repository.MessageRepository;
import com.homely.common.enums.MessageType;
import com.homely.common.enums.ReadStatus;
import com.homely.notification.dto.NotificationCreateRequest;
import com.homely.notification.service.NotificationService;
import com.homely.property.entity.Property;
import com.homely.property.repository.PropertyRepository;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChatService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final PropertyRepository propertyRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final ObjectMapper objectMapper;

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

        if (!isParticipant(conv, userRepository.findById(userId).orElseThrow())) {
            throw new RuntimeException("User not part of conversation");
        }

        long count = messageRepository.countByConversationId(conversationId);
        if (count > 0) {
            throw new RuntimeException("Conversation not empty");
        }

        conversationRepository.delete(conv);
    }

    @Transactional
    public List<Conversation> getUserConversations(UUID userId) {
        List<Conversation> conversations = conversationRepository.findByParticipantOneIdOrParticipantTwoId(userId);
        var dedupe = new java.util.LinkedHashMap<String, Conversation>();
        for (Conversation conv : conversations) {
            Conversation normalized = normalizeConversation(conv);
            String key = getConversationKey(normalized);
            if (dedupe.containsKey(key)) {
                dedupe.put(key, mergeConversations(dedupe.get(key), normalized));
            } else {
                dedupe.put(key, normalized);
            }
        }

        return new java.util.ArrayList<>(dedupe.values());
    }

    public List<Message> getConversationMessages(UUID conversationId) {
        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
    }

    public Conversation createConversation(UUID propertyId, String clientEmail) {
        Property property = propertyRepository.findById(propertyId).orElseThrow();
        User client = userRepository.findByEmail(clientEmail).orElseThrow();
        User seller = property.getSeller();
        Conversation conversation = findOrCreateConversation(client, seller);
        sharePropertyMessage(conversation, client, property);
        sendConversationCreatedNotification(client, seller, property, conversation);
        return conversation;
    }

    public Message sendMessage(MessageDto mdto, String senderEmail) {
        Conversation conversation;
        User sender = userRepository.findByEmail(senderEmail).orElseThrow(() -> new RuntimeException("Sender not found"));

        if (mdto.getConversationId() != null) {
            // Try to fetch by conversationId; if not found, log and attempt fallback
            try {
                conversation = getConversationById(mdto.getConversationId());
            } catch (Exception e) {
                log.warn("Conversation {} not found, attempting fallback recovery", mdto.getConversationId());
                // Fallback: if only conversationId is provided but not found, cannot proceed safely
                throw new RuntimeException("Conversation not found: " + mdto.getConversationId());
            }
        } else if (mdto.getPropertyId() != null) {
            // If no conversationId provided, create/find conversation between sender and property seller
            Property property = propertyRepository.findById(mdto.getPropertyId()).orElseThrow();
            User seller = property.getSeller();
            conversation = findOrCreateConversation(sender, seller);
        } else {
            // FALLBACK: Both conversationId and propertyId are null.
            // This should not happen in normal flow, but log and reject gracefully.
            log.error("Message send: both conversationId and propertyId are null from sender {}", senderEmail);
            throw new RuntimeException("Conversation id or property id required");
        }

        if (!isParticipant(conversation, sender)) {
            throw new RuntimeException("User not part of conversation");
        }

        Message message = new Message();
        message.setConversation(conversation);
        message.setSender(sender);
        message.setText(mdto.getText());
        message.setType(mdto.getMessageType() != null
                ? MessageType.valueOf(mdto.getMessageType())
                : MessageType.TEXT);
        message.setProperty(mdto.getPropertyId() != null
                ? propertyRepository.findById(mdto.getPropertyId()).orElseThrow()
                : null);
        message.setReadStatus(ReadStatus.UNREAD);
        message.setAttachments(mdto.getAttachments());

        saveMessage(message);
        return message;
    }

    public boolean isParticipant(Conversation conversation, User user) {
        return (conversation.getParticipantOne() != null && conversation.getParticipantOne().getId().equals(user.getId()))
                || (conversation.getParticipantTwo() != null && conversation.getParticipantTwo().getId().equals(user.getId()));
    }

    private Conversation findOrCreateConversation(User firstUser, User secondUser) {
        UUID firstId = firstUser.getId();
        UUID secondId = secondUser.getId();

        Optional<Conversation> conversationOpt = conversationRepository.findByParticipants(firstId, secondId);
        if (conversationOpt.isPresent()) {
            return normalizeConversation(conversationOpt.get());
        }

        Conversation conversation = new Conversation();
        if (firstId.compareTo(secondId) <= 0) {
            conversation.setParticipantOne(firstUser);
            conversation.setParticipantTwo(secondUser);
        } else {
            conversation.setParticipantOne(secondUser);
            conversation.setParticipantTwo(firstUser);
        }

        return conversationRepository.save(conversation);
    }

    private Conversation normalizeConversation(Conversation conversation) {
        boolean changed = false;
        if (conversation.getProperty() == null && conversation.getLastMessage() != null
                && conversation.getLastMessage().getProperty() != null) {
            conversation.setProperty(conversation.getLastMessage().getProperty());
            changed = true;
        }

        if (changed) {
            conversation = conversationRepository.save(conversation);
        }
        return conversation;
    }

    private Conversation mergeConversations(Conversation primary, Conversation duplicate) {
        if (primary.getId().equals(duplicate.getId())) {
            return primary;
        }

        // Ensure both conversations are normalized before merge
        primary = normalizeConversation(primary);
        duplicate = normalizeConversation(duplicate);

        if (primary.getProperty() == null && duplicate.getProperty() != null) {
            primary.setProperty(duplicate.getProperty());
        }
        if (primary.getParticipantOne() == null && duplicate.getParticipantOne() != null) {
            primary.setParticipantOne(duplicate.getParticipantOne());
        }
        if (primary.getParticipantTwo() == null && duplicate.getParticipantTwo() != null) {
            primary.setParticipantTwo(duplicate.getParticipantTwo());
        }

        if (duplicate.getMessages() != null && !duplicate.getMessages().isEmpty()) {
            for (Message message : duplicate.getMessages()) {
                message.setConversation(primary);
            }
            messageRepository.saveAll(duplicate.getMessages());
            if (primary.getMessages() != null) {
                primary.getMessages().addAll(duplicate.getMessages());
            }
        }

        Message newest = null;
        if (primary.getLastMessage() != null) {
            newest = primary.getLastMessage();
        }
        if (duplicate.getLastMessage() != null
                && (newest == null || duplicate.getLastMessage().getCreatedAt() != null
                        && duplicate.getLastMessage().getCreatedAt().isAfter(newest.getCreatedAt()))) {
            newest = duplicate.getLastMessage();
        }
        if (newest != null) {
            primary.setLastMessage(newest);
        }

        Conversation merged = conversationRepository.save(primary);
        if (!duplicate.getId().equals(merged.getId())) {
            conversationRepository.delete(duplicate);
        }
        return merged;
    }

    private String getConversationKey(Conversation conversation) {
        UUID first = null;
        UUID second = null;

        if (conversation.getParticipantOne() != null && conversation.getParticipantTwo() != null) {
            first = conversation.getParticipantOne().getId();
            second = conversation.getParticipantTwo().getId();
        }

        if (first == null || second == null) {
            return conversation.getId().toString();
        }

        return first.compareTo(second) <= 0
                ? first.toString() + ':' + second.toString()
                : second.toString() + ':' + first.toString();
    }

    private boolean hasPropertyShared(Conversation conversation, Property property) {
        return conversation.getMessages() != null && conversation.getMessages().stream()
                .anyMatch(m -> m.getType() == MessageType.PROPERTY_SHARE && m.getProperty() != null && m.getProperty().getId().equals(property.getId()));
    }

    private void sharePropertyMessage(Conversation conversation, User sender, Property property) {
        if (hasPropertyShared(conversation, property)) {
            return;
        }

        if (conversation.getProperty() == null) {
            conversation.setProperty(property);
        }

        Message propertyMessage = new Message();
        propertyMessage.setConversation(conversation);
        propertyMessage.setSender(sender);
        propertyMessage.setType(MessageType.PROPERTY_SHARE);
        propertyMessage.setText(property.getTitle());
        propertyMessage.setProperty(property);
        propertyMessage.setReadStatus(ReadStatus.UNREAD);
        messageRepository.save(propertyMessage);

        conversation.setLastMessage(propertyMessage);
        conversationRepository.save(conversation);

        sendChatMessageNotification(propertyMessage);
    }

    private void sendConversationCreatedNotification(User client, User seller, Property property, Conversation conversation) {
        try {
            var payloadMap = new java.util.HashMap<String, Object>();
            payloadMap.put("clientName", client.getName());
            payloadMap.put("clientEmail", client.getEmail());
            payloadMap.put("propertyTitle", property.getTitle());
            payloadMap.put("propertyId", property.getId().toString());
            payloadMap.put("conversationId", conversation.getId().toString());
            payloadMap.put("message", client.getName() + " wants to chat about " + property.getTitle());
            String payload = objectMapper.writeValueAsString(payloadMap);

            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(seller.getId());
            notificationRequest.setType("NEW_CONVERSATION");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);

            log.info("Conversation created notification sent to seller: {}", seller.getEmail());
        } catch (Exception e) {
            log.error("Failed to send conversation notification: {}", e.getMessage(), e);
        }
    }

    // Legacy property+client lookup removed; use participant-based conversation APIs

    @Transactional
    public void saveMessage(Message message) {
        Message saved = messageRepository.save(message);
        Conversation conversation = saved.getConversation();
        conversation.setLastMessage(saved);
        conversationRepository.save(conversation);

        sendChatMessageNotification(saved);
    }

    private void sendChatMessageNotification(Message message) {
        try {
            Conversation conversation = message.getConversation();
            User recipient = determineRecipient(conversation, message.getSender());
            if (recipient == null) {
                log.warn("Unable to determine recipient for chat notification, skipping notification");
                return;
            }

            String propertyTitle = null;
            String propertyId = null;
            if (message.getProperty() != null) {
                propertyTitle = message.getProperty().getTitle();
                propertyId = message.getProperty().getId().toString();
            } else if (conversation.getProperty() != null) {
                propertyTitle = conversation.getProperty().getTitle();
                propertyId = conversation.getProperty().getId().toString();
            }

            String preview = message.getText() != null ? message.getText() : "";
            if (message.getType() == MessageType.PROPERTY_SHARE) {
                preview = "Shared a property";
            }

            var payloadMap = new java.util.HashMap<String, Object>();
            payloadMap.put("senderName", message.getSender().getName());
            payloadMap.put("senderEmail", message.getSender().getEmail());
            payloadMap.put("propertyTitle", propertyTitle);
            payloadMap.put("propertyId", propertyId);
            payloadMap.put("conversationId", conversation.getId().toString());
            payloadMap.put("messagePreview", preview.length() > 100 ? preview.substring(0, 100) + "..." : preview);
            String payload = objectMapper.writeValueAsString(payloadMap);

            NotificationCreateRequest notificationRequest = new NotificationCreateRequest();
            notificationRequest.setUserId(recipient.getId());
            notificationRequest.setType("NEW_CHAT_MESSAGE");
            notificationRequest.setPayload(payload);
            notificationService.create(notificationRequest);

            log.info("Chat notification sent to: {}", recipient.getEmail());
        } catch (Exception e) {
            log.error("Failed to send chat notification: {}", e.getMessage(), e);
        }
    }

    private User determineRecipient(Conversation conversation, User sender) {
        if (conversation.getParticipantOne() != null && conversation.getParticipantOne().getId().equals(sender.getId())) {
            return conversation.getParticipantTwo();
        }
        if (conversation.getParticipantTwo() != null && conversation.getParticipantTwo().getId().equals(sender.getId())) {
            return conversation.getParticipantOne();
        }
        return null;
    }

    @Transactional
    public Message editMessage(Long messageId, String newContent, UUID userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new RuntimeException("Message not found"));

        // Only sender can edit
        if (!message.getSender().getId().equals(userId)) {
            throw new RuntimeException("You are not allowed to edit this message");
        }

        message.setText(newContent);
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
