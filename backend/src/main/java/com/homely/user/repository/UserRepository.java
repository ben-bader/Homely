package com.homely.user.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.homely.common.enums.RoleType;
import com.homely.user.entity.User;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByEmailIgnoreCase(String email);

    List<User> findByRole(RoleType role);
    List<User> findByIsActive(boolean active);
    boolean existsByEmail(String email);
    boolean existsByEmailIgnoreCase(String email);
    Optional<User> findByVerificationToken(String token);
    
    // OTP-based password reset
    Optional<User> findByResetCodeAndEmailIgnoreCase(String resetCode, String email);
    Optional<User> findByResetCode(String resetCode);
    
    // Legacy fields (deprecated - use OTP methods instead)
    @Deprecated(forRemoval = true)
    Optional<User> findByResetToken(String token);
    
    @Deprecated(forRemoval = true)
    Optional<User> findByResetTokenAndEmailIgnoreCase(String resetToken, String email);
}
