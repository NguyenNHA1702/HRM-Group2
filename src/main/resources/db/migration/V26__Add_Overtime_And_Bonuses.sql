-- V26__Add_Overtime_And_Bonuses.sql
-- Thêm bảng overtime_records, payroll_bonuses và cột Block 3 vào payroll_details

-- =========================================================================
-- 1. Bảng overtime_records: lưu tăng ca từng ngày của từng nhân viên
-- =========================================================================
CREATE TABLE IF NOT EXISTS overtime_records (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT UNSIGNED NOT NULL,
    overtime_date   DATE NOT NULL,
    hours           DECIMAL(4,2) NOT NULL DEFAULT 0.00 COMMENT 'Số giờ tăng ca',
    overtime_type   VARCHAR(20) NOT NULL DEFAULT 'WEEKDAY' COMMENT 'WEEKDAY=ngày thường 150%, WEEKEND=chủ nhật 200%, HOLIDAY=ngày lễ 300%+100%',
    status          VARCHAR(20) NOT NULL DEFAULT 'APPROVED' COMMENT 'PENDING, APPROVED, REJECTED',
    created_by      INT UNSIGNED NULL,
    note            VARCHAR(255) NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ot_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_ot_created_by FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL,
    UNIQUE KEY uq_ot_emp_date (employee_id, overtime_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bảng ghi nhận tăng ca từng ngày, HR nhập trước khi generate payroll';

-- =========================================================================
-- 2. Bảng payroll_bonuses: lưu thưởng phát sinh theo tháng
-- =========================================================================
CREATE TABLE IF NOT EXISTS payroll_bonuses (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id     INT UNSIGNED NOT NULL,
    bonus_month     INT NOT NULL COMMENT 'Tháng áp dụng thưởng',
    bonus_year      INT NOT NULL COMMENT 'Năm áp dụng thưởng',
    bonus_type      VARCHAR(50) NOT NULL DEFAULT 'OTHER' COMMENT 'KPI, HOLIDAY, PERFORMANCE, OTHER',
    amount          DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    note            VARCHAR(255) NULL,
    created_by      INT UNSIGNED NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pb_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_pb_created_by FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Bảng thưởng phát sinh do HR nhập thủ công trước khi generate payroll';

-- =========================================================================
-- 3. Thêm cột Block 3 (Thu nhập bổ sung) vào payroll_details
-- =========================================================================
-- Overtime breakdown
ALTER TABLE payroll_details ADD COLUMN overtime_weekday_hours  DECIMAL(5,2)  DEFAULT 0.00 AFTER position_id;
ALTER TABLE payroll_details ADD COLUMN overtime_weekend_hours  DECIMAL(5,2)  DEFAULT 0.00 AFTER overtime_weekday_hours;
ALTER TABLE payroll_details ADD COLUMN overtime_holiday_hours  DECIMAL(5,2)  DEFAULT 0.00 AFTER overtime_weekend_hours;
ALTER TABLE payroll_details ADD COLUMN overtime_pay            DECIMAL(15,2) DEFAULT 0.00 AFTER overtime_holiday_hours;
-- Holiday work (làm ngày lễ — tự nhận diện từ attendance)
ALTER TABLE payroll_details ADD COLUMN holiday_work_days       DECIMAL(5,2)  DEFAULT 0.00 AFTER overtime_pay;
ALTER TABLE payroll_details ADD COLUMN holiday_work_pay        DECIMAL(15,2) DEFAULT 0.00 AFTER holiday_work_days;
-- Bonus
ALTER TABLE payroll_details ADD COLUMN bonus_amount            DECIMAL(15,2) DEFAULT 0.00 AFTER holiday_work_pay;
ALTER TABLE payroll_details ADD COLUMN bonus_note              VARCHAR(500)  NULL         AFTER bonus_amount;
