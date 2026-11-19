const db = require('../config/db');
const oracledb = require('oracledb');

// Lấy trạng thái ghế của suất chiếu (Tự động dọn ghế hết hạn giữ và trả về danh sách ghế đã đặt)
async function getShowtimeSeats(req, res) {
  try {
    const { showtimeId } = req.params;

    // 1. Gọi Procedure giải phóng ghế giữ hết hạn trong Package Oracle
    await db.execute(`BEGIN PKG_KRISTAL_BOOKING.SP_RELEASE_EXPIRED_HOLDS; END;`);

    // 2. Lấy danh sách ghế đang BOOKED hoặc HOLDING
    const sql = `
      SELECT SEAT_CODE, STATUS, HELD_BY_USER_ID
      FROM SEATS
      WHERE SHOWTIME_ID = :showtimeId
        AND STATUS IN ('BOOKED', 'HOLDING')
    `;
    const result = await db.execute(sql, { showtimeId });

    const bookedSeats = [];
    const holdingSeats = [];
    for (const r of result.rows || []) {
      if (r.STATUS === 'BOOKED') {
        bookedSeats.push(r.SEAT_CODE);
      } else if (r.STATUS === 'HOLDING') {
        holdingSeats.push(r.SEAT_CODE);
      }
    }

    return res.json({
      success: true,
      data: {
        showtimeId,
        bookedSeats, // Đồng bộ với format Flutter đang dùng (currentBookedSeats)
        holdingSeats,
      },
    });
  } catch (err) {
    console.error('[BookingController.getShowtimeSeats]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tải trạng thái ghế: ' + err.message });
  }
}

// Giữ ghế tạm thời (Gọi trực tiếp Procedure Oracle PKG_KRISTAL_BOOKING.SP_HOLD_SEATS)
async function holdSeats(req, res) {
  try {
    const { showtimeId, seatCodes, userId, holdMinutes } = req.body;

    const seatsStr = Array.isArray(seatCodes) ? seatCodes.join(',') : seatCodes;
    const minutes = holdMinutes || 5;

    const plsql = `
      BEGIN
        PKG_KRISTAL_BOOKING.SP_HOLD_SEATS(
          p_showtime_id  => :showtimeId,
          p_seat_codes   => :seatCodes,
          p_user_id      => :userId,
          p_hold_minutes => :minutes,
          p_success      => :success,
          p_message      => :message
        );
      END;
    `;

    const binds = {
      showtimeId,
      seatCodes: seatsStr,
      userId: userId || 'anonymous',
      minutes,
      success: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      message: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 500 },
    };

    const result = await db.execute(plsql, binds);
    const success = result.outBinds.success === 1;
    const message = result.outBinds.message;

    return res.json({ success, message });
  } catch (err) {
    console.error('[BookingController.holdSeats]', err);
    return res.status(500).json({ success: false, message: 'Lỗi giữ ghế: ' + err.message });
  }
}

// Tính tiền và kiểm tra Voucher (Gọi trực tiếp PKG_KRISTAL_BOOKING.SP_CALCULATE_PRICE_AND_VOUCHER)
async function calculatePrice(req, res) {
  try {
    const { showtimeId, seatCodes, voucherCode } = req.body;
    const seatsStr = Array.isArray(seatCodes) ? seatCodes.join(',') : seatCodes;

    const plsql = `
      BEGIN
        PKG_KRISTAL_BOOKING.SP_CALCULATE_PRICE_AND_VOUCHER(
          p_showtime_id  => :showtimeId,
          p_seat_codes   => :seatCodes,
          p_voucher_code => :voucherCode,
          p_subtotal     => :subtotal,
          p_discount     => :discount,
          p_total        => :total,
          p_message      => :message
        );
      END;
    `;

    const binds = {
      showtimeId: showtimeId || '',
      seatCodes: seatsStr || '',
      voucherCode: voucherCode ? voucherCode.trim() : null,
      subtotal: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      discount: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      total: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      message: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 500 },
    };

    const result = await db.execute(plsql, binds);

    return res.json({
      success: true,
      data: {
        subtotal: result.outBinds.subtotal,
        discount: result.outBinds.discount,
        total: result.outBinds.total,
        message: result.outBinds.message,
      },
    });
  } catch (err) {
    console.error('[BookingController.calculatePrice]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tính tiền: ' + err.message });
  }
}

