require('dotenv').config();
const app = require('./app');
const db = require('./config/db');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Khởi tạo Connection Pool kết nối Oracle Database 23ai
    try {
      await db.initializePool();
      console.log('✅ Kết nối Oracle Database 23ai thành công!');
    } catch (dbErr) {
      console.warn('⚠️ Cảnh báo: Chưa kết nối được Oracle Database 23ai ngay lập tức.');
      console.warn('   Hãy đảm bảo Docker / Oracle 23ai Service đang chạy và các file trong database/ đã được thực thi.');
      console.warn('   Chi tiết lỗi:', dbErr.message);
    }

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`====================================================`);
      console.log(`🚀 KristalCinema REST API đang chạy tại:`);
      console.log(`   - Localhost:        http://localhost:${PORT}`);
      console.log(`   - Android Emulator: http://10.0.2.2:${PORT}`);
      console.log(`   - Health check:     http://localhost:${PORT}/api/health`);
      console.log(`====================================================`);
    });
  } catch (err) {
    console.error('❌ Lỗi khởi động server:', err);
    process.exit(1);
  }
}

process.on('SIGINT', async () => {
  console.log('\nĐang đóng máy chủ và Oracle Pool...');
  await db.closePool();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('\nĐang đóng máy chủ và Oracle Pool...');
  await db.closePool();
  process.exit(0);
});

startServer();
