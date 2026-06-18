-- ============================================================
-- V19: Seed Leave Balances
-- Khởi tạo quỹ phép ban đầu cho tất cả nhân viên đang hoạt động
-- theo từng loại phép (leave_types) đang active.
-- Dùng INSERT IGNORE để tránh duplicate nếu chạy lại.
-- ============================================================

INSERT IGNORE INTO leave_balances (employee_id, leave_type_id, used_days, remaining_days)
SELECT
    e.id                                              AS employee_id,
    lt.id                                             AS leave_type_id,
    0.00                                              AS used_days,
    COALESCE(lt.days_per_year, 0)                     AS remaining_days
FROM employees e
         CROSS JOIN leave_types lt
WHERE e.status   = 'ACTIVE'
  AND lt.is_active = TRUE
  AND (lt.code != 'MATERNITY' OR LOWER(e.gender) IN ('nữ', 'nu', 'female', 'f'));
