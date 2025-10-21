// index.js
import express from 'express';
import dotenv from 'dotenv';
import winston from 'winston';

dotenv.config();

const app = express();
app.use(express.json());

// Simple logger
const logger = winston.createLogger({
  transports: [new winston.transports.Console()]
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.send('Monitoring service is running');
});

// Example metrics endpoint
app.get('/metrics', (req, res) => {
  // In real scenario, you'd collect and return monitoring data here
  res.json({
    cpuUsage: Math.random(),    // dummy CPU usage
    memoryUsage: Math.random()  // dummy memory usage
  });
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => logger.info(`Monitoring service running on port ${PORT}`));
