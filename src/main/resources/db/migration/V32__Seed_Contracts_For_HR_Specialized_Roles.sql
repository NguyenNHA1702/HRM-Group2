-- ============================================================
-- V32: Bổ sung dữ liệu Hợp đồng lao động cho các tài khoản HR chuyên trách
-- (EMP_PAYROLL, EMP_CB, EMP_RECRUIT) để tính toán và hiển thị lương chính xác
-- ============================================================

INSERT INTO contracts (contract_number, employee_id, contract_type, start_date, end_date, base_salary, status, description)
SELECT 'HD2026-PAYROLL', id, 3, '2026-01-01', NULL, 15000000.00, 1, 'Hợp đồng lao động không thời hạn - HR Payroll Specialist'
FROM employees WHERE work_email = 'payroll@company.com'
AND NOT EXISTS (SELECT 1 FROM contracts WHERE contract_number = 'HD2026-PAYROLL');

INSERT INTO contracts (contract_number, employee_id, contract_type, start_date, end_date, base_salary, status, description)
SELECT 'HD2026-CB', id, 3, '2026-01-01', NULL, 15000000.00, 1, 'Hợp đồng lao động không thời hạn - HR C&B Specialist'
FROM employees WHERE work_email = 'cb@company.com'
AND NOT EXISTS (SELECT 1 FROM contracts WHERE contract_number = 'HD2026-CB');

INSERT INTO contracts (contract_number, employee_id, contract_type, start_date, end_date, base_salary, status, description)
SELECT 'HD2026-RECRUIT', id, 3, '2026-01-01', NULL, 14000000.00, 1, 'Hợp đồng lao động không thời hạn - HR Recruitment Specialist'
FROM employees WHERE work_email = 'recruitment@company.com'
AND NOT EXISTS (SELECT 1 FROM contracts WHERE contract_number = 'HD2026-RECRUIT');
