package com.homely.auth.service;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.homely.auth.entity.RefreshToken;
import com.homely.auth.repository.RefreshTokenRepository;
import com.homely.user.entity.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;

    @Value("${jwt.refresh-expiration:604800000}")
    private long refreshTokenDurationMs;

    public RefreshToken createToken(User user, String deviceInfo) {
        var refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(generateRefreshToken());
        refreshToken.setExpiryDate(Instant.now().plusMillis(refreshTokenDurationMs));
        refreshToken.setDeviceInfo(deviceInfo != null ? deviceInfo : "unknown");
        return refreshTokenRepository.save(refreshToken);
    }

    @Transactional
    public RefreshToken rotateToken(RefreshToken token, String deviceInfo) {
        token.setRevoked(true);
        refreshTokenRepository.save(token);
        return createToken(token.getUser(), deviceInfo);
    }

    public Optional<RefreshToken> findByToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }

    public boolean isExpired(RefreshToken token) {
        return token.getExpiryDate().isBefore(Instant.now());
    }

    public void revoke(RefreshToken token) {
        token.setRevoked(true);
        refreshTokenRepository.save(token);
    }

    private String generateRefreshToken() {
        return UUID.randomUUID().toString() + "." + UUID.randomUUID().toString();
    }
}
