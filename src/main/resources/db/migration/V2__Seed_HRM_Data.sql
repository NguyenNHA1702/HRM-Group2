-- 1. Tắt kiểm tra khóa ngoại tạm thời
SET FOREIGN_KEY_CHECKS = 0;

-- Dùng DELETE FROM thay vì TRUNCATE để MySQL cho phép xóa dữ liệu bảng roles
-- đang được bảng user_accounts ở ngoài DB tham chiếu.
DELETE FROM role_permissions;
DELETE FROM modules;
DELETE FROM roles;
DELETE FROM role_groups;

-- Reset lại bộ đếm ID về 1 để đảm bảo các ID sinh ra luôn cố định từ 1 đến 10
ALTER TABLE role_groups AUTO_INCREMENT = 1;
ALTER TABLE roles AUTO_INCREMENT = 1;
ALTER TABLE modules AUTO_INCREMENT = 1;
ALTER TABLE role_permissions AUTO_INCREMENT = 1;

-- ==========================================================
-- NẠP DATA (Giữ nguyên cấu trúc ID để khớp 100% với file của trưởng nhóm)
-- ==========================================================

-- Nạp 4 nhóm cha
INSERT INTO role_groups (id, code, name, description) VALUES
                                                          (1, 'ADMIN', 'Admin', 'Ban quản trị hệ thống'),
                                                          (2, 'HR', 'HR', 'Phòng nhân sự'),
                                                          (3, 'MANAGER', 'Manager', 'Quản lý bộ phận'),
                                                          (4, 'EMPLOYEE', 'Employee', 'Khối nhân viên công ty');

-- Nạp 10 vai trò chi tiết (ID 1, 3, 7, 9 trùng khớp hoàn toàn với tài khoản test của trưởng nhóm)
INSERT INTO roles (id, group_id, name, description, is_active) VALUES
                                                                   (1, 1, 'Admin', 'Toàn quyền hệ thống', 1),
                                                                   (2, 2, 'HR Director', 'Giám đốc nhân sự', 1),
                                                                   (3, 2, 'HR Manager', 'Quản lý nhân sự tổng hợp', 1),
                                                                   (4, 2, 'HR Payroll', 'Chuyên viên lương', 1),
                                                                   (5, 2, 'HR C&B', 'Phúc lợi, chấm công', 1),
                                                                   (6, 2, 'HR Recruitment', 'Tuyển dụng', 1),
                                                                   (7, 3, 'Manager', 'Trưởng phòng', 1),
                                                                   (8, 3, 'Team Lead', 'Trưởng nhóm', 1),
                                                                   (9, 4, 'Employee', 'Nhân viên', 1),
                                                                   (10, 4, 'Intern', 'Thực tập sinh', 1);

-- Nạp 9 module chức năng hiển thị ở bảng ma trận
INSERT INTO modules (id, code, name, is_admin_only, description) VALUES
                                                                     (1, 'DASHBOARD', 'Dashboard', 0, 'Tổng quan hệ thống'),
                                                                     (2, 'EMPLOYEE_MGMT', 'Nhân viên', 0, 'Quản lý thông tin nhân sự'),
                                                                     (3, 'DEPT_MGMT', 'Phòng ban', 0, 'Quản lý cơ cấu phòng ban'),
                                                                     (4, 'ATTENDANCE', 'Chấm công', 0, 'Quản lý chấm công vào ra'),
                                                                     (5, 'LEAVE_MGMT', 'Nghỉ phép', 0, 'Quản lý đơn xin nghỉ phép'),
                                                                     (6, 'PAYROLL', 'Lương', 0, 'Quản lý cấu hình và bảng lương'),
                                                                     (7, 'USER_MGMT', 'Quản lý Users', 0, 'Quản lý tài khoản đăng nhập'),
                                                                     (8, 'RBAC', 'Phân quyền', 1, 'Cấu hình ma trận bảo mật'),
                                                                     (9, 'SYSTEM', 'Cấu hình hệ thống', 1, 'Thiết lập tham số hệ thống');

-- Bơm sẵn ma trận quyền cho các Role chính
INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete) VALUES
                                                                                                  (1,1,1,1,1,1), (1,2,1,1,1,1), (1,3,1,1,1,1), (1,4,1,1,1,1), (1,5,1,1,1,1), (1,6,1,1,1,1), (1,7,1,1,1,1), (1,8,1,1,1,1), (1,9,1,1,1,1),
                                                                                                  (3,1,1,0,0,0), (3,2,1,1,1,0), (3,3,1,1,1,0), (3,4,1,1,1,0), (3,5,1,1,1,0), (3,6,1,1,1,0), (3,7,0,0,0,0), (3,8,0,0,0,0), (3,9,0,0,0,0),
                                                                                                  (7,1,1,0,0,0), (7,2,1,0,0,0), (7,3,1,1,1,0), (7,4,1,1,0,0), (7,5,1,1,1,0), (7,6,0,0,0,0), (7,7,0,0,0,0), (7,8,0,0,0,0), (7,9,0,0,0,0),
                                                                                                  (9,1,1,0,0,0), (9,2,0,0,0,0), (9,3,0,0,0,0), (9,4,1,0,0,0), (9,5,1,1,0,0), (9,6,1,0,0,0), (9,7,0,0,0,0), (9,8,0,0,0,0), (9,9,0,0,0,0);

-- 2. Bật lại kiểm tra khóa ngoại hệ thống
SET FOREIGN_KEY_CHECKS = 1;