package com.homely.selleranalytics.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.homely.chat.entity.Conversation;
import com.homely.chat.repository.ConversationRepository;
import com.homely.chat.repository.MessageRepository;
import com.homely.property.dto.PropertyDto;
import com.homely.property.service.PropertyService;
import com.homely.propertyview.repository.PropertyViewRepository;
import com.homely.selleranalytics.dto.MessagesOverTimeDto;
import com.homely.selleranalytics.dto.PropertyPerformanceDto;
import com.homely.selleranalytics.dto.SellerAnalyticsDto;
import com.homely.selleranalytics.dto.ViewsOverTimeDto;
import com.homely.user.entity.User;
import com.homely.user.service.UserService;
import com.homely.visitrequest.repository.VisitRequestRepository;

import lombok.RequiredArgsConstructor;

/**
 * Service for aggregating and calculating seller analytics
 * Provides insights into property performance, engagement metrics, and conversion rates
 */
@Service
@RequiredArgsConstructor
public class SellerAnalyticsService {
    
    private final PropertyService propertyService;
    private final PropertyViewRepository propertyViewRepository;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final VisitRequestRepository visitRequestRepository;
    private final UserService userService;
    
    /**
     * Get comprehensive analytics for a seller
     * Includes listings count, views, messages, visit requests, and top performing properties
     */
    public SellerAnalyticsDto getSellerAnalytics(String sellerEmail) {
        User seller = userService.getByEmail(sellerEmail);
        
        if (seller == null) {
            throw new IllegalArgumentException("Seller not found with email: " + sellerEmail);
        }
        
        // Get all properties for this seller
        List<PropertyDto> allProperties = propertyService.getBySellerEmail(sellerEmail);
        
        // Filter to active properties (not DRAFT)
        List<PropertyDto> activeProperties = allProperties.stream()
                .filter(p -> p.getStatus() != null && !p.getStatus().name().equals("DRAFT"))
                .collect(Collectors.toList());
        
        // Calculate metrics
        Long totalListings = (long) allProperties.size();
        Long activeListings = (long) activeProperties.size();
        
        // Get total views across all properties
        Long totalViews = 0L;
        for (PropertyDto property : allProperties) {
            if (property.getId() != null) {
                totalViews += propertyViewRepository.countByPropertyId(property.getId());
            }
        }
        
        // Get total messages for all conversations involving this seller's properties
        Long totalMessages = 0L;
        for (PropertyDto property : allProperties) {
            if (property.getId() != null) {
                List<Conversation> conversations = conversationRepository.findByClientIdOrSellerId(seller.getId(), seller.getId());
                for (Conversation conversation : conversations) {
                    if (conversation.getProperty().getId().equals(property.getId())) {
                        totalMessages += messageRepository.countByConversationId(conversation.getId());
                    }
                }
            }
        }
        
        // Get total visit requests
        Long totalVisitRequests = 0L;
        for (PropertyDto property : allProperties) {
            if (property.getId() != null) {
                totalVisitRequests += (long) visitRequestRepository.findByPropertyId(property.getId()).size();
            }
        }
        
        // Calculate conversion rate (views to messages)
        BigDecimal conversionRate = BigDecimal.ZERO;
        if (totalViews > 0) {
            conversionRate = new BigDecimal(totalMessages)
                    .divide(new BigDecimal(totalViews), 2, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal(100)); // Convert to percentage
        }
        
        // Get top performing properties (top 5)
        List<PropertyPerformanceDto> topProperties = getTopPerformingProperties(allProperties, 5, seller.getId());
        
        return SellerAnalyticsDto.builder()
                .totalListings(totalListings)
                .activeListings(activeListings)
                .totalViews(totalViews)
                .totalMessages(totalMessages)
                .totalVisitRequests(totalVisitRequests)
                .conversionRate(conversionRate)
                .topPerformingProperties(topProperties)
                .build();
    }
    
    /**
     * Get views over time for a seller's properties (daily aggregation for last 30 days)
     */
    public List<ViewsOverTimeDto> getViewsOverTime(String sellerEmail) {
        User seller = userService.getByEmail(sellerEmail);
        
        if (seller == null) {
            throw new IllegalArgumentException("Seller not found with email: " + sellerEmail);
        }
        
        // This is a simplified implementation
        // In production, you'd want to query PropertyView entities with date grouping
        // For now, return empty list as placeholder
        return List.of();
    }
    
    /**
     * Get messages over time for a seller (daily aggregation for last 30 days)
     */
    public List<MessagesOverTimeDto> getMessagesOverTime(String sellerEmail) {
        User seller = userService.getByEmail(sellerEmail);
        
        if (seller == null) {
            throw new IllegalArgumentException("Seller not found with email: " + sellerEmail);
        }
        
        // This is a simplified implementation
        // In production, you'd want to query Message entities with date grouping
        // For now, return empty list as placeholder
        return List.of();
    }
    
    /**
     * Get top performing properties for a seller
     * Ranked by total views and engagement
     */
    public List<PropertyPerformanceDto> getTopPerformingProperties(List<PropertyDto> properties, int limit, UUID sellerId) {
        return properties.stream()
                .filter(p -> p.getId() != null)
                .map(property -> {
                    Long viewCount = propertyViewRepository.countByPropertyId(property.getId());
                    
                    // Get message count for this property
                    Long messageCount = 0L;
                    List<Conversation> conversations = conversationRepository.findByClientIdOrSellerId(sellerId, sellerId);
                    for (Conversation conversation : conversations) {
                        if (conversation.getProperty() != null && conversation.getProperty().getId().equals(property.getId())) {
                            messageCount += messageRepository.countByConversationId(conversation.getId());
                        }
                    }
                    
                    // Get visit request count
                    Long visitRequestCount = (long) visitRequestRepository.findByPropertyId(property.getId()).size();
                    
                    return PropertyPerformanceDto.builder()
                            .propertyId(property.getId())
                            .propertyTitle(property.getTitle())
                            .viewCount(viewCount)
                            .messageCount(messageCount)
                            .visitRequestCount(visitRequestCount)
                            .build();
                })
                .sorted((a, b) -> Long.compare(b.getViewCount() + b.getMessageCount() + b.getVisitRequestCount(),
                        a.getViewCount() + a.getMessageCount() + a.getVisitRequestCount()))
                .limit(limit)
                .collect(Collectors.toList());
    }
}

