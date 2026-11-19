-- ============================================================================
-- ĐỀ TÀI SỐ 6: ỨNG DỤNG ĐẶT VÉ XEM PHIM KRISTALCINEMA
-- FILE: 02_plsql_core.sql
-- MỤC ĐÍCH: CHỨA PACKAGE, PROCEDURES, FUNCTIONS VÀ TRIGGERS XỬ LÝ NGHIỆP VỤ LÕI
-- Kết nối dưới User: KRISTAL_CINEMA / Kristal#2026@localhost:1521/FREEPDB1
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PHẦN 1: PACKAGE SPECIFICATION (KHAI BÁO GÓI PKG_KRISTAL_BOOKING)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_KRISTAL_BOOKING AS

    -- 1. Giải phóng ghế đã hết hạn giữ tạm thời
    PROCEDURE SP_RELEASE_EXPIRED_HOLDS;

    -- 2. Giữ ghế tạm thời (Seat Holding) có thời hạn chống đụng độ
    PROCEDURE SP_HOLD_SEATS (
        p_showtime_id   IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2, -- Danh sách ghế ngăn cách bằng dấu phẩy, VD: 'D3,D4'
        p_user_id       IN  VARCHAR2,
        p_hold_minutes  IN  NUMBER DEFAULT 5,
        p_success       OUT NUMBER,   -- 1: Thành công, 0: Thất bại
        p_message       OUT VARCHAR2
    );

    -- 3. Tính toán giá vé theo loại ghế và kiểm tra Voucher khuyến mãi
    PROCEDURE SP_CALCULATE_PRICE_AND_VOUCHER (
        p_showtime_id   IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2,
        p_voucher_code  IN  VARCHAR2,
        p_subtotal      OUT NUMBER,
        p_discount      OUT NUMBER,
        p_total         OUT NUMBER,
        p_message       OUT VARCHAR2
    );

    -- 4. Xác nhận đặt vé và lưu hóa đơn, chi tiết vé
    PROCEDURE SP_CONFIRM_BOOKING (
        p_booking_id    IN  VARCHAR2,
        p_user_id       IN  VARCHAR2,
        p_showtime_id   IN  VARCHAR2,
        p_movie_title   IN  VARCHAR2,
        p_movie_poster  IN  VARCHAR2,
        p_cinema_name   IN  VARCHAR2,
        p_showtime_time IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2,
        p_voucher_code  IN  VARCHAR2,
        p_success       OUT NUMBER,
        p_total_price   OUT NUMBER,
        p_message       OUT VARCHAR2
    );

    -- 5. Lấy danh sách lịch sử đặt vé của một người dùng
    PROCEDURE SP_GET_USER_BOOKINGS (
        p_user_id       IN  VARCHAR2,
        p_cursor        OUT SYS_REFCURSOR
    );

    -- 6. Lấy thống kê tổng quan doanh thu và dữ liệu cho trang Admin
    PROCEDURE SP_ADMIN_GET_STATISTICS (
        p_total_revenue  OUT NUMBER,
        p_total_bookings OUT NUMBER,
        p_total_movies   OUT NUMBER,
        p_total_cinemas  OUT NUMBER
    );

END PKG_KRISTAL_BOOKING;
/

