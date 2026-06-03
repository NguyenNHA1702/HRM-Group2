-- ============================================================
-- V12: Leave Management Views
-- ============================================================

CREATE OR REPLACE VIEW vw_leave_balance_current AS
SELECT
    lb.id,
    lb.employee_id,
    e.full_name,
    lt.id          AS leave_type_id,
    lt.code        AS leave_type_code,
    lt.name        AS leave_type_name,
    lt.days_per_year,
    lb.used_days,
    lb.remaining_days,
    lb.created_at
FROM leave_balances lb
         JOIN employees e   ON e.id  = lb.employee_id
         JOIN leave_types lt ON lt.id = lb.leave_type_id;