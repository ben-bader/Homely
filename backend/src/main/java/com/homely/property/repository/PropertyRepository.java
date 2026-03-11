package com.homely.property.repository;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.homely.common.enums.ListingType;
import com.homely.common.enums.PropertyType;
import com.homely.property.dto.PropertyDto;
import com.homely.property.entity.Property;

public interface PropertyRepository extends JpaRepository<Property, UUID>, JpaSpecificationExecutor<Property>  {

    // ✅ Homepage scroll
    List<Property> findAllByOrderByCreatedAtDesc();
    
    // ✅ Homepage scroll with boost sorting (boosted properties appear first)
    @Query("""
        SELECT p FROM Property p
        LEFT JOIN BoostPurchase b ON b.property.id = p.id AND b.status = 'APPROVED' AND b.expiryAt > :now
        ORDER BY CASE WHEN b.id IS NOT NULL THEN 0 ELSE 1 END ASC,
                 b.createdAt DESC,
                 p.createdAt DESC
    """)
    List<Property> findAllOrderByBoostThenCreatedAt(@Param("now") Instant now);

    // ✅ Seller properties
    List<Property> findBySellerEmail(String email);
    @Query("""
  select new com.homely.property.dto.PropertyDto(
    p.id, p.address, p.price, p.listingType, s.id
  )
  from Property p
  join p.seller s
  where p.id = :id
""")
Optional<PropertyDto> findPropertyDtoById(@Param("id") UUID id);

    // ✅ Filter (advanced filtering)
   @Query("""
    SELECT p FROM Property p
    WHERE (:listingType IS NULL OR p.listingType = :listingType)
    AND (:propertyType IS NULL OR p.propertyType = :propertyType)
    AND (:city IS NULL OR LOWER(p.address) LIKE LOWER(CONCAT('%', :city, '%')))
    AND (:minPrice IS NULL OR p.price >= :minPrice)
    AND (:maxPrice IS NULL OR p.price <= :maxPrice)
    AND (:fromDate IS NULL OR p.createdAt >= :fromDate)
    AND (:toDate IS NULL OR p.createdAt <= :toDate)
""")
List<Property> filter(
        @Param("listingType") ListingType listingType,
        @Param("propertyType") PropertyType propertyType,
        @Param("city") String city,
        @Param("minPrice") BigDecimal minPrice,
        @Param("maxPrice") BigDecimal maxPrice,
        @Param("fromDate") Instant fromDate,
        @Param("toDate") Instant toDate
);

    // ✅ GLOBAL SEARCH (search in EVERYTHING)
    @Query("""
        SELECT DISTINCT p FROM Property p
        LEFT JOIN p.apartment a
        LEFT JOIN p.house h
        LEFT JOIN p.villa v
        LEFT JOIN p.studio s
        LEFT JOIN p.commercial c
        LEFT JOIN p.land l
        WHERE
            LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(p.description) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(p.address) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(p.propertyType) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR LOWER(p.listingType) LIKE LOWER(CONCAT('%', :keyword, '%'))
            OR CAST(p.price as string) LIKE CONCAT('%', :keyword, '%')
    """)
    List<Property> globalSearch(@Param("keyword") String keyword);
}