-- ----------------------------------------------------------------------------
-- PHẦN 2: PACKAGE BODY (TRIỂN KHAI CHI TIẾT NGHIỆP VỤ)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_KRISTAL_BOOKING AS

    -- ------------------------------------------------------------------------
    -- 1. GIẢI PHÓNG GHẾ HẾT HẠN GIỮ TẠM
    -- ------------------------------------------------------------------------
    PROCEDURE SP_RELEASE_EXPIRED_HOLDS IS
    BEGIN
        UPDATE SEATS
        SET STATUS = 'AVAILABLE',
            HELD_BY_USER_ID = NULL,
            HOLD_EXPIRES_AT = NULL,
            UPDATED_AT = CURRENT_TIMESTAMP
        WHERE STATUS = 'HOLDING'
          AND HOLD_EXPIRES_AT < CURRENT_TIMESTAMP;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END SP_RELEASE_EXPIRED_HOLDS;

    -- ------------------------------------------------------------------------
    -- 2. GIỮ GHẾ TẠM THỜI (SEAT HOLDING)
    -- ------------------------------------------------------------------------
    PROCEDURE SP_HOLD_SEATS (
        p_showtime_id   IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2,
        p_user_id       IN  VARCHAR2,
        p_hold_minutes  IN  NUMBER DEFAULT 5,
        p_success       OUT NUMBER,
        p_message       OUT VARCHAR2
    ) IS
        v_seat_code     VARCHAR2(10);
        v_current_status VARCHAR2(20);
        v_held_by       VARCHAR2(50);
        v_expires_at    TIMESTAMP;
        v_pos           NUMBER := 1;
        v_next_pos      NUMBER;
        v_seats_temp    VARCHAR2(500) := TRIM(p_seat_codes) || ',';
        v_count_found   NUMBER := 0;
    BEGIN
        -- Bước 1: Dọn dẹp các ghế hết hạn trước
        SP_RELEASE_EXPIRED_HOLDS;

        IF p_seat_codes IS NULL OR LENGTH(TRIM(p_seat_codes)) = 0 THEN
            p_success := 0;
            p_message := 'Danh sách ghế không được để trống.';
            RETURN;
        END IF;

        -- Bước 2: Kiểm tra từng ghế xem có bị trùng hoặc bị người khác giữ không
        WHILE INSTR(v_seats_temp, ',', v_pos) > 0 LOOP
            v_next_pos := INSTR(v_seats_temp, ',', v_pos);
            v_seat_code := UPPER(TRIM(SUBSTR(v_seats_temp, v_pos, v_next_pos - v_pos)));
            v_pos := v_next_pos + 1;

            IF LENGTH(v_seat_code) > 0 THEN
                BEGIN
                    SELECT STATUS, HELD_BY_USER_ID, HOLD_EXPIRES_AT
                    INTO v_current_status, v_held_by, v_expires_at
                    FROM SEATS
                    WHERE SHOWTIME_ID = p_showtime_id
                      AND SEAT_CODE = v_seat_code
                    FOR UPDATE WAIT 3; -- Khóa bi quan chống race condition

                    -- Nếu ghế đã bán
                    IF v_current_status = 'BOOKED' THEN
                        p_success := 0;
                        p_message := 'Ghế ' || v_seat_code || ' đã có người mua vé trước đó.';
                        ROLLBACK;
                        RETURN;
                    END IF;

                    -- Nếu ghế đang được giữ bởi người khác và chưa hết hạn
                    IF v_current_status = 'HOLDING' AND v_held_by != p_user_id AND v_expires_at > CURRENT_TIMESTAMP THEN
                        p_success := 0;
                        p_message := 'Ghế ' || v_seat_code || ' đang được giữ bởi khách hàng khác.';
                        ROLLBACK;
                        RETURN;
                    END IF;

                    v_count_found := v_count_found + 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- Nếu ghế chưa được tạo sẵn trong bảng, ta tự động tạo mới
                        INSERT INTO SEATS (
                            SHOWTIME_ID, SEAT_CODE, ROW_LETTER, SEAT_NUMBER,
                            SEAT_TYPE, PRICE, STATUS, HELD_BY_USER_ID, HOLD_EXPIRES_AT
                        ) VALUES (
                            p_showtime_id,
                            v_seat_code,
                            SUBSTR(v_seat_code, 1, 1),
                            TO_NUMBER(SUBSTR(v_seat_code, 2)),
                            CASE WHEN SUBSTR(v_seat_code, 1, 1) IN ('D', 'E', 'F') THEN 'VIP' ELSE 'NORMAL' END,
                            CASE WHEN SUBSTR(v_seat_code, 1, 1) IN ('D', 'E', 'F') THEN 110000 ELSE 80000 END,
                            'AVAILABLE',
                            NULL,
                            NULL
                        );
                        v_count_found := v_count_found + 1;
                    WHEN OTHERS THEN
                        p_success := 0;
                        p_message := 'Ghế ' || v_seat_code || ' đang bận xử lý, vui lòng thử lại sau.';
                        ROLLBACK;
                        RETURN;
                END;
            END IF;
        END LOOP;

        -- Bước 3: Cập nhật trạng thái HOLDING cho tất cả các ghế
        v_pos := 1;
        WHILE INSTR(v_seats_temp, ',', v_pos) > 0 LOOP
            v_next_pos := INSTR(v_seats_temp, ',', v_pos);
            v_seat_code := UPPER(TRIM(SUBSTR(v_seats_temp, v_pos, v_next_pos - v_pos)));
            v_pos := v_next_pos + 1;

            IF LENGTH(v_seat_code) > 0 THEN
                UPDATE SEATS
                SET STATUS = 'HOLDING',
                    HELD_BY_USER_ID = p_user_id,
                    HOLD_EXPIRES_AT = CURRENT_TIMESTAMP + NUMTODSINTERVAL(p_hold_minutes, 'MINUTE'),
                    UPDATED_AT = CURRENT_TIMESTAMP
                WHERE SHOWTIME_ID = p_showtime_id
                  AND SEAT_CODE = v_seat_code;

                INSERT INTO BOOKING_AUDIT_LOGS (ACTION, SHOWTIME_ID, SEAT_CODE, USER_ID, DESCRIPTION)
                VALUES ('SEAT_HOLD', p_showtime_id, v_seat_code, p_user_id, 'Giữ ghế tạm thời ' || p_hold_minutes || ' phút');
            END IF;
        END LOOP;

        COMMIT;
        p_success := 1;
        p_message := 'Đã giữ thành công ' || v_count_found || ' ghế trong ' || p_hold_minutes || ' phút.';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := 0;
            p_message := 'Lỗi khi giữ ghế: ' || SQLERRM;
    END SP_HOLD_SEATS;

    -- ------------------------------------------------------------------------
    -- 3. TÍNH TOÁN GIÁ VÉ VÀ KIỂM TRA VOUCHER
    -- ------------------------------------------------------------------------
    PROCEDURE SP_CALCULATE_PRICE_AND_VOUCHER (
        p_showtime_id   IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2,
        p_voucher_code  IN  VARCHAR2,
        p_subtotal      OUT NUMBER,
        p_discount      OUT NUMBER,
        p_total         OUT NUMBER,
        p_message       OUT VARCHAR2
    ) IS
        v_seat_code     VARCHAR2(10);
        v_row           VARCHAR2(2);
        v_price         NUMBER;
        v_pos           NUMBER := 1;
        v_next_pos      NUMBER;
        v_seats_temp    VARCHAR2(500) := TRIM(p_seat_codes) || ',';
        v_v_discount    NUMBER := 0;
        v_v_min_price   NUMBER := 0;
        v_v_is_active   NUMBER := 0;
        v_v_expiry      TIMESTAMP;
    BEGIN
        p_subtotal := 0;
        p_discount := 0;
        p_total := 0;
        p_message := 'OK';

        -- Tính tổng tiền vé
        WHILE INSTR(v_seats_temp, ',', v_pos) > 0 LOOP
            v_next_pos := INSTR(v_seats_temp, ',', v_pos);
            v_seat_code := UPPER(TRIM(SUBSTR(v_seats_temp, v_pos, v_next_pos - v_pos)));
            v_pos := v_next_pos + 1;

            IF LENGTH(v_seat_code) > 0 THEN
                v_row := SUBSTR(v_seat_code, 1, 1);
                IF v_row IN ('D', 'E', 'F') THEN
                    v_price := 110000; -- Giá vé VIP
                ELSE
                    v_price := 80000;  -- Giá vé thường
                END IF;
                p_subtotal := p_subtotal + v_price;
            END IF;
        END LOOP;

        -- Kiểm tra Voucher nếu có
        IF p_voucher_code IS NOT NULL AND LENGTH(TRIM(p_voucher_code)) > 0 THEN
            BEGIN
                SELECT DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE, EXPIRY_DATE
                INTO v_v_discount, v_v_min_price, v_v_is_active, v_v_expiry
                FROM VOUCHERS
                WHERE CODE = UPPER(TRIM(p_voucher_code));

                IF v_v_is_active = 0 THEN
                    p_message := 'Mã voucher ' || p_voucher_code || ' hiện không còn hoạt động.';
                    p_discount := 0;
                ELSIF v_v_expiry IS NOT NULL AND v_v_expiry < CURRENT_TIMESTAMP THEN
                    p_message := 'Mã voucher ' || p_voucher_code || ' đã hết hạn sử dụng.';
                    p_discount := 0;
                ELSIF p_subtotal < v_v_min_price THEN
                    p_message := 'Đơn hàng tối thiểu để áp dụng mã là ' || v_v_min_price || 'đ.';
                    p_discount := 0;
                ELSE
                    p_discount := v_v_discount;
                    p_message := 'Áp dụng mã voucher ' || p_voucher_code || ' thành công! Giảm ' || v_v_discount || 'đ.';
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    p_message := 'Mã voucher ' || p_voucher_code || ' không tồn tại trên hệ thống.';
                    p_discount := 0;
            END;
        END IF;

        IF p_subtotal - p_discount < 0 THEN
            p_total := 0;
        ELSE
            p_total := p_subtotal - p_discount;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_subtotal := 0;
            p_discount := 0;
            p_total := 0;
            p_message := 'Lỗi tính giá: ' || SQLERRM;
    END SP_CALCULATE_PRICE_AND_VOUCHER;

    -- ------------------------------------------------------------------------
    -- 4. XÁC NHẬN ĐẶT VÉ (CONFIRM BOOKING)
    -- ------------------------------------------------------------------------
    PROCEDURE SP_CONFIRM_BOOKING (
        p_booking_id    IN  VARCHAR2,
        p_user_id       IN  VARCHAR2,
        p_showtime_id   IN  VARCHAR2,
        p_movie_title   IN  VARCHAR2,
        p_movie_poster  IN  VARCHAR2,
        p_cinema_name   IN  VARCHAR2,
        p_showtime_time IN  VARCHAR2,
        p_seat_codes    IN  VARCHAR2,
        p_voucher_code  IN  VARCHAR2,
        p_success       OUT NUMBER,
        p_total_price   OUT NUMBER,
        p_message       OUT VARCHAR2
    ) IS
        v_subtotal      NUMBER;
        v_discount      NUMBER;
        v_total         NUMBER;
        v_calc_msg      VARCHAR2(400);
        v_seat_code     VARCHAR2(10);
        v_seat_type     VARCHAR2(20);
        v_seat_price    NUMBER;
        v_pos           NUMBER := 1;
        v_next_pos      NUMBER;
        v_seats_temp    VARCHAR2(500) := TRIM(p_seat_codes) || ',';
        v_current_status VARCHAR2(20);
        v_held_by       VARCHAR2(50);
        v_expires_at    TIMESTAMP;
    BEGIN
        -- Giải phóng ghế hết hạn
        SP_RELEASE_EXPIRED_HOLDS;

        -- 1. Kiểm tra từng ghế trước khi xác nhận đặt vé
        WHILE INSTR(v_seats_temp, ',', v_pos) > 0 LOOP
            v_next_pos := INSTR(v_seats_temp, ',', v_pos);
            v_seat_code := UPPER(TRIM(SUBSTR(v_seats_temp, v_pos, v_next_pos - v_pos)));
            v_pos := v_next_pos + 1;

            IF LENGTH(v_seat_code) > 0 THEN
                BEGIN
                    SELECT STATUS, HELD_BY_USER_ID, HOLD_EXPIRES_AT
                    INTO v_current_status, v_held_by, v_expires_at
                    FROM SEATS
                    WHERE SHOWTIME_ID = p_showtime_id
                      AND SEAT_CODE = v_seat_code
                    FOR UPDATE WAIT 3;

                    IF v_current_status = 'BOOKED' THEN
                        p_success := 0;
                        p_total_price := 0;
                        p_message := 'Ghế ' || v_seat_code || ' đã có người thanh toán trước!';
                        ROLLBACK;
                        RETURN;
                    END IF;

                    IF v_current_status = 'HOLDING' AND v_held_by != p_user_id AND v_expires_at > CURRENT_TIMESTAMP THEN
                        p_success := 0;
                        p_total_price := 0;
                        p_message := 'Ghế ' || v_seat_code || ' đang được người khác giữ chỗ!';
                        ROLLBACK;
                        RETURN;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- Tự tạo ghế nếu chưa có
                        INSERT INTO SEATS (
                            SHOWTIME_ID, SEAT_CODE, ROW_LETTER, SEAT_NUMBER,
                            SEAT_TYPE, PRICE, STATUS
                        ) VALUES (
                            p_showtime_id,
                            v_seat_code,
                            SUBSTR(v_seat_code, 1, 1),
                            TO_NUMBER(SUBSTR(v_seat_code, 2)),
                            CASE WHEN SUBSTR(v_seat_code, 1, 1) IN ('D', 'E', 'F') THEN 'VIP' ELSE 'NORMAL' END,
                            CASE WHEN SUBSTR(v_seat_code, 1, 1) IN ('D', 'E', 'F') THEN 110000 ELSE 80000 END,
                            'AVAILABLE'
                        );
                END;
            END IF;
        END LOOP;

        -- 2. Tính tiền và áp dụng voucher
        SP_CALCULATE_PRICE_AND_VOUCHER(
            p_showtime_id   => p_showtime_id,
            p_seat_codes    => p_seat_codes,
            p_voucher_code  => p_voucher_code,
            p_subtotal      => v_subtotal,
            p_discount      => v_discount,
            p_total         => v_total,
            p_message       => v_calc_msg
        );

        p_total_price := v_total;

        -- 3. Tạo hóa đơn thanh toán
        INSERT INTO BOOKINGS (
            BOOKING_ID, USER_ID, SHOWTIME_ID, MOVIE_TITLE, MOVIE_POSTER,
            CINEMA_NAME, SHOWTIME_TIME, SEATS_STRING, SUBTOTAL_PRICE,
            DISCOUNT_AMOUNT, TOTAL_PRICE, VOUCHER_CODE, STATUS, CREATED_AT
        ) VALUES (
            p_booking_id, p_user_id, p_showtime_id, p_movie_title, p_movie_poster,
            p_cinema_name, p_showtime_time, p_seat_codes, v_subtotal,
            v_discount, v_total, p_voucher_code, 'SUCCESS', CURRENT_TIMESTAMP
        );

        -- 4. Thêm chi tiết từng vé và cập nhật ghế sang 'BOOKED'
        v_pos := 1;
        WHILE INSTR(v_seats_temp, ',', v_pos) > 0 LOOP
            v_next_pos := INSTR(v_seats_temp, ',', v_pos);
            v_seat_code := UPPER(TRIM(SUBSTR(v_seats_temp, v_pos, v_next_pos - v_pos)));
            v_pos := v_next_pos + 1;

            IF LENGTH(v_seat_code) > 0 THEN
                IF SUBSTR(v_seat_code, 1, 1) IN ('D', 'E', 'F') THEN
                    v_seat_type := 'VIP';
                    v_seat_price := 110000;
                ELSE
                    v_seat_type := 'NORMAL';
                    v_seat_price := 80000;
                END IF;

                INSERT INTO BOOKING_DETAILS (BOOKING_ID, SEAT_CODE, SEAT_TYPE, PRICE)
                VALUES (p_booking_id, v_seat_code, v_seat_type, v_seat_price);

                UPDATE SEATS
                SET STATUS = 'BOOKED',
                    HELD_BY_USER_ID = p_user_id,
                    HOLD_EXPIRES_AT = NULL,
                    UPDATED_AT = CURRENT_TIMESTAMP
                WHERE SHOWTIME_ID = p_showtime_id
                  AND SEAT_CODE = v_seat_code;
            END IF;
        END LOOP;

        COMMIT;
        p_success := 1;
        p_message := 'Đặt vé thành công!';
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_success := 0;
            p_total_price := 0;
            p_message := 'Lỗi xác nhận đặt vé: ' || SQLERRM;
    END SP_CONFIRM_BOOKING;

    -- ------------------------------------------------------------------------
    -- 5. LẤY LỊCH SỬ ĐẶT VÉ CỦA USER
    -- ------------------------------------------------------------------------
    PROCEDURE SP_GET_USER_BOOKINGS (
        p_user_id       IN  VARCHAR2,
        p_cursor        OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_cursor FOR
            SELECT BOOKING_ID, USER_ID, SHOWTIME_ID, MOVIE_TITLE, MOVIE_POSTER,
                   CINEMA_NAME, SHOWTIME_TIME, SEATS_STRING, SUBTOTAL_PRICE,
                   DISCOUNT_AMOUNT, TOTAL_PRICE, VOUCHER_CODE, STATUS,
                   TO_CHAR(CREATED_AT, 'YYYY-MM-DD"T"HH24:MI:SS') AS BOOKING_TIME
            FROM BOOKINGS
            WHERE USER_ID = p_user_id
            ORDER BY CREATED_AT DESC;
    END SP_GET_USER_BOOKINGS;

    -- ------------------------------------------------------------------------
    -- 6. THỐNG KÊ DOANH THU VÀ DỮ LIỆU ADMIN
    -- ------------------------------------------------------------------------
    PROCEDURE SP_ADMIN_GET_STATISTICS (
        p_total_revenue  OUT NUMBER,
        p_total_bookings OUT NUMBER,
        p_total_movies   OUT NUMBER,
        p_total_cinemas  OUT NUMBER
    ) IS
    BEGIN
        SELECT NVL(SUM(TOTAL_PRICE), 0), COUNT(BOOKING_ID)
        INTO p_total_revenue, p_total_bookings
        FROM BOOKINGS
        WHERE STATUS = 'SUCCESS';

        SELECT COUNT(MOVIE_ID) INTO p_total_movies FROM MOVIES;
        SELECT COUNT(CINEMA_ID) INTO p_total_cinemas FROM CINEMAS;
    EXCEPTION
        WHEN OTHERS THEN
            p_total_revenue := 0;
            p_total_bookings := 0;
            p_total_movies := 0;
            p_total_cinemas := 0;
    END SP_ADMIN_GET_STATISTICS;

END PKG_KRISTAL_BOOKING;
/

-- ----------------------------------------------------------------------------
-- PHẦN 3: CÁC DATABASE TRIGGERS
-- ----------------------------------------------------------------------------

-- Trigger 1: Kiểm tra tính toàn vẹn trạng thái ghế (Chặn đổi trạng thái ghế đã bán)
CREATE OR REPLACE TRIGGER TRG_CHECK_SEAT_INTEGRITY
BEFORE UPDATE OF STATUS ON SEATS
FOR EACH ROW
BEGIN
    IF :OLD.STATUS = 'BOOKED' AND :NEW.STATUS != 'BOOKED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Không thể thay đổi trạng thái của ghế đã được thanh toán thành công!');
    END IF;

    IF :NEW.STATUS = 'HOLDING' AND :OLD.STATUS = 'HOLDING' 
       AND :OLD.HELD_BY_USER_ID != :NEW.HELD_BY_USER_ID 
       AND :OLD.HOLD_EXPIRES_AT > CURRENT_TIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ghế đang được giữ bởi người khác trong thời gian hiệu lực!');
    END IF;
