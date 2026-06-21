-- V21: Cập nhật vai trò đúng cho tài khoản Admin và HR Manager
-- Admin: role_id = 1 (ADMIN)
-- nhan.tt (HR): role_id = 3 (HR Manager - HR)

UPDATE user_accounts SET role_id = 1 WHERE username = 'admin';
UPDATE user_accounts SET role_id = 3 WHERE username = 'nhan.tt';
