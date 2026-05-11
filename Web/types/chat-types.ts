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
  sellerId: string;
  sellerActive: boolean;
  clientName: string;
  clientId: string;
  clientActive: boolean;
  propertyId: string;
  propertyTitle: string;
  messages?: ChatMessageResponse[]; // optional, will load lazily
  loadingMessages?: boolean;
  createdAt: string;
}