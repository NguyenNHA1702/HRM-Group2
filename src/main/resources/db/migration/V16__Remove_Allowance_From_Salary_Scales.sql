-- V14: Remove allowance column from salary_scales
-- Since allowances are now handled via employee_allowances mapping
ALTER TABLE salary_scales DROP COLUMN allowance;
