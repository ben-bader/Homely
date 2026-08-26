-- Flyway Migration: Add OTP-based password reset
-- V5__refactor_password_reset_to_otp.sql

ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(6);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code_expiry TIMESTAMP;

-- Create index for faster reset code lookups
CREATE INDEX IF NOT EXISTS idx_users_reset_code ON users(reset_code) WHERE reset_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_reset_code_email ON users(email, reset_code) WHERE reset_code IS NOT NULL;

-- Mark any existing reset tokens as expired (for backward compatibility)
UPDATE users SET reset_code_expiry = CURRENT_TIMESTAMP 
WHERE reset_code_expiry IS NULL AND reset_token IS NOT NULL;

-- Add comments for documentation
COMMENT ON COLUMN users.reset_code IS '6-digit OTP code for password reset (valid for 15 minutes)';
COMMENT ON COLUMN users.reset_code_expiry IS 'Expiration timestamp of the reset code';
