-- V2__refactor_conversation_to_participant_based.sql
-- Refactor conversation architecture from property-based to participant-based.
-- This migration adds participant_one_id and participant_two_id if they don't exist,
-- and ensures the schema aligns with the new Conversation entity model.

-- Step 1: Add participant columns if they don't exist (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'conversation' AND column_name = 'participant_one_id'
  ) THEN
    ALTER TABLE conversation ADD COLUMN participant_one_id UUID;
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'conversation' AND column_name = 'participant_two_id'
  ) THEN
    ALTER TABLE conversation ADD COLUMN participant_two_id UUID;
  END IF;
END$$;

-- Step 2: Populate participant columns from legacy client/seller relationship
-- For each conversation with messages, derive participant_one and participant_two
UPDATE conversation c
SET
  participant_one_id = CASE
    WHEN m.sender_id IS NOT NULL THEN LEAST(m.sender_id, (SELECT m2.sender_id FROM message m2 WHERE m2.conversation_id = c.id AND m2.sender_id != m.sender_id LIMIT 1))
    ELSE c.participant_one_id
  END,
  participant_two_id = CASE
    WHEN m.sender_id IS NOT NULL THEN GREATEST(m.sender_id, (SELECT m2.sender_id FROM message m2 WHERE m2.conversation_id = c.id AND m2.sender_id != m.sender_id LIMIT 1))
    ELSE c.participant_two_id
  END
WHERE participant_one_id IS NULL
  AND EXISTS (SELECT 1 FROM message m WHERE m.conversation_id = c.id);

-- Step 3: For conversations with no messages, attempt to derive from property seller + latest interaction
-- This is a best-effort migration; some conversations may remain orphaned
UPDATE conversation c
SET
  participant_one_id = LEAST(COALESCE(c.participant_one_id, '00000000-0000-0000-0000-000000000000'::UUID), 
                              COALESCE(p.seller_id, '00000000-0000-0000-0000-000000000001'::UUID)),
  participant_two_id = GREATEST(COALESCE(c.participant_two_id, '00000000-0000-0000-0000-000000000000'::UUID),
                                COALESCE(p.seller_id, '00000000-0000-0000-0000-000000000001'::UUID))
WHERE participant_one_id IS NULL AND property_id IS NOT NULL
  AND EXISTS (SELECT 1 FROM property p WHERE p.id = c.property_id);

-- Step 4: Add foreign key constraints (if not already present)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY' AND table_name = 'conversation' AND constraint_name = 'fk_conversation_participant_one'
  ) THEN
    ALTER TABLE conversation
    ADD CONSTRAINT fk_conversation_participant_one
    FOREIGN KEY (participant_one_id) REFERENCES "user"(id) ON DELETE SET NULL;
  END IF;
END$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY' AND table_name = 'conversation' AND constraint_name = 'fk_conversation_participant_two'
  ) THEN
    ALTER TABLE conversation
    ADD CONSTRAINT fk_conversation_participant_two
    FOREIGN KEY (participant_two_id) REFERENCES "user"(id) ON DELETE SET NULL;
  END IF;
END$$;

-- Step 5: Ensure last_message_id foreign key exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_type = 'FOREIGN KEY' AND table_name = 'conversation' AND constraint_name = 'fk_conversation_last_message'
  ) THEN
    ALTER TABLE conversation
    ADD CONSTRAINT fk_conversation_last_message
    FOREIGN KEY (last_message_id) REFERENCES message(id) ON DELETE SET NULL;
  END IF;
END$$;

-- Step 6: Log migration status
-- (Optional: can be replaced with application logging)
-- Conversations migrated: SELECT COUNT(*) FROM conversation WHERE participant_one_id IS NOT NULL;
-- Conversations still missing participants: SELECT COUNT(*) FROM conversation WHERE participant_one_id IS NULL;
