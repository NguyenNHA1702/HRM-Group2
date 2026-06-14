-- V5: Liên kết nhân viên với Thang lương và Loại phụ cấp
ALTER TABLE employees
    ADD COLUMN salary_scale_id INT UNSIGNED NULL COMMENT 'FK -> salary_scales.id' AFTER position_id,
    ADD COLUMN allowance_type_id INT UNSIGNED NULL COMMENT 'FK -> allowance_types.id' AFTER salary_scale_id,
    ADD CONSTRAINT fk_emp_salary_scale FOREIGN KEY (salary_scale_id) REFERENCES salary_scales(id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_emp_allowance_type FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id) ON DELETE SET NULL;
