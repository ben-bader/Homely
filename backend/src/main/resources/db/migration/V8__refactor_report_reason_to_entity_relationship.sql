-- V8: Refactor Report-ReportReason relationship from String to Foreign Key
-- This migration adds proper entity relationship between Report and ReportReason
-- with support for active/inactive status management.

-- Step 1: Add columns to report_reason table for better management (nullable first)
ALTER TABLE report_reason
ADD COLUMN IF NOT EXISTS name VARCHAR(255),
ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS description VARCHAR(1024);

-- Step 2: Populate 'name' from 'reason' if not already set
UPDATE report_reason 
SET name = reason 
WHERE name IS NULL;

-- Step 3: Populate 'active' to default true if not already set
UPDATE report_reason 
SET active = true 
WHERE active IS NULL;

-- Step 4: Populate 'description' to empty string if not already set
UPDATE report_reason 
SET description = '' 
WHERE description IS NULL;

-- Step 5: Now add NOT NULL constraints after data is populated
ALTER TABLE report_reason
ALTER COLUMN name SET NOT NULL;

ALTER TABLE report_reason
ALTER COLUMN active SET NOT NULL;

ALTER TABLE report_reason
ALTER COLUMN description SET NOT NULL;

-- Step 4: Add unique constraint on name (ensuring no duplicate reason names)
ALTER TABLE report_reason
DROP CONSTRAINT IF EXISTS report_reason_reason_key;

ALTER TABLE report_reason
ADD CONSTRAINT report_reason_name_unique UNIQUE (name);

-- Step 5: Insert default report reasons if the table is empty
INSERT INTO report_reason (reason, name, active, created_at, updated_at)
SELECT * FROM (
    VALUES 
        ('Inappropriate content', 'Inappropriate content', true),
        ('Spam', 'Spam', true),
        ('Harassment', 'Harassment', true),
        ('Scam or fraud', 'Scam or fraud', true),
        ('Offensive language', 'Offensive language', true),
        ('Fake or misleading', 'Fake or misleading', true),
        ('Copyright infringement', 'Copyright infringement', true),
        ('Other', 'Other', true)
) AS t(reason, name, active)
WHERE NOT EXISTS (SELECT 1 FROM report_reason)
ON CONFLICT DO NOTHING;

-- Step 6: Add foreign key column to report table
ALTER TABLE report
ADD COLUMN IF NOT EXISTS report_reason_id UUID;

-- Step 7: For existing reports with string reasons, try to match them to report_reason IDs
-- This handles the case where reports have string reasons that match report_reason.reason values
UPDATE report r
SET report_reason_id = rr.id
FROM report_reason rr
WHERE r.reason = rr.reason 
  AND r.report_reason_id IS NULL;

-- Step 8: For any remaining reports without a matched reason_id, assign to 'Other'
UPDATE report r
SET report_reason_id = (SELECT id FROM report_reason WHERE name = 'Other' LIMIT 1)
WHERE r.report_reason_id IS NULL;

-- Step 9: Make report_reason_id NOT NULL after populating
ALTER TABLE report
ALTER COLUMN report_reason_id SET NOT NULL;

-- Step 10: Add foreign key constraint
ALTER TABLE report
ADD CONSTRAINT fk_report_report_reason_id 
FOREIGN KEY (report_reason_id) 
REFERENCES report_reason(id) ON DELETE RESTRICT;

-- Step 11: Drop old reason string column from report (optional - keep for backward compatibility during transition)
-- ALTER TABLE report DROP COLUMN reason;

-- Note: The 'reason' column on Report entity will be replaced by the relationship to ReportReason
-- Migration does NOT drop the column to allow for a gradual transition.
-- Once the application code is deployed, the column can be dropped in a future migration.
