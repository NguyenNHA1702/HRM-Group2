-- 1. Tạo bảng nhóm quyền lớn
CREATE TABLE role_groups (
                             id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                             code        VARCHAR(20)  NOT NULL UNIQUE COMMENT 'ADMIN | HR | MANAGER | EMPLOYEE',
                             name        VARCHAR(50)  NOT NULL,
                             description VARCHAR(255),
                             created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) COMMENT='Nhóm role cấp cao';

-- 2. Tạo bảng danh mục vai trò chi tiết (10 chức danh con)
CREATE TABLE roles (
                       id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                       group_id    INT UNSIGNED NOT NULL COMMENT 'FK -> role_groups.id',
                       name        VARCHAR(50)  NOT NULL UNIQUE COMMENT 'HR Payroll | HR C&B | HR Director...',
                       description VARCHAR(255),
                       is_active   TINYINT(1)   NOT NULL DEFAULT 1,
                       created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                       updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       CONSTRAINT fk_role_group FOREIGN KEY (group_id) REFERENCES role_groups(id) ON DELETE RESTRICT
) COMMENT='Vai trò chi tiết chi phối hệ thống';

-- 3. Tạo bảng danh mục tính năng/màn hình
CREATE TABLE modules (
                         id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                         code          VARCHAR(50)  NOT NULL UNIQUE COMMENT 'USER_MGMT | RBAC | ATTENDANCE | PAYROLL...',
                         name          VARCHAR(100) NOT NULL,
                         is_admin_only TINYINT(1)  NOT NULL DEFAULT 0 COMMENT 'Hardlock: chỉ ADMIN mới được vào',
                         description   VARCHAR(255),
                         created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) COMMENT='Danh sách module hệ thống';

-- 4. Tạo bảng ma trận phân quyền dựa trên từng vai trò chi tiết
CREATE TABLE role_permissions (
                                  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                                  role_id     INT UNSIGNED NOT NULL,
                                  module_id   INT UNSIGNED NOT NULL,
                                  can_view    TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'Quyền Xem',
                                  can_create  TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'Quyền Tạo mới',
                                  can_edit    TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'Quyền Chỉnh sửa',
                                  can_delete  TINYINT(1)   NOT NULL DEFAULT 0 COMMENT 'Quyền Xóa',
                                  updated_by  INT UNSIGNED COMMENT 'Mã Admin cập nhật',
                                  updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  UNIQUE KEY uq_role_module (role_id, module_id),
                                  CONSTRAINT fk_rp_role   FOREIGN KEY (role_id)   REFERENCES roles(id) ON DELETE CASCADE,
                                  CONSTRAINT fk_rp_module FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
) COMMENT='Ma trận quyền chi tiết';