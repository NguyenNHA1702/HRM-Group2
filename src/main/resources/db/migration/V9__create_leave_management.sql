-- ============================================================
-- V9: Leave Management Tables
-- Tương thích với schema context HRM v3
-- ============================================================

-- Drop in reverse FK order to avoid constraint errors
DROP TABLE IF EXISTS leave_requests;
DROP TABLE IF EXISTS leave_balances;
DROP TABLE IF EXISTS leave_types;

CREATE TABLE leave_types
(
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code          VARCHAR(50)  NOT NULL UNIQUE COMMENT 'ANNUAL | SICK | PERSONAL | UNPAID | MATERNITY',
    name          VARCHAR(100) NOT NULL,
    days_per_year INT          DEFAULT NULL COMMENT 'NULL nếu không giới hạn (ví dụ UNPAID)',
    is_paid       TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1 = tính tiền, 0 = không tính',
    is_active     BOOLEAN      DEFAULT TRUE,
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP
) COMMENT = 'Loại phép - tương thích với schema context';

CREATE TABLE leave_balances
(
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id    INT UNSIGNED  NOT NULL,
    leave_type_id  INT UNSIGNED  NOT NULL,
    used_days      DECIMAL(5, 2) DEFAULT 0 COMMENT 'Số ngày đã sử dụng',
    remaining_days DECIMAL(5, 2) DEFAULT 0 COMMENT 'Số ngày còn lại',
    created_at     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lb_employee
        FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE RESTRICT,
    CONSTRAINT fk_lb_leave_type
        FOREIGN KEY (leave_type_id) REFERENCES leave_types (id) ON DELETE RESTRICT,
    UNIQUE KEY uq_emp_leave_type (employee_id, leave_type_id)
) COMMENT = 'Số dư phép của từng nhân viên';

CREATE TABLE leave_requests
(
    id             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id    INT UNSIGNED  NOT NULL,
    leave_type_id  INT UNSIGNED  NOT NULL,
    start_date     DATE          NOT NULL,
    end_date       DATE          NOT NULL,
    total_days     DECIMAL(5, 2) NOT NULL COMMENT 'Tổng số ngày xin nghỉ',
    reason         TEXT COMMENT 'Lý do xin nghỉ',
    status         VARCHAR(30)   NOT NULL DEFAULT 'PENDING_MANAGER'
        COMMENT 'PENDING_MANAGER | APPROVED_MANAGER | REJECTED | PENDING_HR | APPROVED_HR | CANCELLED',
    reviewed_by    INT UNSIGNED COMMENT 'FK -> employees.id (người duyệt)',
    reviewed_at    DATETIME      NULL COMMENT 'Lúc duyệt',
    review_comment TEXT COMMENT 'Ghi chú duyệt',
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lr_employee
        FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE RESTRICT,
    CONSTRAINT fk_lr_leave_type
        FOREIGN KEY (leave_type_id) REFERENCES leave_types (id) ON DELETE RESTRICT,
    CONSTRAINT fk_lr_reviewed_by
        FOREIGN KEY (reviewed_by) REFERENCES employees (id) ON DELETE SET NULL,
    INDEX idx_lr_employee (employee_id),
    INDEX idx_lr_status (status),
    INDEX idx_lr_date (start_date, end_date)
) COMMENT = 'Đơn xin nghỉ phép';

-- ============================================================
-- DỮ LIỆU KHỞI TẠO
-- ============================================================

INSERT INTO leave_types (code, name, days_per_year, is_paid)
VALUES ('ANNUAL', 'Nghỉ phép năm', 12, 1),
       ('SICK', 'Nghỉ ốm', 30, 1),
       ('PERSONAL', 'Nghỉ việc riêng', 3, 0),
       ('UNPAID', 'Nghỉ không lương', NULL, 0),
       ('MATERNITY', 'Nghỉ thai sản', 180, 1);