-- V14: Tạo bảng quản lý lịch làm việc của nhân viên (employee_schedules)

CREATE TABLE IF NOT EXISTS employee_schedules (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id   INT UNSIGNED NOT NULL COMMENT 'FK -> employees.id',
    work_shift_id INT UNSIGNED NOT NULL COMMENT 'FK -> work_shifts.id',
    schedule_date DATE NOT NULL COMMENT 'Ngày làm việc',
    notes         VARCHAR(255) COMMENT 'Ghi chú lịch làm việc',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_emp_date (employee_id, schedule_date),
    CONSTRAINT fk_sched_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_sched_shift    FOREIGN KEY (work_shift_id) REFERENCES work_shifts(id) ON DELETE CASCADE
) COMMENT='Bảng phân lịch làm việc cho nhân viên';

-- Tạo bảng lịch sử thay đổi lịch làm việc (schedule_history) để phục vụ cho Change History Section
CREATE TABLE IF NOT EXISTS schedule_history (
    id             INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id    INT UNSIGNED NOT NULL,
    schedule_date  DATE NOT NULL,
    old_shift_name VARCHAR(100),
    new_shift_name VARCHAR(100),
    changed_by     VARCHAR(100) NOT NULL COMMENT 'Người thực hiện thay đổi',
    change_reason  VARCHAR(255),
    changed_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sh_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) COMMENT='Lịch sử thay đổi lịch làm việc';

-- Thêm dữ liệu mẫu lịch làm việc cho tháng 6/2026
-- Giả sử ID nhân viên chạy từ 1 trở đi (đã có từ Seed_HRM_Data)
INSERT IGNORE INTO employee_schedules (employee_id, work_shift_id, schedule_date, notes) VALUES
(1, 1, '2026-06-10', 'Ca hành chính chuẩn ngày thường'),
(1, 1, '2026-06-11', 'Ca hành chính chuẩn ngày thường'),
(1, 1, '2026-06-12', 'Ca hành chính chuẩn ngày thường'),
(2, 2, '2026-06-10', 'Ca sáng trực quầy'),
(2, 2, '2026-06-11', 'Ca sáng trực quầy'),
(3, 3, '2026-06-10', 'Ca chiều vận hành hệ thống'),
(3, 3, '2026-06-11', 'Ca chiều vận hành hệ thống'),
(3, 4, '2026-06-12', 'Ca tối trực server khẩn cấp');
