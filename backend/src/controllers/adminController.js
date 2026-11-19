const db = require('../config/db');
const oracledb = require('oracledb');

// Lấy thống kê tổng quan cho Admin Portal (Gọi Package Oracle PKG_KRISTAL_BOOKING.SP_ADMIN_GET_STATISTICS)
async function getStatistics(req, res) {
  try {
    const plsql = `
      BEGIN
        PKG_KRISTAL_BOOKING.SP_ADMIN_GET_STATISTICS(
          p_total_revenue  => :totalRevenue,
          p_total_bookings => :totalBookings,
          p_total_movies   => :totalMovies,
          p_total_cinemas  => :totalCinemas
        );
      END;
    `;

    const binds = {
      totalRevenue: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      totalBookings: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      totalMovies: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
      totalCinemas: { dir: oracledb.BIND_OUT, type: oracledb.NUMBER },
    };

    const result = await db.execute(plsql, binds);

    return res.json({
      success: true,
      data: {
        totalRevenue: result.outBinds.totalRevenue || 0,
        totalBookings: result.outBinds.totalBookings || 0,
        totalMovies: result.outBinds.totalMovies || 0,
        totalCinemas: result.outBinds.totalCinemas || 0,
      },
    });
  } catch (err) {
    console.error('[AdminController.getStatistics]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tải thống kê: ' + err.message });
  }
}

module.exports = {
  getStatistics,
};
