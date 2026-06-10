-- V13: Refactor Employee Allowances to support multiple allowances per employee
CREATE TABLE IF NOT EXISTS employee_allowances (
    employee_id INT UNSIGNED NOT NULL,
    allowance_type_id INT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (employee_id, allowance_type_id),
    CONSTRAINT fk_ea_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    CONSTRAINT fk_ea_allowance FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id) ON DELETE CASCADE
) COMMENT='Bảng mapping n-n giữa nhân viên và các loại phụ cấp';

-- Migrate existing data
INSERT INTO employee_allowances (employee_id, allowance_type_id)
SELECT id, allowance_type_id
FROM employees
WHERE allowance_type_id IS NOT NULL;

-- Drop foreign key and column from employees
ALTER TABLE employees DROP FOREIGN KEY fk_emp_allowance_type;
ALTER TABLE employees DROP COLUMN allowance_type_id;
