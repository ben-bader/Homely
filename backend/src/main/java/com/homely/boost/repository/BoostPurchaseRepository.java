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

    @Query("""
        SELECT b FROM BoostPurchase b
        WHERE b.property.id = :propertyId
        AND b.status = 'COMPLETED'
        AND b.expiryAt > :now
        ORDER BY b.createdAt DESC
    """)
    BoostPurchase findActiveBoostByProperty(@Param("propertyId") UUID propertyId, @Param("now") Instant now);

    BoostPurchase findFirstByPropertyIdAndStatusAndExpiryAtAfterOrderByCreatedAtDesc(
            UUID propertyId,
            PurchaseStatus status,
            Instant expiryAt);

    List<BoostPurchase> findByStatusAndExpiryAtAfter(PurchaseStatus status, Instant expiryAt);
}

