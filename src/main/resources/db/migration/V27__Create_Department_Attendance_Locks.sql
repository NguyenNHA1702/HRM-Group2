CREATE TABLE IF NOT EXISTS department_attendance_locks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    department_id INT UNSIGNED NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    is_locked BOOLEAN NOT NULL DEFAULT TRUE,
    locked_by INT UNSIGNED NULL,
    locked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_dept_year_month (department_id, year, month),
    CONSTRAINT fk_dept_lock_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    CONSTRAINT fk_dept_lock_by FOREIGN KEY (locked_by) REFERENCES employees(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
