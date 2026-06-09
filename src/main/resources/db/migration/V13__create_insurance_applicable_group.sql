-- V13__create_insurance_applicable_group.sql
-- Tạo bảng lưu đối tượng áp dụng bảo hiểm của công ty

CREATE TABLE IF NOT EXISTS insurance_applicable_group (
                                                          id               INT AUTO_INCREMENT PRIMARY KEY,
                                                          name             VARCHAR(200)  NOT NULL COMMENT 'Tên nhóm đối tượng',
    description      TEXT                   COMMENT 'Mô tả chi tiết điều kiện áp dụng',
    condition_detail VARCHAR(500)            COMMENT 'Điều kiện ngắn gọn hiển thị trên bảng',
    sort_order       INT          DEFAULT 0  COMMENT 'Thứ tự hiển thị',
    is_active        TINYINT(1)   DEFAULT 1  COMMENT '1 = Đang áp dụng, 0 = Đã dừng',
    created_at       DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    COMMENT='Đối tượng áp dụng bảo hiểm bắt buộc của công ty';

-- Seed dữ liệu mặc định theo quy định pháp luật Việt Nam
INSERT INTO insurance_applicable_group (name, description, condition_detail, sort_order, is_active) VALUES
                                                                                                        (
                                                                                                            'Nhân sự chính thức (HĐLĐ từ đủ 1 tháng trở lên)',
                                                                                                            'Bao gồm người làm việc theo Hợp đồng lao động (HĐLĐ) không xác định thời hạn và xác định thời hạn từ đủ 1 tháng trở lên. Áp dụng đầy đủ BHXH, BHYT, BHTN theo quy định.',
                                                                                                            'HĐLĐ ≥ 1 tháng — BHXH + BHYT + BHTN',
                                                                                                            1,
                                                                                                            1
                                                                                                        ),
                                                                                                        (
                                                                                                            'Người quản lý doanh nghiệp',
                                                                                                            'Giám đốc, Quản lý điều hành có nhận tiền lương từ công ty. Tham gia BHXH bắt buộc theo Luật BHXH 2014, điều 2.',
                                                                                                            'Giám đốc / Quản lý có nhận lương — BHXH bắt buộc',
                                                                                                            2,
                                                                                                            1
                                                                                                        );