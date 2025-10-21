import express from 'express';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// Middleware (optional for now)
app.use(express.json());

// Example route for Chaos service
app.get('/', (req, res) => {
  res.json({ message: 'Chaos Service is running' });
});

// Example endpoint to trigger chaos (you’ll integrate LitmusChaos APIs later)
app.post('/trigger-chaos', (req, res) => {
  res.json({ status: 'Chaos experiment triggered (placeholder)' });
});
app.post('/trigger-chaos', async (req, res) => {
  try {
    // Example: Trigger a ChaosExperiment via Kubernetes API
    // You can use client libraries like kubernetes-client in Node.js
    res.json({ status: 'Chaos experiment triggered' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Start server
app.listen(PORT, () => {
  console.log(`⚡ Chaos Service running on port ${PORT}`);
});
