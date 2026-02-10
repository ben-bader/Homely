package com.homely.chat.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.chat.entity.Conversation;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

public interface ConversationRepository extends JpaRepository<Conversation, UUID> {
    List<Conversation> findByClientIdOrSellerId(UUID ClientId, UUID SellerId);

    Optional<Conversation> findByPropertyAndClient(Property property,User client);

}
