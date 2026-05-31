CREATE TABLE insurance_config
(
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    employee_id BIGINT NOT NULL,

    insurance_number VARCHAR(20) NOT NULL UNIQUE,

    bhxh_rate DECIMAL(5,2) NOT NULL,

    bhyt_rate DECIMAL(5,2) NOT NULL,

    bhtn_rate DECIMAL(5,2) NOT NULL,

    base_salary DECIMAL(15,2) NOT NULL,

    bhxh_amount DECIMAL(15,2) NOT NULL,

    bhyt_amount DECIMAL(15,2) NOT NULL,

    bhtn_amount DECIMAL(15,2) NOT NULL,

    total_amount DECIMAL(15,2) NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ic_employee
        FOREIGN KEY(employee_id)
            REFERENCES employees(id)
);

INSERT INTO insurance_config
(employee_id, insurance_number, bhxh_rate, bhyt_rate, bhtn_rate, base_salary, bhxh_amount, bhyt_amount, bhtn_amount, total_amount, is_active)
VALUES
    (1, 'BH000001', 8.00, 1.50, 1.00, 10000000.00, 800000.00, 150000.00, 100000.00, 1050000.00, TRUE),

    (2, 'BH000002', 8.00, 1.50, 1.00, 8000000.00, 640000.00, 120000.00, 80000.00, 840000.00, TRUE),

    (3, 'BH000003', 8.00, 1.50, 1.00, 12000000.00, 960000.00, 180000.00, 120000.00, 1260000.00, TRUE),

    (4, 'BH000004', 8.00, 1.50, 1.00, 9000000.00, 720000.00, 135000.00, 90000.00, 945000.00, TRUE),

    (5, 'BH000005', 8.00, 1.50, 1.00, 11000000.00, 880000.00, 165000.00, 110000.00, 1155000.00, TRUE);