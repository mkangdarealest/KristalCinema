const express = require('express');
const router = express.Router();
const voucherController = require('../controllers/voucherController');

router.get('/', voucherController.getVouchers);
router.get('/verify/:code', voucherController.verifyVoucher);
router.post('/', voucherController.saveVoucher);
router.delete('/:id', voucherController.deleteVoucher);

module.exports = router;
