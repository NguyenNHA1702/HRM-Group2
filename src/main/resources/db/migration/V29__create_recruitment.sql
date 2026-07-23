-- ============================================================
-- V26: Recruitment Module (Job Vacancies & Candidates)
-- Luồng: OPEN/CLOSED vacancy, NEW -> INTERVIEWING -> OFFERED -> HIRED/REJECTED
-- ============================================================

CREATE TABLE IF NOT EXISTS job_vacancies
(
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title         VARCHAR(200) NOT NULL,
    department_id INT UNSIGNED NOT NULL,
    position_id   INT UNSIGNED NULL,
    description   TEXT,
    headcount     INT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Số lượng cần tuyển',
    status        VARCHAR(20)  NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN | CLOSED',
    created_by    INT UNSIGNED NULL,
    opened_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at     DATETIME     NULL,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_jv_department FOREIGN KEY (department_id) REFERENCES departments (id) ON DELETE RESTRICT,
    CONSTRAINT fk_jv_position FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE SET NULL,
    CONSTRAINT fk_jv_created_by FOREIGN KEY (created_by) REFERENCES employees (id) ON DELETE SET NULL,
    INDEX idx_jv_status (status),
    INDEX idx_jv_department (department_id)
) COMMENT = 'Vị trí tuyển dụng';

CREATE TABLE IF NOT EXISTS candidates
(
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    vacancy_id  INT UNSIGNED  NOT NULL,
    full_name   VARCHAR(150)  NOT NULL,
    email       VARCHAR(150),
    phone       VARCHAR(30),
    resume_url  VARCHAR(500),
    notes       TEXT,
    status      VARCHAR(20)   NOT NULL DEFAULT 'NEW'
        COMMENT 'NEW | INTERVIEWING | OFFERED | HIRED | REJECTED',
    applied_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by  INT UNSIGNED  NULL,
    employee_id INT UNSIGNED  NULL COMMENT 'Liên kết nhân viên khi HIRED',
    created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_c_vacancy FOREIGN KEY (vacancy_id) REFERENCES job_vacancies (id) ON DELETE RESTRICT,
    CONSTRAINT fk_c_updated_by FOREIGN KEY (updated_by) REFERENCES employees (id) ON DELETE SET NULL,
    CONSTRAINT fk_c_employee FOREIGN KEY (employee_id) REFERENCES employees (id) ON DELETE SET NULL,
    INDEX idx_c_vacancy (vacancy_id),
    INDEX idx_c_status (status)
) COMMENT = 'Hồ sơ ứng viên';

-- RBAC: thêm module Tuyển dụng
INSERT INTO modules (code, name, is_admin_only, description)
VALUES ('RECRUITMENT', 'Tuyển dụng', 0, 'Quản lý vị trí tuyển dụng và ứng viên');

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 1, id, 1, 1, 1, 1 FROM modules WHERE code = 'RECRUITMENT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=1;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 3, id, 1, 1, 1, 0 FROM modules WHERE code = 'RECRUITMENT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;

INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete)
SELECT 6, id, 1, 1, 1, 0 FROM modules WHERE code = 'RECRUITMENT'
ON DUPLICATE KEY UPDATE can_view=1, can_create=1, can_edit=1, can_delete=0;
