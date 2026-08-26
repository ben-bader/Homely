export interface ChatMessageResponse {
  id: number;
  conversationId: string;
  senderId: string;
  senderName: string;
  body: string;
  messageType?: string | null;
  propertyId?: string | null;
  propertyTitle?: string | null;
  propertyImageUrl?: string | null;
  propertyPrice?: string | null;
  propertyLocation?: string | null;
  readAt?: string | null;
  sentAt: string;
}

export interface Conversation {
  id: string;
  propertyId: string;
  participantOneId: string;
  participantTwoId: string;
  participantOneName: string;
  participantTwoName: string;
  participantOneAvatar?: string | null;
  participantTwoAvatar?: string | null;
  propertyTitle?: string | null;
  lastMessage?: string | null;
  lastMessageType?: string | null;
  lastMessageAt?: string | null;
  unreadCount?: number;
  createdAt: string;
  updatedAt?: string | null;
  messages?: ChatMessageResponse[];
}