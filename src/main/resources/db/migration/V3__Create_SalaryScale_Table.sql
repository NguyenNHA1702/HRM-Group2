-- 1. Tạo bảng thang bảng lương (Salary Scales)
CREATE TABLE IF NOT EXISTS salary_scales (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    grade         VARCHAR(50)  NOT NULL UNIQUE COMMENT 'Bậc lương (ví dụ: Level 1, Level 2...)',
    basic_salary  DECIMAL(15,2) NOT NULL COMMENT 'Lương cơ bản',
    allowance     DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT 'Phụ cấp',
    description   VARCHAR(255)  COMMENT 'Mô tả thang lương',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='Thang bảng lương nhân viên';

-- 2. Chèn dữ liệu mẫu nếu bảng chưa có dữ liệu
INSERT IGNORE INTO salary_scales (id, grade, basic_salary, allowance, description) VALUES
(1, 'L1_Intern', 5000000.00, 500000.00, 'Thực tập sinh doanh nghiệp'),
(2, 'L2_Junior', 12000000.00, 1000000.00, 'Nhân viên bậc Junior'),
(3, 'L3_Mid', 20000000.00, 2000000.00, 'Nhân viên bậc Mid-level'),
(4, 'L4_Senior', 35000000.00, 3000000.00, 'Nhân Chuyên viên bậc Senior'),
(5, 'L5_Manager', 50000000.00, 5000000.00, 'Cấp Quản lý / Trưởng phòng ban');
