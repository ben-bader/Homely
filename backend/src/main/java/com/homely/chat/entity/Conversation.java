package com.homely.chat.entity;

import java.util.ArrayList;
import java.util.List;

import com.homely.common.base.BaseEntity;
import com.homely.property.entity.Property;
import com.homely.user.entity.User;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.OneToOne;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
public class Conversation extends BaseEntity {

    @ManyToOne
    private Property property; // legacy property reference; preserve for migration compatibility

    // legacy client/seller fields removed in favor of participantOne/participantTwo
    @ManyToOne
    @JoinColumn(name = "participant_one_id")
    private User participantOne;

    @ManyToOne
    @JoinColumn(name = "participant_two_id")
    private User participantTwo;

    @OneToOne
    @JoinColumn(name = "last_message_id")
    private Message lastMessage;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL)
    private List<Message> messages = new ArrayList<>();

    public User getOtherParticipant(User user) {
        if (participantOne != null && participantOne.getId().equals(user.getId())) {
            return participantTwo;
        }
        if (participantTwo != null && participantTwo.getId().equals(user.getId())) {
            return participantOne;
        }
        return participantTwo;
    }
}
