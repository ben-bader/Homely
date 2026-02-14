package com.homely.auth.service;

import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class TokenBlacklist {
    private final Map<String, Date> blacklist = new ConcurrentHashMap<>();

    public void blacklistToken(String token, Date expiry) {
        if (token == null) return;
        blacklist.put(token, expiry != null ? expiry : new Date(System.currentTimeMillis()));
    }

    public boolean isBlacklisted(String token) {
        if (token == null) return false;
        Date expiry = blacklist.get(token);
        if (expiry == null) return false;
        if (expiry.before(new Date())) {
            blacklist.remove(token);
            return false;
        }
        return true;
    }

    // Cleanup expired tokens every hour
    @Scheduled(fixedDelay = 3600000)
    public void cleanup() {
        Date now = new Date();
        blacklist.entrySet().removeIf(e -> e.getValue().before(now));
    }
}
