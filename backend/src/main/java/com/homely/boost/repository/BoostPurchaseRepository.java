package com.homely.boost.repository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.homely.boost.entity.BoostPurchase;
import com.homely.common.enums.PurchaseStatus;

public interface BoostPurchaseRepository extends JpaRepository<BoostPurchase, UUID> {
    List<BoostPurchase> findBySellerId(UUID sellerId);

    List<BoostPurchase> findByStatus(PurchaseStatus status);
    
    // ✅ Find active boost for a property (not expired and approved status)
    @Query("""
        SELECT b FROM BoostPurchase b
        WHERE b.property.id = :propertyId
        AND b.status = 'APPROVED'
        AND b.expiryAt > :now
        ORDER BY b.createdAt DESC
        LIMIT 1
    """)
    BoostPurchase findActiveBoostByProperty(@Param("propertyId") UUID propertyId, @Param("now") Instant now);
    
    // ✅ Find all active boosts (for analytics, etc.)
    @Query("""
        SELECT b FROM BoostPurchase b
        WHERE b.status = 'APPROVED'
        AND b.expiryAt > :now
    """)
    List<BoostPurchase> findAllActiveBoosts(@Param("now") Instant now);
}

