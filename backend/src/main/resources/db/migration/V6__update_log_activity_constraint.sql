-- VXX__update_log_activity_constraint.sql

ALTER TABLE log_activity
DROP CONSTRAINT IF EXISTS log_activity_activity_type_check;

ALTER TABLE log_activity
ADD CONSTRAINT log_activity_activity_type_check
CHECK (
    activity_type IN (
        'LOGIN',
        'LOGOUT',
        'SIGNUP',
        'PASSWORD_RESET_REQUESTED',
        'PASSWORD_RESET_COMPLETED',
        'VERIFY_EMAIL_REQUESTED',
        'VERIFY_EMAIL_COMPLETED',
        'CREATE',
        'UPDATE',
        'DELETE',
        'SUSPEND',
        'REACTIVATE',
        'APPROVE',
        'REJECT',
        'REPORT_FILED',
        'REPORT_STATUS_CHANGED'
    )
);