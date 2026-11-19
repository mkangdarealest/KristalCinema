const db = require('../config/db');

// Lấy danh sách phim (kèm hỗ trợ tìm kiếm và lọc status)
async function getMovies(req, res) {
  try {
    const { status, keyword } = req.query;
    let sql = `
      SELECT MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS
      FROM MOVIES
      WHERE 1=1
    `;
    const binds = {};

    if (status) {
      sql += ` AND STATUS = :status`;
      binds.status = status;
    }

    if (keyword) {
      sql += ` AND (LOWER(TITLE) LIKE :kw OR LOWER(GENRE) LIKE :kw)`;
      binds.kw = `%${keyword.trim().toLowerCase()}%`;
    }

    sql += ` ORDER BY CREATED_AT DESC`;

    const result = await db.execute(sql, binds);

    const movies = (result.rows || []).map((m) => ({
      id: m.MOVIE_ID,
      title: m.TITLE,
      image: m.IMAGE,
      isHot: m.IS_HOT === 1,
      genre: m.GENRE,
      duration: m.DURATION,
      rating: m.RATING,
      synopsis: m.SYNOPSIS,
      status: m.STATUS,
    }));

    return res.json({ success: true, data: movies });
  } catch (err) {
    console.error('[MovieController.getMovies]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tải danh sách phim: ' + err.message });
  }
}

// Lấy chi tiết phim theo ID
async function getMovieById(req, res) {
  try {
    const { id } = req.params;
    const sql = `
      SELECT MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS
      FROM MOVIES
      WHERE MOVIE_ID = :id
    `;
    const result = await db.execute(sql, { id });

    if (!result.rows || result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy phim.' });
    }

    const m = result.rows[0];
    return res.json({
      success: true,
      data: {
        id: m.MOVIE_ID,
        title: m.TITLE,
        image: m.IMAGE,
        isHot: m.IS_HOT === 1,
        genre: m.GENRE,
        duration: m.DURATION,
        rating: m.RATING,
        synopsis: m.SYNOPSIS,
        status: m.STATUS,
      },
    });
  } catch (err) {
    console.error('[MovieController.getMovieById]', err);
    return res.status(500).json({ success: false, message: 'Lỗi: ' + err.message });
  }
}

// Thêm mới hoặc cập nhật phim (Admin)
async function saveMovie(req, res) {
  try {
    const { id, title, image, isHot, genre, duration, rating, synopsis, status } = req.body;

    if (!title) {
      return res.status(400).json({ success: false, message: 'Tiêu đề phim không được để trống.' });
    }

    const movieId = id && id.trim().length > 0 ? id : 'm_' + Date.now();
    const isHotVal = isHot === true || isHot === 1 || isHot === '1' ? 1 : 0;
    const movieStatus = status || 'now_showing';

    // MERGE (Insert nếu chưa có, Update nếu đã có)
    const mergeSql = `
      MERGE INTO MOVIES m
      USING (SELECT :id AS MOVIE_ID FROM dual) src
      ON (m.MOVIE_ID = src.MOVIE_ID)
      WHEN MATCHED THEN
        UPDATE SET
          TITLE = :title,
          IMAGE = :image,
          IS_HOT = :isHot,
          GENRE = :genre,
          DURATION = :duration,
          RATING = :rating,
          SYNOPSIS = :synopsis,
          STATUS = :status
      WHEN NOT MATCHED THEN
        INSERT (MOVIE_ID, TITLE, IMAGE, IS_HOT, GENRE, DURATION, RATING, SYNOPSIS, STATUS)
        VALUES (:id, :title, :image, :isHot, :genre, :duration, :rating, :synopsis, :status)
    `;

    await db.execute(mergeSql, {
      id: movieId,
      title: title.trim(),
      image: image ? image.trim() : 'assets/images/poster(hot).webp',
      isHot: isHotVal,
      genre: genre ? genre.trim() : 'Hành động',
      duration: duration ? duration.trim() : '120 phút',
      rating: rating ? rating.trim() : 'P',
      synopsis: synopsis ? synopsis.trim() : '',
      status: movieStatus,
    });

    return res.json({
      success: true,
      message: 'Lưu thông tin phim thành công.',
      data: { id: movieId },
    });
  } catch (err) {
    console.error('[MovieController.saveMovie]', err);
    return res.status(500).json({ success: false, message: 'Lỗi lưu phim: ' + err.message });
  }
}

// Xóa phim (Admin)
async function deleteMovie(req, res) {
  try {
    const { id } = req.params;
    const sql = `DELETE FROM MOVIES WHERE MOVIE_ID = :id`;
    await db.execute(sql, { id });
    return res.json({ success: true, message: 'Xóa phim thành công.' });
  } catch (err) {
    console.error('[MovieController.deleteMovie]', err);
    return res.status(500).json({ success: false, message: 'Lỗi xóa phim: ' + err.message });
  }
}

module.exports = {
  getMovies,
  getMovieById,
  saveMovie,
  deleteMovie,
};