END;
/

-- Trigger 2: Ghi log kiểm toán tự động khi phát sinh hóa đơn đặt vé mới
CREATE OR REPLACE TRIGGER TRG_BOOKING_AUDIT
AFTER INSERT OR UPDATE ON BOOKINGS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO BOOKING_AUDIT_LOGS (ACTION, BOOKING_ID, SHOWTIME_ID, USER_ID, DESCRIPTION)
        VALUES (
            'CREATE_BOOKING',
            :NEW.BOOKING_ID,
            :NEW.SHOWTIME_ID,
            :NEW.USER_ID,
            'Tạo hóa đơn vé phim ' || :NEW.MOVIE_TITLE || ' tại rạp ' || :NEW.CINEMA_NAME || 
            ', ghế: ' || :NEW.SEATS_STRING || ', tổng tiền: ' || :NEW.TOTAL_PRICE || 'đ'
        );
    ELSIF UPDATING THEN
        INSERT INTO BOOKING_AUDIT_LOGS (ACTION, BOOKING_ID, SHOWTIME_ID, USER_ID, DESCRIPTION)
        VALUES (
            'UPDATE_BOOKING_STATUS',
            :NEW.BOOKING_ID,
            :NEW.SHOWTIME_ID,
            :NEW.USER_ID,
            'Cập nhật trạng thái hóa đơn từ ' || :OLD.STATUS || ' sang ' || :NEW.STATUS
        );
    END IF;
END;
/

COMMIT;
PROMPT [OK] Đã biên dịch Package PKG_KRISTAL_BOOKING và các Triggers thành công trên Oracle 23ai!
