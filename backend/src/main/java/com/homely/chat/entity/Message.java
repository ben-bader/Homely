package com.homely.chat.entity;

import java.time.Instant;
import java.util.Map;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import com.homely.common.enums.MessageType;
import com.homely.common.enums.ReadStatus;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "conversation_id", nullable = false)
    private Conversation conversation;

    @ManyToOne
    @JoinColumn(name = "sender_id")
    private User sender;

    @Column(name = "body")
    private String text;

    public String getBody() {
        return text;
    }

    public void setBody(String body) {
        this.text = body;
    }

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MessageType type = MessageType.TEXT;

    @Enumerated(EnumType.STRING)
    @Column(name = "read_status", nullable = false)
    private ReadStatus readStatus = ReadStatus.UNREAD;

    @ManyToOne
    @JoinColumn(name = "property_id")
    private Property property;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "TEXT")
    private Map<String, Object> attachments;

    private Instant readAt;
    
    @CreationTimestamp
    @Column(updatable = false)
    private Instant createdAt;

    @org.hibernate.annotations.UpdateTimestamp
    private Instant updatedAt;
}
