-- V17: Create Contracts Table
CREATE TABLE IF NOT EXISTS contracts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contract_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Số hợp đồng',
    employee_id INT UNSIGNED NOT NULL COMMENT 'FK -> employees.id',
    contract_type INT NOT NULL COMMENT '1: Thử việc, 2: Chính thức 1 năm, 3: Không thời hạn, 4: Thời vụ',
    start_date DATE NOT NULL COMMENT 'Ngày bắt đầu',
    end_date DATE NULL COMMENT 'Ngày kết thúc (NULL nếu không thời hạn)',
    base_salary DECIMAL(15,2) NOT NULL COMMENT 'Lương cơ bản',
    status INT NOT NULL COMMENT '1: Active, 2: Expired, 3: Terminated',
    description TEXT NULL COMMENT 'Mô tả chi tiết',
    file_url VARCHAR(500) NULL COMMENT 'Đường dẫn file hợp đồng (URL hoặc path)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_contracts_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng quản lý hợp đồng lao động';
