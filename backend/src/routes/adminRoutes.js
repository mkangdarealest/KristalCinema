const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

router.get('/statistics', adminController.getStatistics);

module.exports = router;
