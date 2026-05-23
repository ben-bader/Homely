package com.homely.selleranalytics.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.homely.selleranalytics.dto.MessagesOverTimeDto;
import com.homely.selleranalytics.dto.PropertyPerformanceDto;
import com.homely.selleranalytics.dto.SellerAnalyticsDto;
import com.homely.selleranalytics.dto.ViewsOverTimeDto;
import com.homely.selleranalytics.service.SellerAnalyticsService;

import lombok.RequiredArgsConstructor;

/**
 * REST Controller for Seller Analytics
 * Provides analytics and insights for property sellers
 */
@RestController
@RequestMapping("/api/seller/analytics")
@RequiredArgsConstructor
public class SellerAnalyticsController {
    
    private final SellerAnalyticsService sellerAnalyticsService;
    
    /**
     * GET /api/seller/analytics
     * Get comprehensive analytics dashboard for the authenticated seller
     * 
     * Returns:
     * - total listings
     * - active listings
     * - total views
     * - total messages received
     * - total visits requested
     * - conversion rate (views → messages)
     * - top performing properties
     */
    @GetMapping
    public ResponseEntity<SellerAnalyticsDto> getSellerAnalytics(Principal principal) {
        try {
            String sellerEmail = principal.getName();
            SellerAnalyticsDto analytics = sellerAnalyticsService.getSellerAnalytics(sellerEmail);
            return ResponseEntity.ok(analytics);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).build();
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * GET /api/seller/analytics/views-over-time
     * Get property views aggregated over time (daily) for the last 30 days
     */
    @GetMapping("/views-over-time")
    public ResponseEntity<List<ViewsOverTimeDto>> getViewsOverTime(Principal principal) {
        try {
            String sellerEmail = principal.getName();
            List<ViewsOverTimeDto> viewsOverTime = sellerAnalyticsService.getViewsOverTime(sellerEmail);
            return ResponseEntity.ok(viewsOverTime);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).build();
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * GET /api/seller/analytics/messages-over-time
     * Get messages received aggregated over time (daily) for the last 30 days
     */
    @GetMapping("/messages-over-time")
    public ResponseEntity<List<MessagesOverTimeDto>> getMessagesOverTime(Principal principal) {
        try {
            String sellerEmail = principal.getName();
            List<MessagesOverTimeDto> messagesOverTime = sellerAnalyticsService.getMessagesOverTime(sellerEmail);
            return ResponseEntity.ok(messagesOverTime);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).build();
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * GET /api/seller/analytics/top-properties
     * Get top performing properties for the seller (ranked by views and engagement)
     */
    @GetMapping("/top-properties")
    public ResponseEntity<List<PropertyPerformanceDto>> getTopProperties(Principal principal) {
        try {
            String sellerEmail = principal.getName();
            SellerAnalyticsDto analytics = sellerAnalyticsService.getSellerAnalytics(sellerEmail);
            return ResponseEntity.ok(analytics.getTopPerformingProperties());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(404).build();
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}
