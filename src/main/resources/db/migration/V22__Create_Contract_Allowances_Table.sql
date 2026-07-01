-- V22__Create_Contract_Allowances_Table.sql
-- Create mapping table between contracts and allowance types
CREATE TABLE IF NOT EXISTS contract_allowances (
    contract_id INT UNSIGNED NOT NULL,
    allowance_type_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (contract_id, allowance_type_id),
    CONSTRAINT fk_ca_contract FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE,
    CONSTRAINT fk_ca_allowance FOREIGN KEY (allowance_type_id) REFERENCES allowance_types(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Bảng mapping n-n giữa hợp đồng và các loại phụ cấp';
