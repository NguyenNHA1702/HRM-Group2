CREATE TABLE leave_types
(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    code VARCHAR(50) NOT NULL UNIQUE,

    name VARCHAR(100) NOT NULL,

    days_per_year INT NOT NULL DEFAULT 0,

    paid_percentage DECIMAL(5,2) NOT NULL DEFAULT 100,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leave_balances
(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    employee_id BIGINT NOT NULL,

    leave_type_id BIGINT NOT NULL,

    used_days DECIMAL(5,2) DEFAULT 0,

    remaining_days DECIMAL(5,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_lb_employee
        FOREIGN KEY(employee_id)
            REFERENCES employees(id),

    CONSTRAINT fk_lb_leave_type
        FOREIGN KEY(leave_type_id)
            REFERENCES leave_types(id)
);

CREATE TABLE leave_requests
(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    employee_id BIGINT NOT NULL,

    leave_type_id BIGINT NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE NOT NULL,

    total_days DECIMAL(5,2) NOT NULL,

    reason TEXT,

    status VARCHAR(30)
                         DEFAULT 'PENDING_MANAGER',

    reviewed_by BIGINT,

    reviewed_at TIMESTAMP NULL,

    review_comment TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_lr_employee
        FOREIGN KEY(employee_id)
            REFERENCES employees(id),

    CONSTRAINT fk_lr_leave_type
        FOREIGN KEY(leave_type_id)
            REFERENCES leave_types(id)
);

INSERT INTO leave_types
(code,name,days_per_year,paid_percentage)
VALUES
    ('ANNUAL','Nghỉ phép năm',12,100),

    ('SICK','Nghỉ ốm',10,100),

    ('UNPAID','Nghỉ không lương',365,0),

    ('MATERNITY','Nghỉ thai sản',180,100);