const db = require('../config/db');

// Lấy danh sách rạp chiếu kèm danh sách giờ chiếu
async function getCinemas(req, res) {
  try {
    const cinemaSql = `SELECT CINEMA_ID, NAME, ADDRESS, IMAGE FROM CINEMAS ORDER BY CINEMA_ID ASC`;
    const cinemaResult = await db.execute(cinemaSql);

    const showtimeSql = `
      SELECT DISTINCT CINEMA_ID, START_TIME
      FROM SHOWTIMES
      WHERE STATUS = 'AVAILABLE'
      ORDER BY START_TIME ASC
    `;
    const showtimeResult = await db.execute(showtimeSql);

    // Gom nhóm giờ chiếu theo rạp
    const showtimesByCinema = {};
    for (const row of showtimeResult.rows || []) {
      if (!showtimesByCinema[row.CINEMA_ID]) {
        showtimesByCinema[row.CINEMA_ID] = [];
      }
      showtimesByCinema[row.CINEMA_ID].push(row.START_TIME);
    }

    const defaultShowtimes = ["09:30", "12:40", "15:15", "18:00", "20:30", "22:45"];

    const cinemas = (cinemaResult.rows || []).map((c) => ({
      id: c.CINEMA_ID,
      name: c.NAME,
      address: c.ADDRESS,
      image: c.IMAGE,
      showtimes: showtimesByCinema[c.CINEMA_ID] && showtimesByCinema[c.CINEMA_ID].length > 0
        ? showtimesByCinema[c.CINEMA_ID]
        : defaultShowtimes,
    }));

    return res.json({ success: true, data: cinemas });
  } catch (err) {
    console.error('[CinemaController.getCinemas]', err);
    return res.status(500).json({ success: false, message: 'Lỗi lấy danh sách rạp: ' + err.message });
  }
}

// Lưu rạp chiếu (Admin)
async function saveCinema(req, res) {
  try {
    const { id, name, address, image, showtimes } = req.body;
    if (!name || !address) {
      return res.status(400).json({ success: false, message: 'Tên và địa chỉ rạp không được để trống.' });
    }

    const cinemaId = id && id.trim().length > 0 ? id : 'c_' + Date.now();
    const cinemaImage = image ? image.trim() : 'assets/images/mall1.jpg';

    const mergeSql = `
      MERGE INTO CINEMAS c
      USING (SELECT :id AS CINEMA_ID FROM dual) src
      ON (c.CINEMA_ID = src.CINEMA_ID)
      WHEN MATCHED THEN
        UPDATE SET NAME = :name, ADDRESS = :address, IMAGE = :image
      WHEN NOT MATCHED THEN
        INSERT (CINEMA_ID, NAME, ADDRESS, IMAGE)
        VALUES (:id, :name, :address, :image)
    `;

    await db.execute(mergeSql, {
      id: cinemaId,
      name: name.trim(),
      address: address.trim(),
      image: cinemaImage,
    });

    // Cập nhật các suất chiếu cho rạp nếu có danh sách giờ
    if (Array.isArray(showtimes) && showtimes.length > 0) {
      // Lấy danh sách phim hiện có
      const moviesResult = await db.execute(`SELECT MOVIE_ID FROM MOVIES`);
      const movies = moviesResult.rows || [];

      for (const time of showtimes) {
        const cleanTime = time.trim();
        for (const m of movies) {
          const stId = `${cinemaId}_${m.MOVIE_ID}_${cleanTime.replace(':', '_')}`;
          const stSql = `
            MERGE INTO SHOWTIMES s
            USING (SELECT :stId AS SHOWTIME_ID FROM dual) src
            ON (s.SHOWTIME_ID = src.SHOWTIME_ID)
            WHEN NOT MATCHED THEN
              INSERT (SHOWTIME_ID, CINEMA_ID, MOVIE_ID, START_TIME, SHOW_DATE, STATUS)
              VALUES (:stId, :cinemaId, :movieId, :startTime, TRUNC(SYSDATE), 'AVAILABLE')
          `;
          await db.execute(stSql, {
            stId,
            cinemaId,
            movieId: m.MOVIE_ID,
            startTime: cleanTime,
          });
        }
      }
    }

    return res.json({
      success: true,
      message: 'Lưu thông tin rạp chiếu thành công.',
      data: { id: cinemaId },
    });
  } catch (err) {
    console.error('[CinemaController.saveCinema]', err);
    return res.status(500).json({ success: false, message: 'Lỗi lưu rạp: ' + err.message });
  }
}

// Xóa rạp chiếu (Admin)
async function deleteCinema(req, res) {
  try {
    const { id } = req.params;
    await db.execute(`DELETE FROM CINEMAS WHERE CINEMA_ID = :id`, { id });
    return res.json({ success: true, message: 'Xóa rạp thành công.' });
  } catch (err) {
    console.error('[CinemaController.deleteCinema]', err);
    return res.status(500).json({ success: false, message: 'Lỗi xóa rạp: ' + err.message });
  }
}

module.exports = {
  getCinemas,
  saveCinema,
  deleteCinema,
};
