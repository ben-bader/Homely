package com.homely.auth.service;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.homely.auth.dto.AuthResponse;
import com.homely.auth.dto.LoginRequest;
import com.homely.auth.dto.RegisterRequest;
import com.homely.user.entity.Profile;
import com.homely.user.entity.User;
import com.homely.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final TokenBlacklist tokenBlacklist;

    public AuthResponse register(RegisterRequest request){
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole());

        // Create profile automatically
        Profile profile = new Profile();
        profile.setUser(user);
        user.setProfile(profile);

        userRepository.save(user);
        return new AuthResponse(jwtService.generateToken(user));
    }

    public AuthResponse login(LoginRequest request){
        User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(()-> new RuntimeException("User not found"));    
        if(!passwordEncoder.matches(request.getPassword(), user.getPasswordHash()))   {
            throw  new RuntimeException("Invalid credentials");
        }   
        if (!user.isActive()) {
            throw new RuntimeException("User account is deactivated");
        }

        return new AuthResponse(jwtService.generateToken(user));
    }

    public void logout(String token) {
        if (token == null) return;
        if (token.startsWith("Bearer ")) token = token.substring(7);
        java.util.Date expiry = jwtService.extractExpiration(token);
        tokenBlacklist.blacklistToken(token, expiry);
    }
}
