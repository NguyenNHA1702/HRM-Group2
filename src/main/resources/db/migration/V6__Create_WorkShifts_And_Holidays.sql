-- V5: Tạo bảng work_shifts và holidays để quản lý ca làm việc và ngày lễ

-- 1. Tạo bảng ca làm việc (work_shifts)
CREATE TABLE IF NOT EXISTS work_shifts (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL COMMENT 'Tên ca làm việc',
    start_time  TIME         NOT NULL COMMENT 'Giờ check-in',
    end_time    TIME         NOT NULL COMMENT 'Giờ check-out',
    description VARCHAR(255) COMMENT 'Mô tả chi tiết ca làm việc',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='Danh mục ca làm việc';

-- 2. Tạo bảng ngày nghỉ lễ (holidays)
CREATE TABLE IF NOT EXISTS holidays (
    id                 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name               VARCHAR(100)  NOT NULL COMMENT 'Tên ngày nghỉ lễ',
    start_date         DATE          NOT NULL COMMENT 'Ngày bắt đầu nghỉ lễ',
    end_date           DATE          NOT NULL COMMENT 'Ngày kết thúc nghỉ lễ',
    salary_coefficient DECIMAL(3,2)  NOT NULL DEFAULT 1.00 COMMENT 'Hệ số nhân lương làm việc ngày lễ',
    description        VARCHAR(255)  COMMENT 'Mô tả chi tiết ngày lễ',
    created_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='Danh mục các ngày nghỉ lễ';

-- 3. Chèn dữ liệu mẫu cho work_shifts
INSERT IGNORE INTO work_shifts (id, name, start_time, end_time, description) VALUES
(1, 'Ca hành chính', '08:00:00', '17:00:00', 'Ca làm việc hành chính chuẩn văn phòng'),
(2, 'Ca sáng', '06:00:00', '14:00:00', 'Ca làm việc buổi sáng'),
(3, 'Ca chiều', '14:00:00', '22:00:00', 'Ca làm việc buổi chiều'),
(4, 'Ca tối/đêm', '22:00:00', '06:00:00', 'Ca làm việc ban đêm');

-- 4. Chèn dữ liệu mẫu cho holidays
INSERT IGNORE INTO holidays (id, name, start_date, end_date, salary_coefficient, description) VALUES
(1, 'Tết Dương Lịch', '2026-01-01', '2026-01-01', 3.00, 'Nghỉ Tết Dương Lịch 1 ngày'),
(2, 'Tết Nguyên Đán', '2026-02-15', '2026-02-21', 3.00, 'Nghỉ Tết Nguyên Đán truyền thống'),
(3, 'Giỗ Tổ Hùng Vương', '2026-04-26', '2026-04-26', 3.00, 'Giỗ Tổ Hùng Vương (10/3 âm lịch)'),
(4, 'Giải phóng miền Nam & Quốc tế Lao động', '2026-04-30', '2026-05-01', 3.00, 'Nghỉ lễ chiến thắng và lao động');
