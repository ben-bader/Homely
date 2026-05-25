-- Add read_at timestamp column for message read tracking
BEGIN;

ALTER TABLE message ADD COLUMN IF NOT EXISTS read_at TIMESTAMP;

COMMIT;
