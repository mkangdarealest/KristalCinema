const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');

// Sơ đồ ghế và giữ chỗ
router.get('/seats/:showtimeId', bookingController.getShowtimeSeats);
router.post('/hold-seats', bookingController.holdSeats);
router.post('/calculate-price', bookingController.calculatePrice);

// Đặt vé
router.post('/confirm', bookingController.confirmBooking);

// Lịch sử
router.get('/user/:userId', bookingController.getUserBookings);
router.get('/all', bookingController.getAllBookings);

module.exports = router;
