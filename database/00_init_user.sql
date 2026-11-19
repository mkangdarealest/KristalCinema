-- ============================================================================
-- ĐỀ TÀI SỐ 6: ỨNG DỤNG ĐẶT VÉ XEM PHIM KRISTALCINEMA
-- FILE: 00_init_user.sql
-- MỤC ĐÍCH: KHỞI TẠO USER VÀ CẤP QUYỀN TRÊN ORACLE DATABASE 23ai (DBeaver / Docker)
-- ============================================================================

-- Lưu ý: Thực thi với tài khoản SYS hoặc SYSTEM (kết nối với quyền SYSDBA)
-- Nếu dùng Oracle 23ai Free Docker, container mặc định là FREEPDB1
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Xóa user cũ nếu đã tồn tại để tạo mới hoàn toàn
BEGIN
    EXECUTE IMMEDIATE 'DROP USER KRISTAL_CINEMA CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Bỏ qua nếu user chưa tồn tại
END;
/

-- Tạo User KRISTAL_CINEMA
CREATE USER KRISTAL_CINEMA IDENTIFIED BY "Kristal#2026"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

-- Cấp các quyền cốt lõi cho ứng dụng
GRANT CONNECT, RESOURCE TO KRISTAL_CINEMA;
GRANT CREATE SESSION TO KRISTAL_CINEMA;
GRANT CREATE TABLE TO KRISTAL_CINEMA;
GRANT CREATE VIEW TO KRISTAL_CINEMA;
GRANT CREATE SEQUENCE TO KRISTAL_CINEMA;
GRANT CREATE PROCEDURE TO KRISTAL_CINEMA;
GRANT CREATE TRIGGER TO KRISTAL_CINEMA;
GRANT UNLIMITED TABLESPACE TO KRISTAL_CINEMA;
GRANT EXECUTE ON DBMS_LOCK TO KRISTAL_CINEMA;

COMMIT;

-- Thông báo hoàn thành
PROMPT [OK] Đã tạo User KRISTAL_CINEMA và cấp quyền thành công trên Oracle 23ai!
