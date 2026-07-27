-- ============================================================
-- V31: Bổ sung tài khoản test và hoàn thiện quyền cho các vai trò chuyên trách HR
-- (HR Payroll, HR C&B, HR Recruitment) theo chuẩn Use Case Diagram
-- ============================================================

-- 1. Hoàn thiện ma trận phân quyền (role_permissions) cho 3 Role chuyên trách HR

-- ── HR PAYROLL (role_id = 4) ─────────────────────────────────
-- Quyền: Dashboard (Xem), Chấm công (Xem để Validate), Lương (Toàn quyền), Hợp đồng (Xem), Cấu hình lương (Xem/Gán)
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 4, id, 1, 1, 1, 1 FROM modules WHERE code = 'PAYROLL'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=1;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 4, id, 1, 0, 0, 0 FROM modules WHERE code IN ('DASHBOARD', 'ATTENDANCE', 'CONTRACT_MGMT', 'SALARY_CONFIG')
ON DUPLICATE KEY UPDATE can_view=1;

-- ── HR C&B (role_id = 5) ─────────────────────────────────────
-- Quyền: Dashboard, Chấm công, Nghỉ phép, Lịch làm việc, Cấu hình lương (Toàn quyền), Lương (Xem báo cáo)
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 5, id, 1, 1, 1, 0 FROM modules WHERE code IN ('ATTENDANCE', 'LEAVE_MGMT', 'SCHEDULE_MGMT', 'SALARY_CONFIG', 'CONTRACT_MGMT')
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 5, id, 1, 0, 0, 0 FROM modules WHERE code IN ('DASHBOARD', 'PAYROLL')
ON DUPLICATE KEY UPDATE can_view=1;

-- ── HR RECRUITMENT (role_id = 6) ─────────────────────────────
-- Quyền: Tuyển dụng (Toàn quyền), Dashboard & Hợp đồng (Xem)
INSERT IGNORE INTO modules (code, name, is_admin_only, description)
VALUES ('RECRUITMENT', 'Tuyển dụng', 0, 'Quản lý vị trí tuyển dụng và ứng viên');

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 6, id, 1, 1, 1, 0 FROM modules WHERE code = 'RECRUITMENT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 6, id, 1, 0, 0, 0 FROM modules WHERE code IN ('DASHBOARD', 'CONTRACT_MGMT')
ON DUPLICATE KEY UPDATE can_view=1;


-- 2. Tạo dữ liệu nhân viên (employees) test cho 3 role chuyên trách (nếu chưa có)
INSERT INTO employees (employee_code, full_name, work_email, personal_email, phone, gender, department_id, position_id, hire_date, status)
SELECT 'EMP_PAYROLL', 'HR Payroll Specialist', 'payroll@company.com', 'payroll@company.com', '0901234561', 'MALE', 2, 2, CURDATE(), 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM employees WHERE work_email = 'payroll@company.com');

INSERT INTO employees (employee_code, full_name, work_email, personal_email, phone, gender, department_id, position_id, hire_date, status)
SELECT 'EMP_CB', 'HR C&B Specialist', 'cb@company.com', 'cb@company.com', '0901234562', 'FEMALE', 2, 2, CURDATE(), 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM employees WHERE work_email = 'cb@company.com');

INSERT INTO employees (employee_code, full_name, work_email, personal_email, phone, gender, department_id, position_id, hire_date, status)
SELECT 'EMP_RECRUIT', 'HR Recruitment Specialist', 'recruitment@company.com', 'recruitment@company.com', '0901234563', 'FEMALE', 2, 2, CURDATE(), 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM employees WHERE work_email = 'recruitment@company.com');


-- 3. Tạo tài khoản đăng nhập (user_accounts) cho 3 role chuyên trách (pass mặc định test là 123456)
INSERT INTO user_accounts (employee_id, username, password_hash, role_id, is_active, force_reset_pwd)
SELECT id, 'payroll@company.com', '$2a$10$abcdefghijklmnopqrstuv', 4, 1, 0
FROM employees WHERE work_email = 'payroll@company.com'
AND NOT EXISTS (SELECT 1 FROM user_accounts WHERE username = 'payroll@company.com');

INSERT INTO user_accounts (employee_id, username, password_hash, role_id, is_active, force_reset_pwd)
SELECT id, 'cb@company.com', '$2a$10$abcdefghijklmnopqrstuv', 5, 1, 0
FROM employees WHERE work_email = 'cb@company.com'
AND NOT EXISTS (SELECT 1 FROM user_accounts WHERE username = 'cb@company.com');

INSERT INTO user_accounts (employee_id, username, password_hash, role_id, is_active, force_reset_pwd)
SELECT id, 'recruitment@company.com', '$2a$10$abcdefghijklmnopqrstuv', 6, 1, 0
FROM employees WHERE work_email = 'recruitment@company.com'
AND NOT EXISTS (SELECT 1 FROM user_accounts WHERE username = 'recruitment@company.com');
