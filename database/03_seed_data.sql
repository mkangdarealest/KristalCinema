-- ============================================================================
-- ĐỀ TÀI SỐ 6: ỨNG DỤNG ĐẶT VÉ XEM PHIM KRISTALCINEMA
-- FILE: 03_seed_data.sql
-- MỤC ĐÍCH: NẠP DỮ LIỆU MẪU ĐẦY ĐỦ KHỚP VỚI ASSETS/IMAGES VÀ GIAO DIỆN FLUTTER
-- Kết nối dưới User: KRISTAL_CINEMA / Kristal#2026@localhost:1521/FREEPDB1
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. NẠP USERS MẪU (Admin và Khách hàng)
-- Mật khẩu mặc định: 1234567890
-- ----------------------------------------------------------------------------
INSERT INTO USERS (USER_ID, FULL_NAME, EMAIL, PASSWORD_HASH, PHONE, AVATAR, GENDER, CITY, ROLE)
VALUES (
    'u_admin01',
    'Admin Kristal',
    'admin01@kristalcinema.com',
    '$2b$10$wNqV9Fj4yX8C5aJ2q1ZJ0.9jIkmHq8Z0J2xK8d4M3iZ5lY9q2wK1a', -- 1234567890 (bcrypt) hoặc plain
    '0909123456',
    'assets/images/logo.png',
    'Nam',
    'TP. Hồ Chí Minh',
    'admin'
);

INSERT INTO USERS (USER_ID, FULL_NAME, EMAIL, PASSWORD_HASH, PHONE, AVATAR, GENDER, CITY, ROLE)
VALUES (
    'u_khach01',
    'Nguyễn Văn A',
    'user01@gmail.com',
    '$2b$10$wNqV9Fj4yX8C5aJ2q1ZJ0.9jIkmHq8Z0J2xK8d4M3iZ5lY9q2wK1a',
    '0912345678',
    '',
    'Nam',
    'TP. Hồ Chí Minh',
    'user'
);

-- ----------------------------------------------------------------------------
-- 2. NẠP DANH SÁCH 9 PHIM (Khớp 100% với Movie.mockMovies và Assets)
-- ----------------------------------------------------------------------------
INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '1',
    'MƯA ĐỎ',
    'assets/images/poster(hot).webp',
    1,
    'lịch sử, chiến tranh, chính kịch',
    '124 phút',
    'T18',
    'Phim Mưa Đỏ (đạo diễn Đặng Thái Huyền) là một bản hùng ca bi tráng tái hiện 81 ngày đêm khốc liệt tại Thành cổ Quảng Trị năm 1972. Tác phẩm mang đến trải nghiệm điện ảnh cảm động, chân thực, giúp khán giả tri ân những người lính, dẫu vậy vẫn còn một số điểm trừ nhỏ ở tuyến tình cảm.',
    'now_showing'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '2',
    'MA XÓ',
    'assets/images/poster1(hot).jpg',
    1,
    'Kinh dị, Tâm lý',
    '145 phút',
    'T13',
    'Ma Xó là bộ phim điện ảnh Việt Nam thuộc thể loại kinh dị (18+). Tác phẩm xoay quanh câu chuyện tâm linh kỳ bí tại miền Tây sông nước, khai thác chủ đề nuôi ma xó (thế lực siêu nhiên giữ nhà) và bi kịch xuất phát từ tình thân, lòng tham cùng những lời cầu xin trả giá.',
    'now_showing'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '3',
    'MẮT BIẾC',
    'assets/images/poster2(hot).jpg',
    1,
    'Truyện dài, văn học thanh thiếu niên, tình cảm',
    '135 phút',
    'P',
    'Mắt Biếc của nhà văn Nguyễn Nhật Ánh là một cuốn truyện dài (hoặc tiểu thuyết) thuộc thể loại văn học lãng mạn. Nội dung xoay quanh mối tình đơn phương da diết của Ngạn dành cho Hà Lan - cô bạn thuở ấu thơ có đôi mắt hút hồn, vẽ nên một bức tranh thanh xuân trong trẻo nhưng đượm buồn.',
    'now_showing'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '4',
    'MAI',
    'assets/images/poster3.jpg',
    0,
    'tâm lý, tình cảm, hài hước',
    '120 phút',
    'T16',
    'Phim xoay quanh cuộc đời của Mai (Phương Anh Đào), một nữ nhân viên mát-xa tuổi gần 40 mang nhiều tổn thương. Dù có quá khứ tăm tối và luôn phải chịu định kiến cay nghiệt từ xã hội, cô vẫn giữ khát khao được yêu thương chân thành.',
    'now_showing'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '5',
    'TITANIC',
    'assets/images/poster4.jpg',
    0,
    'lãng mạn, phiêu lưu và thảm họa',
    '115 phút',
    'T18',
    'Titanic là bộ phim điện ảnh kinh điển của Mỹ ra mắt năm 1997, thuộc thể loại lãng mạn, phiêu lưu và thảm họa. Phim tái hiện lại thảm họa đắm tàu RMS Titanic có thật vào năm 1912, lồng ghép cùng câu chuyện tình yêu đầy bi tráng giữa hai nhân vật hư cấu.',
    'now_showing'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '6',
    'SPIDER MAN: NO WAY HOME',
    'assets/images/poster5.jpg',
    0,
    'hành động, khoa học viễn tưởng',
    '128 phút',
    'T16',
    'Nội dung phim bắt đầu ngay sau phần trước khi danh tính bí mật của Peter Parker bị kẻ phản diện Mysterio tiết lộ cho toàn thế giới. Việc bị công khai là Người Nhện khiến cuộc sống của Peter cùng những người thân yêu (như MJ và Ned) bị đảo lộn và gặp vô vàn rắc rối.',
    'coming_soon'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '7',
    'KUNGFU PANDA 4',
    'assets/images/poster6.jpg',
    0,
    'Hoạt hình, hài hước, võ thuật',
    '110 phút',
    'T18',
    'Trong phần 4, đại sư Shifu thông báo Po (do Jack Black lồng tiếng) đã đến lúc từ bỏ danh hiệu Thần Long Đại Hiệp để đảm nhận vị trí Lãnh đạo tinh thần. Po không muốn từ bỏ công việc đánh đấm quen thuộc, đồng thời phải đối mặt với một mối đe dọa mới là Tắc Kè Hoa.',
    'coming_soon'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '8',
    'BỐ GIÀ',
    'assets/images/poster7.webp',
    0,
    'tâm lý, gia đình, hài kịch và đời sống',
    '105 phút',
    'P',
    'Phim tập trung vào ông Ba Sang (Trấn Thành) – một người đàn ông làm nghề chở hàng thuê, tính tình bao đồng nhưng luôn hết lòng hy sinh vì gia đình. Trái ngược với ông là cậu con trai Quắn (Tuấn Trần) – một YouTuber hiện đại có cái tôi cao.',
    'coming_soon'
);

