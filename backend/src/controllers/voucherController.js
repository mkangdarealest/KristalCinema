const db = require('../config/db');

// Lấy danh sách Voucher (kèm thông tin id, code, discountAmount, minPrice, isActive)
async function getVouchers(req, res) {
  try {
    const sql = `
      SELECT VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE,
             TO_CHAR(EXPIRY_DATE, 'YYYY-MM-DD"T"HH24:MI:SS') AS EXPIRY_DATE
      FROM VOUCHERS
      ORDER BY CREATED_AT DESC
    `;
    const result = await db.execute(sql);

    const vouchers = (result.rows || []).map((v) => ({
      id: v.VOUCHER_ID,
      code: v.CODE,
      discountAmount: v.DISCOUNT_AMOUNT,
      minPrice: v.MIN_PRICE,
      isActive: v.IS_ACTIVE === 1,
      expiryDate: v.EXPIRY_DATE,
    }));

    return res.json({ success: true, data: vouchers });
  } catch (err) {
    console.error('[VoucherController.getVouchers]', err);
    return res.status(500).json({ success: false, message: 'Lỗi tải voucher: ' + err.message });
  }
}

// Kiểm tra mã voucher hợp lệ
async function verifyVoucher(req, res) {
  try {
    const { code } = req.params;
    if (!code) {
      return res.status(400).json({ success: false, message: 'Thiếu mã voucher.' });
    }

    const sql = `
      SELECT VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE,
             TO_CHAR(EXPIRY_DATE, 'YYYY-MM-DD"T"HH24:MI:SS') AS EXPIRY_DATE
      FROM VOUCHERS
      WHERE UPPER(CODE) = :code
        AND IS_ACTIVE = 1
        AND (EXPIRY_DATE IS NULL OR EXPIRY_DATE >= CURRENT_TIMESTAMP)
    `;

    const result = await db.execute(sql, { code: code.toUpperCase().trim() });

    if (!result.rows || result.rows.length === 0) {
      return res.json({ success: false, message: 'Mã voucher không tồn tại hoặc đã hết hạn.' });
    }

    const v = result.rows[0];
    return res.json({
      success: true,
      data: {
        id: v.VOUCHER_ID,
        code: v.CODE,
        discountAmount: v.DISCOUNT_AMOUNT,
        minPrice: v.MIN_PRICE,
        isActive: v.IS_ACTIVE === 1,
      },
    });
  } catch (err) {
    console.error('[VoucherController.verifyVoucher]', err);
    return res.status(500).json({ success: false, message: 'Lỗi kiểm tra voucher: ' + err.message });
  }
}

// Lưu voucher (Thêm mới hoặc Cập nhật)
async function saveVoucher(req, res) {
  try {
    const { id, code, discountAmount, minPrice, isActive } = req.body;
    if (!code || !discountAmount) {
      return res.status(400).json({ success: false, message: 'Mã và số tiền giảm không được để trống.' });
    }

    const voucherId = id && id.trim().length > 0 ? id : 'v_' + Date.now();
    const cleanCode = code.toUpperCase().trim();
    const discount = parseInt(discountAmount, 10) || 0;
    const minP = parseInt(minPrice, 10) || 0;
    const active = isActive === false || isActive === 0 || isActive === '0' ? 0 : 1;

    const mergeSql = `
      MERGE INTO VOUCHERS v
      USING (SELECT :id AS VOUCHER_ID FROM dual) src
      ON (v.VOUCHER_ID = src.VOUCHER_ID)
      WHEN MATCHED THEN
        UPDATE SET CODE = :code, DISCOUNT_AMOUNT = :discount, MIN_PRICE = :minP, IS_ACTIVE = :active
      WHEN NOT MATCHED THEN
        INSERT (VOUCHER_ID, CODE, DISCOUNT_AMOUNT, MIN_PRICE, IS_ACTIVE, EXPIRY_DATE)
        VALUES (:id, :code, :discount, :minP, :active, SYSTIMESTAMP + INTERVAL '60' DAY)
    `;

    await db.execute(mergeSql, {
      id: voucherId,
      code: cleanCode,
      discount,
      minP,
      active,
    });

    return res.json({ success: true, message: 'Lưu voucher thành công.', data: { id: voucherId } });
  } catch (err) {
    console.error('[VoucherController.saveVoucher]', err);
    return res.status(500).json({ success: false, message: 'Lỗi lưu voucher: ' + err.message });
  }
}

// Xóa voucher
async function deleteVoucher(req, res) {
  try {
    const { id } = req.params;
    await db.execute(`DELETE FROM VOUCHERS WHERE VOUCHER_ID = :id`, { id });
    return res.json({ success: true, message: 'Xóa voucher thành công.' });
  } catch (err) {
    console.error('[VoucherController.deleteVoucher]', err);
    return res.status(500).json({ success: false, message: 'Lỗi xóa voucher: ' + err.message });
  }
}

module.exports = {
  getVouchers,
  verifyVoucher,
  saveVoucher,
  deleteVoucher,
};
