-- Thêm ràng buộc UNIQUE cho cột name trong bảng work_shifts
ALTER TABLE work_shifts ADD CONSTRAINT uk_work_shifts_name UNIQUE (name);
