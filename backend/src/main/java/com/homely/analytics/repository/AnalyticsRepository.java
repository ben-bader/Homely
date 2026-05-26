package com.homely.analytics.repository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import org.springframework.stereotype.Repository;
import com.homely.common.enums.PropertyStatus;
import com.homely.common.enums.RoleType;
import com.homely.moderation.entity.LogActivity;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

@Repository
public class AnalyticsRepository {

    @PersistenceContext
    private EntityManager entityManager;

    public long countUsers() {
        return entityManager.createQuery("SELECT COUNT(u) FROM User u", Long.class).getSingleResult();
    }

    public long countUsersByRole(RoleType role) {
        return entityManager.createQuery("SELECT COUNT(u) FROM User u WHERE u.role = :role", Long.class)
                .setParameter("role", role)
                .getSingleResult();
    }

    public long countProperties() {
        return entityManager.createQuery("SELECT COUNT(p) FROM Property p", Long.class).getSingleResult();
    }

    public long countPropertiesByStatus(PropertyStatus status) {
        return entityManager.createQuery("SELECT COUNT(p) FROM Property p WHERE p.status = :status", Long.class)
                .setParameter("status", status)
                .getSingleResult();
    }

    public long countConversations() {
        return entityManager.createQuery("SELECT COUNT(c) FROM Conversation c", Long.class).getSingleResult();
    }

    public long countMessages() {
        return entityManager.createQuery("SELECT COUNT(m) FROM Message m", Long.class).getSingleResult();
    }

    public long countFavorites() {
        return entityManager.createQuery("SELECT COUNT(f) FROM Favorite f", Long.class).getSingleResult();
    }

    public long countNotifications() {
        return entityManager.createQuery("SELECT COUNT(n) FROM Notification n", Long.class).getSingleResult();
    }

    public long countReports() {
        return entityManager.createQuery("SELECT COUNT(r) FROM Report r", Long.class).getSingleResult();
    }

    public long countBoostPurchases() {
        return entityManager.createQuery("SELECT COUNT(bp) FROM BoostPurchase bp WHERE bp.status = com.homely.common.enums.PurchaseStatus.COMPLETED", Long.class)
                .getSingleResult();
    }

    public BigDecimal sumBoostRevenue() {
        BigDecimal result = entityManager.createQuery("SELECT SUM(bp.amount) FROM BoostPurchase bp WHERE bp.status = com.homely.common.enums.PurchaseStatus.COMPLETED", BigDecimal.class)
                .getSingleResult();
        return result != null ? result : BigDecimal.ZERO;
    }

    public long countActiveUsersSince(Instant since) {
        return entityManager.createQuery("SELECT COUNT(DISTINCT la.user) FROM LogActivity la WHERE la.activityType = com.homely.moderation.entity.LogActivity.ActivityType.LOGIN AND la.createdAt >= :since", Long.class)
                .setParameter("since", since)
                .getSingleResult();
    }

