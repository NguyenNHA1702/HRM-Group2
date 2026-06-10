-- V18__Finalize_Payroll_And_Salary_Scales.sql
-- Create payrolls, payroll_details, attendance_summary, and employee_salary_history tables from scratch

-- 1. Create payrolls table (master record for the month)
CREATE TABLE IF NOT EXISTS payrolls (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    month INT NOT NULL,
    year INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT, APPROVED, PAID',
    total_employees INT NOT NULL DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    created_by INT UNSIGNED,
    approved_by INT UNSIGNED,
    approved_at DATETIME NULL,
    paid_by INT UNSIGNED NULL,
    paid_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_month_year (month, year),
    CONSTRAINT fk_payroll_created_by FOREIGN KEY (created_by) REFERENCES employees(id) ON DELETE SET NULL,
    CONSTRAINT fk_payroll_approved_by FOREIGN KEY (approved_by) REFERENCES employees(id) ON DELETE SET NULL,
    CONSTRAINT fk_payroll_paid_by FOREIGN KEY (paid_by) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Create payroll_details table (individual employee records)
CREATE TABLE IF NOT EXISTS payroll_details (
    id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    payroll_id INT UNSIGNED NOT NULL,
    employee_id INT UNSIGNED NOT NULL,
    
    basic_salary DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    allowance_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    insurance_deduction DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    tax_deduction DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    unpaid_leave_deduction DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    net_salary DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_pd_payroll FOREIGN KEY (payroll_id) REFERENCES payrolls(id) ON DELETE CASCADE,
    CONSTRAINT fk_pd_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY uq_payroll_employee (payroll_id, employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Create attendance_summary table
CREATE TABLE IF NOT EXISTS attendance_summary (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    standard_days DECIMAL(5,2) NOT NULL DEFAULT 26.00,
    actual_worked_days DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    paid_leave_days DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    unpaid_leave_days DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE KEY uq_employee_month_year (employee_id, month, year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tổng hợp công theo tháng của nhân viên';

-- Seed dummy data for testing payroll calculation
INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days)
SELECT id, 6, 2026, 26.00, 24.00, 1.00, 1.00 FROM employees WHERE id IN (1, 2, 3)
ON DUPLICATE KEY UPDATE actual_worked_days=24.00;

INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days)
SELECT id, 5, 2026, 26.00, 26.00, 0.00, 0.00 FROM employees WHERE id IN (1, 2, 3)
ON DUPLICATE KEY UPDATE actual_worked_days=26.00;

-- 4. Create employee_salary_history table
CREATE TABLE IF NOT EXISTS employee_salary_history (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    employee_id INT UNSIGNED NOT NULL,
    salary_scale_id INT UNSIGNED NOT NULL,
    effective_date DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (salary_scale_id) REFERENCES salary_scales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lịch sử áp dụng/thay đổi mức lương của nhân viên';
