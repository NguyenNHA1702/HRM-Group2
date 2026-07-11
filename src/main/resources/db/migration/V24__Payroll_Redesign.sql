-- V24__Payroll_Redesign.sql
-- Redesign payroll: contract-based salary, position-based allowances, 3-block display, department-based attendance lock, new approval flow

-- =========================================================================
-- 1. Position Allowances: phụ cấp cấu hình theo chức vụ
-- =========================================================================
CREATE TABLE IF NOT EXISTS position_allowances (
    position_id       INT UNSIGNED NOT NULL,
    allowance_type_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (position_id, allowance_type_id),
    CONSTRAINT fk_pa_position  FOREIGN KEY (position_id)       REFERENCES positions(id)       ON DELETE CASCADE,
    CONSTRAINT fk_pa_allowance FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Mapping n-n giữa chức vụ và loại phụ cấp';

-- =========================================================================
-- 2. Attendance Locks: thêm department_id để chốt công theo phòng ban
-- =========================================================================
ALTER TABLE attendance_locks ADD COLUMN department_id INT UNSIGNED NULL AFTER locked_by;
-- Create new unique key including department_id (uk_year_month will be dropped in V25 safely)
ALTER TABLE attendance_locks ADD UNIQUE KEY uq_year_month_dept (year, month, department_id);

-- =========================================================================
-- 3. Payroll Details: thêm cột cho 3 blocks data
-- =========================================================================
-- Block 1: Ngày công
ALTER TABLE payroll_details ADD COLUMN standard_days      DECIMAL(5,2)  DEFAULT 26.00 AFTER notes;
ALTER TABLE payroll_details ADD COLUMN actual_worked_days DECIMAL(5,2)  DEFAULT 0.00  AFTER standard_days;
ALTER TABLE payroll_details ADD COLUMN paid_leave_days    DECIMAL(5,2)  DEFAULT 0.00  AFTER actual_worked_days;
ALTER TABLE payroll_details ADD COLUMN unpaid_leave_days  DECIMAL(5,2)  DEFAULT 0.00  AFTER paid_leave_days;
ALTER TABLE payroll_details ADD COLUMN sick_leave_days    DECIMAL(5,2)  DEFAULT 0.00  AFTER unpaid_leave_days;

-- Block 2: Tách bảo hiểm chi tiết
ALTER TABLE payroll_details ADD COLUMN bhxh_deduction DECIMAL(15,2) DEFAULT 0.00 AFTER sick_leave_days;
ALTER TABLE payroll_details ADD COLUMN bhyt_deduction DECIMAL(15,2) DEFAULT 0.00 AFTER bhxh_deduction;
ALTER TABLE payroll_details ADD COLUMN bhtn_deduction DECIMAL(15,2) DEFAULT 0.00 AFTER bhyt_deduction;

-- Block 3: Lương trước thuế
ALTER TABLE payroll_details ADD COLUMN gross_salary DECIMAL(15,2) DEFAULT 0.00 AFTER bhtn_deduction;

-- Department tracking
ALTER TABLE payroll_details ADD COLUMN department_id INT UNSIGNED NULL AFTER gross_salary;
-- Position snapshot at generation time
ALTER TABLE payroll_details ADD COLUMN position_id INT UNSIGNED NULL AFTER department_id;

-- =========================================================================
-- 4. Payrolls: thêm cột cho flow duyệt mới (DRAFT → MANAGER_CONFIRMED → HR_FINALIZED)
-- =========================================================================
ALTER TABLE payrolls ADD COLUMN manager_confirmed_by INT UNSIGNED NULL;
ALTER TABLE payrolls ADD COLUMN manager_confirmed_at DATETIME     NULL;
ALTER TABLE payrolls ADD COLUMN hr_confirmed_by      INT UNSIGNED NULL;
ALTER TABLE payrolls ADD COLUMN hr_confirmed_at      DATETIME     NULL;
ALTER TABLE payrolls ADD COLUMN finalized_by         INT UNSIGNED NULL;
ALTER TABLE payrolls ADD COLUMN finalized_at         DATETIME     NULL;

-- =========================================================================
-- 5. Employee tax config: số người phụ thuộc cho tính giảm trừ gia cảnh
-- =========================================================================
ALTER TABLE employees ADD COLUMN num_dependents INT NOT NULL DEFAULT 0 COMMENT 'Số người phụ thuộc cho giảm trừ gia cảnh thuế TNCN';