    public List<Instant> getUserRegistrationTimestamps() {
        return entityManager.createQuery("SELECT u.createdAt FROM User u WHERE u.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Instant> getPropertyCreationTimestamps() {
        return entityManager.createQuery("SELECT p.createdAt FROM Property p WHERE p.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Instant> getMessageCreationTimestamps() {
        return entityManager.createQuery("SELECT m.createdAt FROM Message m WHERE m.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Instant> getFavoriteCreationTimestamps() {
        return entityManager.createQuery("SELECT f.createdAt FROM Favorite f WHERE f.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Instant> getNotificationCreationTimestamps() {
        return entityManager.createQuery("SELECT n.createdAt FROM Notification n WHERE n.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Instant> getPropertyApprovalTimestamps() {
        return entityManager.createQuery("SELECT la.createdAt FROM LogActivity la WHERE la.activityType = com.homely.moderation.entity.LogActivity.ActivityType.APPROVE AND la.createdAt IS NOT NULL", Instant.class)
                .getResultList();
    }

    public List<Object[]> getPropertyCountByPropertyType() {
        return entityManager.createQuery("SELECT p.propertyType, COUNT(p) FROM Property p GROUP BY p.propertyType", Object[].class)
                .getResultList();
    }

    public List<Object[]> getPropertyCountByStatus() {
        return entityManager.createQuery("SELECT p.status, COUNT(p) FROM Property p GROUP BY p.status", Object[].class)
                .getResultList();
    }

    public List<Object[]> getPropertyCountByListingType() {
        return entityManager.createQuery("SELECT p.listingType, COUNT(p) FROM Property p GROUP BY p.listingType", Object[].class)
                .getResultList();
    }

    public List<String> getPropertyAddresses() {
        return entityManager.createQuery("SELECT p.address FROM Property p WHERE p.address IS NOT NULL", String.class)
                .getResultList();
    }

    public List<Object[]> getBoostRevenueByMonth() {
        return entityManager.createQuery("SELECT bp.createdAt, bp.amount FROM BoostPurchase bp WHERE bp.status = com.homely.common.enums.PurchaseStatus.COMPLETED", Object[].class)
                .getResultList();
    }

    public List<Object[]> getTopSellers() {
        // Returns Object[] representing: [User seller, BigDecimal totalRevenue]
        TypedQuery<Object[]> query = entityManager.createQuery(
                "SELECT bp.seller, SUM(bp.amount) FROM BoostPurchase bp WHERE bp.status = com.homely.common.enums.PurchaseStatus.COMPLETED GROUP BY bp.seller ORDER BY SUM(bp.amount) DESC",
                Object[].class);
        query.setMaxResults(10);
        return query.getResultList();
    }

    public long countConversationsWithMessages() {
        return entityManager.createQuery("SELECT COUNT(c) FROM Conversation c WHERE EXISTS (SELECT m FROM Message m WHERE m.conversation = c)", Long.class)
                .getSingleResult();
    }

    public List<Object[]> getMostActiveUsers() {
        // Returns Object[] representing: [User sender, Long messageCount]
        TypedQuery<Object[]> query = entityManager.createQuery(
                "SELECT m.sender, COUNT(m) FROM Message m GROUP BY m.sender ORDER BY COUNT(m) DESC",
                Object[].class);
        query.setMaxResults(10);
        return query.getResultList();
    }

    public List<Object[]> getMostViewedProperties() {
        // Returns Object[] representing: [Property property, Long viewCount]
        TypedQuery<Object[]> query = entityManager.createQuery(
                "SELECT pv.property, COUNT(pv) FROM PropertyView pv GROUP BY pv.property ORDER BY COUNT(pv) DESC",
                Object[].class);
        query.setMaxResults(10);
        return query.getResultList();
    }

    public List<Object[]> getMostFavoritedProperties() {
        // Returns Object[] representing: [Property property, Long favoriteCount]
        TypedQuery<Object[]> query = entityManager.createQuery(
                "SELECT f.property, COUNT(f) FROM Favorite f GROUP BY f.property ORDER BY COUNT(f) DESC",
                Object[].class);
        query.setMaxResults(10);
        return query.getResultList();
    }

    public long countApprovals() {
        return entityManager.createQuery("SELECT COUNT(la) FROM LogActivity la WHERE la.activityType = com.homely.moderation.entity.LogActivity.ActivityType.APPROVE", Long.class)
                .getSingleResult();
    }

    public long countRejections() {
        return entityManager.createQuery("SELECT COUNT(la) FROM LogActivity la WHERE la.activityType = com.homely.moderation.entity.LogActivity.ActivityType.REJECT", Long.class)
                .getSingleResult();
    }

    public List<Object[]> getModerationActivity() {
        // Returns Object[] representing: [User user, Long actionCount]
        TypedQuery<Object[]> query = entityManager.createQuery(
                "SELECT la.user, COUNT(la) FROM LogActivity la WHERE la.activityType IN (com.homely.moderation.entity.LogActivity.ActivityType.APPROVE, com.homely.moderation.entity.LogActivity.ActivityType.REJECT) GROUP BY la.user ORDER BY COUNT(la) DESC",
                Object[].class);
        query.setMaxResults(10);
        return query.getResultList();
    }

    public List<LogActivity> getRecentModerationLogs(int limit) {
        TypedQuery<LogActivity> query = entityManager.createQuery(
                "SELECT la FROM LogActivity la ORDER BY la.createdAt DESC",
                LogActivity.class);
        query.setMaxResults(limit);
        return query.getResultList();
    }
}
