-- ============================================================
-- V26: Tái cấu trúc Module RBAC — Tách thành 12 module
-- Thêm 3 module mới tách từ EMPLOYEE_MGMT, ATTENDANCE, PAYROLL
-- ============================================================

-- Thêm 3 module mới (id tự tăng sau 9) (dùng IGNORE để tránh lỗi trùng lặp khi chạy lại)
INSERT IGNORE INTO modules (code, name, is_admin_only, description) VALUES
    ('CONTRACT_MGMT',  'Hợp đồng',       0, 'Quản lý hợp đồng lao động'),
    ('SCHEDULE_MGMT',  'Lịch làm việc',  0, 'Ca làm việc, ngày lễ, phân lịch'),
    ('SALARY_CONFIG',  'Cấu hình lương', 0, 'Thang bảng lương, phụ cấp, bảo hiểm');

-- ============================================================
-- SEED QUYỀN MẶC ĐỊNH CHO CÁC ROLE
-- Roles: 1=Admin, 2=HR Director, 3=HR Manager, 4=HR Payroll,
--        5=HR C&B, 6=HR Recruitment, 7=Manager, 8=Team Lead,
--        9=Employee, 10=Intern
-- ============================================================

-- ── ADMIN (role_id=1): toàn quyền tất cả module mới ─────────
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 1, id, 1, 1, 1, 1 FROM modules
WHERE code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=1;

-- ── HR DIRECTOR (role_id=2): toàn quyền tất cả module mới ───
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 2, id, 1, 1, 1, 1 FROM modules
WHERE code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=1;

-- ── HR MANAGER (role_id=3): CRU (không xóa) ─────────────────
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 3, id, 1, 1, 1, 0 FROM modules
WHERE code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;

-- ── HR PAYROLL (role_id=4): CONTRACT_MGMT=CRUD, SALARY_CONFIG=View ──
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 4, id, 1, 1, 1, 1 FROM modules WHERE code = 'CONTRACT_MGMT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=1;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 4, id, 1, 0, 0, 0 FROM modules WHERE code IN ('SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=1, can_create=0, can_edit=0, can_delete=0;

-- ── HR C&B (role_id=5): CONTRACT_MGMT=CRU, SALARY_CONFIG=CRUD, SCHEDULE_MGMT=CRU ──
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 5, id, 1, 1, 1, 0 FROM modules WHERE code = 'CONTRACT_MGMT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 5, id, 1, 1, 1, 0 FROM modules WHERE code = 'SCHEDULE_MGMT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 5, id, 1, 1, 1, 0 FROM modules WHERE code = 'SALARY_CONFIG'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;

-- ── HR RECRUITMENT (role_id=6): chỉ xem hợp đồng ────────────
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 6, id, 1, 0, 0, 0 FROM modules WHERE code = 'CONTRACT_MGMT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=0, can_edit=0, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 6, id, 0, 0, 0, 0 FROM modules WHERE code IN ('SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=0, can_create=0, can_edit=0, can_delete=0;

-- ── MANAGER (role_id=7): xem hợp đồng + lịch, không cấu hình lương ──
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 7, id, 1, 0, 0, 0 FROM modules WHERE code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT')
ON DUPLICATE KEY UPDATE can_view=1, can_create=0, can_edit=0, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 7, id, 0, 0, 0, 0 FROM modules WHERE code = 'SALARY_CONFIG'
ON DUPLICATE KEY UPDATE can_view=0, can_create=0, can_edit=0, can_delete=0;

-- ── TEAM LEAD (role_id=8): như Manager ───────────────────────
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 8, id, 1, 0, 0, 0 FROM modules WHERE code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT')
ON DUPLICATE KEY UPDATE can_view=1, can_create=0, can_edit=0, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 8, id, 0, 0, 0, 0 FROM modules WHERE code = 'SALARY_CONFIG'
ON DUPLICATE KEY UPDATE can_view=0, can_create=0, can_edit=0, can_delete=0;

-- ── EMPLOYEE (role_id=9) + INTERN (role_id=10): không có quyền gì ──
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT r.id, m.id, 0, 0, 0, 0
FROM (SELECT 9 AS id UNION SELECT 10) r
CROSS JOIN modules m
WHERE m.code IN ('CONTRACT_MGMT', 'SCHEDULE_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=0, can_create=0, can_edit=0, can_delete=0;