INSERT INTO MOVIES (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
VALUES (
    '9',
    'ĐỊA ĐẠO',
    'assets/images/poster8.jpg',
    0,
    'Lịch sử, Chiến tranh, Chính kịch',
    '130 phút',
    'T18',
    'Phim điện ảnh Địa Đạo tái hiện cuộc chiến tranh nhân dân kiên cường tại vùng đất thép Củ Chi, tôn vinh ý chí bất khuất của các chiến sĩ và đồng bào trong những năm tháng kháng chiến.',
    'coming_soon'
);

-- ----------------------------------------------------------------------------
-- 3. NẠP DANH SÁCH 5 CỤM RẠP CHIẾU
-- ----------------------------------------------------------------------------
INSERT INTO CINEMAS (CINEMA_ID, NAME, ADDRESS, IMAGE)
VALUES ('1', 'KristalCinema Aeon Bình Tân', 'Đường Số 17A, Bình Trị Đông B, Bình Tân, TP. Hồ Chí Minh', 'assets/images/mall1.jpg');

INSERT INTO CINEMAS (CINEMA_ID, NAME, ADDRESS, IMAGE)
VALUES ('2', 'KristalCinema Aeon Tân Phú', '30 Bờ Bao Tân Thắng, Sơn Kỳ, Tân Phú, TP. Hồ Chí Minh', 'assets/images/mall2.jpg');

INSERT INTO CINEMAS (CINEMA_ID, NAME, ADDRESS, IMAGE)
VALUES ('3', 'KristalCinema Vạn Hạnh Mall', '11 Sư Vạn Hạnh, Phường 12, Quận 10, TP. Hồ Chí Minh', 'assets/images/mall3.jpg');

INSERT INTO CINEMAS (CINEMA_ID, NAME, ADDRESS, IMAGE)
VALUES ('4', 'KristalCinema GigaMall Thủ Đức', '240-242 Phạm Văn Đồng, Hiệp Bình Chánh, Thủ Đức, TP. Hồ Chí Minh', 'assets/images/mall4.jpg');

INSERT INTO CINEMAS (CINEMA_ID, NAME, ADDRESS, IMAGE)
VALUES ('5', 'KristalCinema Crescent Mall Quận 7', '101 Tôn Dật Tiên, Tân Phú, Quận 7, TP. Hồ Chí Minh', 'assets/images/mall5.jpg');

-- ----------------------------------------------------------------------------
-- 4. NẠP SUẤT CHIẾU (SHOWTIMES)
-- Định dạng SHOWTIME_ID: {CINEMA_ID}_{MOVIE_ID}_{TIME} (VD: 1_1_09_30)
-- ----------------------------------------------------------------------------
INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_1_09_30', '1', '1', '09:30', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_1_12_40', '1', '1', '12:40', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_1_15_15', '1', '1', '15:15', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_1_18_00', '1', '1', '18:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_1_20_30', '1', '1', '20:30', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_2_10_00', '1', '2', '10:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_2_16_00', '1', '2', '16:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('1_3_19_00', '1', '3', '19:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('2_1_10_00', '2', '1', '10:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('2_1_13_15', '2', '1', '13:15', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('3_1_09_00', '3', '1', '09:00', TRUNC(SYSDATE), 'AVAILABLE');

INSERT INTO SHOWTIMES (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
VALUES ('3_4_14_30', '3', '4', '14:30', TRUNC(SYSDATE), 'AVAILABLE');

-- ----------------------------------------------------------------------------
-- 5. SINH GHẾ MẪU CHO CÁC SUẤT CHIẾU (Hàng A->H, Mỗi hàng 10 ghế)
-- Ghế Thường (A, B, C, G, H): 80.000đ; Ghế VIP (D, E, F): 110.000đ
-- ----------------------------------------------------------------------------
DECLARE
    TYPE t_rows IS TABLE OF VARCHAR2(2);
    v_rows t_rows := t_rows('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H');
    v_type VARCHAR2(20);
    v_price NUMBER;
BEGIN
    FOR st IN (SELECT SHOWTIME_ID FROM SHOWTIMES) LOOP
        FOR r IN 1..v_rows.COUNT LOOP
            IF v_rows(r) IN ('D', 'E', 'F') THEN
                v_type := 'VIP';
                v_price := 110000;
            ELSE
                v_type := 'NORMAL';
                v_price := 80000;
            END IF;

            FOR col IN 1..10 LOOP
                INSERT INTO SEATS (
                    SHOWTIME_ID, SEAT_CODE, ROW_LETTER, SEAT_NUMBER,
                    SEAT_TYPE, PRICE, STATUS
                ) VALUES (
                    st.SHOWTIME_ID,
                    v_rows(r) || TO_CHAR(col),
                    v_rows(r),
                    col,
                    v_type,
                    v_price,
                    'AVAILABLE'
                );
            END LOOP;
        END LOOP;
    END LOOP;
END;
/

-- Đánh dấu một số ghế đã đặt mẫu cho suất chiếu '1_1_09_30' để giao diện demo trực quan
UPDATE SEATS SET STATUS = 'BOOKED' WHERE SHOWTIME_ID = '1_1_09_30' AND SEAT_CODE IN ('C5', 'C6', 'D5', 'D6');

-- ----------------------------------------------------------------------------
-- 6. NẠP DANH SÁCH MÃ GIẢM GIÁ (VOUCHERS)
-- ----------------------------------------------------------------------------
INSERT INTO VOUCHERS (VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE, EXPIRY_DATE)
VALUES ('v1', 'GIAM50K', 50000, 100000, 1, SYSTIMESTAMP + INTERVAL '60' DAY);

INSERT INTO VOUCHERS (VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE, EXPIRY_DATE)
VALUES ('v2', 'KRISTAL20', 20000, 80000, 1, SYSTIMESTAMP + INTERVAL '60' DAY);

INSERT INTO VOUCHERS (VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE, EXPIRY_DATE)
VALUES ('v3', 'VIP100', 100000, 200000, 1, SYSTIMESTAMP + INTERVAL '60' DAY);

-- ----------------------------------------------------------------------------
-- 7. NẠP HÓA ĐƠN ĐẶT VÉ MẪU
-- ----------------------------------------------------------------------------
INSERT INTO BOOKINGS (
    BOOKING_ID, USER_ID, SHOWTIME_ID, MOVIE_TITLE, MOVIE_POSTER,
    CINEMA_NAME, SHOWTIME_TIME, SEATS_STRING, SUBTOTAL_PRICE,
    DISCOUNT_AMOUNT, TOTAL_PRICE, VOUCHER_CODE, STATUS, CREATED_AT
) VALUES (
    'b_sample_01',
    'u_khach01',
    '1_1_09_30',
    'MƯA ĐỎ',
    'assets/images/poster(hot).webp',
    'KristalCinema Aeon Bình Tân',
    '09:30',
    'C5, C6',
    160000,
    50000,
    110000,
    'GIAM50K',
    'SUCCESS',
    SYSTIMESTAMP - INTERVAL '1' DAY
);

INSERT INTO BOOKING_DETAILS (BOOKING_ID, SEAT_CODE, SEAT_TYPE, PRICE)
VALUES ('b_sample_01', 'C5', 'NORMAL', 80000);

INSERT INTO BOOKING_DETAILS (BOOKING_ID, SEAT_CODE, SEAT_TYPE, PRICE)
VALUES ('b_sample_01', 'C6', 'NORMAL', 80000);

COMMIT;
PROMPT [OK] Đã nạp dữ liệu mẫu hoàn tất (9 phim, 5 rạp, suất chiếu, ghế, voucher, tài khoản)!
