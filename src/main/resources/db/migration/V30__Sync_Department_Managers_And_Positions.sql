-- V30__Sync_Department_Managers_And_Positions.sql
-- 1. Seed manager positions for departments that do not have manager positions
INSERT INTO positions (code, name, department_id, base_salary, allowance, is_active)
SELECT 'TESTDEPT_MGR', 'Trưởng phòng Test Department', 6, 20000000.00, 2000000.00, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM positions WHERE department_id = 6 AND (name LIKE '%Trưởng phòng%' OR code LIKE '%MGR%'))
AND EXISTS (SELECT 1 FROM departments WHERE id = 6);

INSERT INTO positions (code, name, department_id, base_salary, allowance, is_active)
SELECT 'IO_MGR', 'Trưởng phòng Hạ tầng và Vận hành', 7, 20000000.00, 2000000.00, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM positions WHERE department_id = 7 AND (name LIKE '%Trưởng phòng%' OR code LIKE '%MGR%'))
AND EXISTS (SELECT 1 FROM departments WHERE id = 7);

-- 2. Synchronize departments.manager_id with active employees holding manager positions
UPDATE departments d
JOIN employees e ON e.department_id = d.id AND e.status = 'ACTIVE'
JOIN positions p ON e.position_id = p.id AND p.department_id = d.id
SET d.manager_id = e.id
WHERE (p.name LIKE '%Trưởng phòng%' OR p.name LIKE '%Giám đốc%' OR p.name LIKE '%Manager%' OR p.name LIKE '%Kế toán trưởng%' OR p.code LIKE '%MGR%');

-- 3. Restore HR Manager role (role_id = 3) for HR department personnel if mistakenly set to role_id 7
UPDATE user_accounts ua
JOIN employees e ON ua.employee_id = e.id
SET ua.role_id = 3
WHERE e.id = 2 OR (e.position_id IN (2, 3) AND ua.role_id = 7);

-- 4. Complete Repair for all corrupted Vietnamese department names and descriptions
UPDATE departments SET name = 'Ban Giám Đốc', description = 'Ban lãnh đạo công ty' WHERE id = 1;
UPDATE departments SET name = 'Phòng Nhân Sự', description = 'Tuyển dụng, Lương, C&B' WHERE id = 2;
UPDATE departments SET name = 'Phòng Công Nghệ', description = 'Phát triển phần mềm' WHERE id = 3;
UPDATE departments SET name = 'Phòng Kế Toán', description = 'Thu chi, tài chính' WHERE id = 4;
UPDATE departments SET name = 'Phòng Kinh Doanh', description = 'Bán hàng, CSKH' WHERE id = 5;
UPDATE departments SET name = 'Hạ tầng và Vận hành Hệ thống', description = 'Infrastructure and Operations' WHERE id = 7;

-- 5. Complete Repair for all corrupted Vietnamese position names
UPDATE positions SET name = 'Trưởng phòng Nhân sự' WHERE id = 2;
UPDATE positions SET name = 'Chuyên viên Nhân sự' WHERE id = 3;
UPDATE positions SET name = 'Trưởng phòng IT' WHERE id = 4;
UPDATE positions SET name = 'Lập trình viên Backend' WHERE id = 5;
UPDATE positions SET name = 'Lập trình viên Frontend' WHERE id = 6;
UPDATE positions SET name = 'Kế toán trưởng' WHERE id = 7;
UPDATE positions SET name = 'Chuyên viên Kế toán' WHERE id = 8;
UPDATE positions SET name = 'Trưởng phòng Sales' WHERE id = 9;
UPDATE positions SET name = 'Nhân viên Sales' WHERE id = 10;

-- 6. Demote non-manager employees currently holding duplicate manager titles (e.g. IT department duplicate manager titles)
UPDATE employees e
JOIN departments d ON e.department_id = d.id
SET e.position_id = 5 -- Lập trình viên Backend / Staff position for IT
WHERE d.id = 3 AND d.manager_id IS NOT NULL AND e.id != d.manager_id AND e.position_id = 4;