// Xác nhận đặt vé (Gọi trực tiếp PKG_KRISTAL_BOOKING.SP_CONFIRM_BOOKING)
async function confirmBooking(req, res) {
  try {
    const {
      userId,
      movieTitle,
      moviePoster,
      cinemaName,
      showtimeId,
      showtimeTime,
      seats,
      voucherCode,
    } = req.body;

    if (!userId || !showtimeId || !seats || seats.length === 0) {
      return res.status(400).json({ success: false, message: 'Thông tin đặt vé không hợp lệ.' });
    }

    const bookingId = 'b_' + Date.now();
    const seatsStr = Array.isArray(seats) ? seats.join(',') : seats;

    const plsql = `
      BEGIN
        PKG_KRISTAL_BOOKING.SP_CONFIRM_BOOKING(
          p_booking_id    => :bookingId,
          p_user_id       => :userId,
          p_showtime_id   => :showtimeId,
          p_movie_title   => :movieTitle,
          p_movie_poster  => :moviePoster,
          p_cinema_name   => :cinemaName,
          p_showtime_time => :showtimeTime,
          p_seat_codes    => :seatCodes,
          p_voucher_code  => :voucherCode,
          p_success       => :success,
          p_total_price   => :totalPrice,
          p_message       => :message
        );
      END;
    `;

    const binds = {
      bookingId,
      userId,
      showtimeId,
      movieTitle: movieTitle || '',
      moviePoster: moviePoster || '',
      cinemaName: cinemaName || '',
      showtimeTime: showtimeTime || '',
      seatCodes: seatsStr,
      voucherCode: voucherCode ? voucherCode.trim() : null,
      success: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      totalPrice: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      message: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 500 },
    };

    const result = await db.execute(plsql, binds);
    const success = result.outBinds.success === 1;

    if (!success) {
      return res.status(400).json({
        success: false,
        message: result.outBinds.message || 'Đặt vé thất bại.',
      });
    }

    return res.json({
      success: true,
      message: result.outBinds.message || 'Đặt vé thành công!',
      data: {
        bookingId,
        totalPrice: result.outBinds.totalPrice,
      },
    });
  } catch (err) {
    console.error('[BookingController.confirmBooking]', err);
    return res.status(500).json({ success: false, message: 'Lỗi xác nhận đặt vé: ' + err.message });
  }
}

// Lấy lịch sử đặt vé của User
async function getUserBookings(req, res) {
  try {
    const { userId } = req.params;
    const sql = `
      SELECT BOOKING_ID, USER_ID, SHOWTIME_ID, MOVIE_TITLE, MOVIE_POSTER,
             CINEMA_NAME, SHOWTIME_TIME, SEATS_STRING, SUBTOTAL_PRICE,
             DISCOUNT_AMOUNT, TOTAL_PRICE, VOUCHER_CODE, STATUS,
             TO_CHAR(CREATED_AT, 'YYYY-MM-DD"T"HH24:MI:SS') AS BOOKING_TIME
      FROM BOOKINGS
      WHERE USER_ID = :userId
      ORDER BY CREATED_AT DESC
    `;
    const result = await db.execute(sql, { userId });

    const bookings = (result.rows || []).map((b) => ({
      id: b.BOOKING_ID,
      userId: b.USER_ID,
      showtimeId: b.SHOWTIME_ID,
      movieTitle: b.MOVIE_TITLE,
      moviePoster: b.MOVIE_POSTER,
      cinemaName: b.CINEMA_NAME,
      showtime: b.SHOWTIME_TIME,
      seats: b.SEATS_STRING ? b.SEATS_STRING.split(',').map((s) => s.trim()) : [],
      subtotalPrice: b.SUBTOTAL_PRICE,
      discountAmount: b.DISCOUNT_AMOUNT,
      totalPrice: b.TOTAL_PRICE,
      voucherCode: b.VOUCHER_CODE,
      status: b.STATUS,
      bookingTime: b.BOOKING_TIME,
    }));

    return res.json({ success: true, data: bookings });
  } catch (err) {
    console.error('[BookingController.getUserBookings]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tải lịch sử đặt vé: ' + err.message });
  }
}

// Lấy toàn bộ hóa đơn đặt vé (Admin)
async function getAllBookings(req, res) {
  try {
    const sql = `
      SELECT BOOKING_ID, USER_ID, SHOWTIME_ID, MOVIE_TITLE, MOVIE_POSTER,
             CINEMA_NAME, SHOWTIME_TIME, SEATS_STRING, SUBTOTAL_PRICE,
             DISCOUNT_AMOUNT, TOTAL_PRICE, VOUCHER_CODE, STATUS,
             TO_CHAR(CREATED_AT, 'YYYY-MM-DD"T"HH24:MI:SS') AS BOOKING_TIME
      FROM BOOKINGS
      ORDER BY CREATED_AT DESC
    `;
    const result = await db.execute(sql);

    const bookings = (result.rows || []).map((b) => ({
      id: b.BOOKING_ID,
      userId: b.USER_ID,
      showtimeId: b.SHOWTIME_ID,
      movieTitle: b.MOVIE_TITLE,
      moviePoster: b.MOVIE_POSTER,
      cinemaName: b.CINEMA_NAME,
      showtime: b.SHOWTIME_TIME,
      seats: b.SEATS_STRING ? b.SEATS_STRING.split(',').map((s) => s.trim()) : [],
      subtotalPrice: b.SUBTOTAL_PRICE,
      discountAmount: b.DISCOUNT_AMOUNT,
      totalPrice: b.TOTAL_PRICE,
      voucherCode: b.VOUCHER_CODE,
      status: b.STATUS,
      bookingTime: b.BOOKING_TIME,
    }));

    return res.json({ success: true, data: bookings });
  } catch (err) {
    console.error('[BookingController.getAllBookings]', err);
    return res.status(500).json({ success: false, message: 'Lỗi: ' + err.message });
  }
}

module.exports = {
  getShowtimeSeats,
  holdSeats,
  calculatePrice,
  confirmBooking,
  getUserBookings,
  getAllBookings,
};
