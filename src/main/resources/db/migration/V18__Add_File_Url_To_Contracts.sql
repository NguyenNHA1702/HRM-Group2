-- V18: Add file_url column to contracts table
ALTER TABLE contracts
    ADD COLUMN file_url VARCHAR(500) NULL COMMENT 'Đường dẫn file hợp đồng (URL hoặc path)' AFTER description;
