-- Add read_status column for Message enum storage
BEGIN;

ALTER TABLE message ADD COLUMN IF NOT EXISTS read_status VARCHAR(50);
UPDATE message SET read_status = 'UNREAD' WHERE read_status IS NULL;
ALTER TABLE message ALTER COLUMN read_status SET DEFAULT 'UNREAD';
ALTER TABLE message ALTER COLUMN read_status SET NOT NULL;

COMMIT;