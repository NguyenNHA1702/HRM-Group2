-- V4: Thêm cột is_active vào salary_scales + Tạo bảng allowance_types
-- Chạy file này trong MySQL Workbench / DBeaver

-- 1. Thêm cột is_active vào bảng salary_scales nếu chưa có
ALTER TABLE salary_scales
    ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1=Đang dùng, 0=Vô hiệu hóa'
    AFTER description;

-- 2. Tạo bảng loại phụ cấp (allowance_types)
CREATE TABLE IF NOT EXISTS allowance_types (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(50)   NOT NULL UNIQUE COMMENT 'Mã phụ cấp (ví dụ: LUNCH, TRANSPORT...)',
    name        VARCHAR(100)  NOT NULL COMMENT 'Tên loại phụ cấp',
    amount      DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Mức tiền phụ cấp (VNĐ)',
    description VARCHAR(255)  COMMENT 'Mô tả chi tiết loại phụ cấp',
    is_active   TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1=Đang áp dụng, 0=Vô hiệu hóa',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='Danh mục loại phụ cấp nhân viên';

-- 3. Chèn dữ liệu mẫu allowance_types
INSERT IGNORE INTO allowance_types (id, code, name, amount, description, is_active) VALUES
(1, 'LUNCH',     'Phụ cấp ăn trưa',         730000.00, 'Phụ cấp ăn trưa theo ngày làm việc trong tháng', 1),
(2, 'TRANSPORT', 'Phụ cấp đi lại',          500000.00, 'Hỗ trợ chi phí đi lại đến văn phòng', 1),
(3, 'PHONE',     'Phụ cấp điện thoại',      300000.00, 'Hỗ trợ chi phí điện thoại công việc', 1),
(4, 'HOUSING',   'Phụ cấp nhà ở',          1000000.00, 'Hỗ trợ chi phí thuê nhà cho nhân viên xa nhà', 1),
(5, 'OVERTIME',  'Phụ cấp làm thêm giờ',   200000.00, 'Phụ cấp cho mỗi ca làm thêm giờ được duyệt', 1),
(6, 'HAZARD',    'Phụ cấp độc hại',         800000.00, 'Phụ cấp cho môi trường làm việc đặc thù', 0);
