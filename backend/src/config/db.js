const oracledb = require('oracledb');
require('dotenv').config();

// Sử dụng chế độ Thin Mode (mặc định từ node-oracledb v6+, không cần cài Oracle Instant Client)
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.autoCommit = true;

const dbConfig = {
  user: process.env.ORACLE_USER || 'KRISTAL_CINEMA',
  password: process.env.ORACLE_PASSWORD || 'Kristal#2026',
  connectString: process.env.ORACLE_CONNECT_STRING || 'localhost:1521/FREEPDB1',
  poolMin: 2,
  poolMax: 10,
  poolIncrement: 2,
};

let pool;

async function initializePool() {
  try {
    pool = await oracledb.createPool(dbConfig);
    console.log('[DB] Oracle Database 23ai connection pool initialized successfully (Thin Mode).');
  } catch (err) {
    console.error('[DB] Error initializing Oracle connection pool:', err.message);
    throw err;
  }
}

async function closePool() {
  if (pool) {
    try {
      await pool.close(10);
      console.log('[DB] Oracle connection pool closed.');
    } catch (err) {
      console.error('[DB] Error closing pool:', err.message);
    }
  }
}

async function execute(sql, binds = {}, options = {}) {
  let connection;
  try {
    if (!pool) {
      await initializePool();
    }
    connection = await pool.getConnection();
    const result = await connection.execute(sql, binds, options);
    return result;
  } catch (err) {
    console.error(`[DB] SQL Execution Error: ${err.message}\nSQL: ${sql}`);
    throw err;
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error('[DB] Error closing connection:', err.message);
      }
    }
  }
}

module.exports = {
  initializePool,
  closePool,
  execute,
  oracledb,
};
