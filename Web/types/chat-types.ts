export interface ChatMessageResponse {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  body: string;
  createdAt: string;
}

export interface Conversation {
  id: string;
  sellerName: string;
  clientName: string;
  propertyId: string;
  messages?: ChatMessageResponse[]; // optional, will load lazily
  loadingMessages?: boolean;
}