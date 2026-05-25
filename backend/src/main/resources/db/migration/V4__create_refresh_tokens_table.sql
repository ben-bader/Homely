-- Create refresh_tokens table for storing rotated refresh tokens
BEGIN;

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID NOT NULL,
  token VARCHAR(500) NOT NULL UNIQUE,
  user_id UUID NOT NULL,
  expiry_date TIMESTAMP NOT NULL,
  revoked BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  device_info VARCHAR(500),
  PRIMARY KEY (id)
);

-- Foreign key to users table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'refresh_tokens' AND constraint_name = 'fk_refresh_tokens_user'
  ) THEN
    ALTER TABLE refresh_tokens
    ADD CONSTRAINT fk_refresh_tokens_user
    FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE;
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);

COMMIT;
