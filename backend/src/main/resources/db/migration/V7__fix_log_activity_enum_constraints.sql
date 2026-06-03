-- Flyway migration: rebuild log_activity enum constraints for activity_type and entity_type

ALTER TABLE log_activity
    DROP CONSTRAINT IF EXISTS log_activity_activity_type_check,
    DROP CONSTRAINT IF EXISTS log_activity_entity_type_check;

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

ALTER TABLE log_activity
    ADD CONSTRAINT log_activity_entity_type_check
    CHECK (
        entity_type IN (
            'USER',
            'PROPERTY',
            'REPORT',
            'ADMIN_ACTION',
            'SELLER_ACTION',
            'BUYER_ACTION'
        )
    );
