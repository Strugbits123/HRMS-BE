import 'dotenv/config';
import express, { type Application, type Request, type Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import prisma from './config/db.js';
import { globalErrorHandler } from './middlewares/errorHandler.js';

// --- Feature Routes ---
import employeeRoutes from './modules/employees/employee.routes.js';
import assetRoutes from './modules/assets/asset.routes.js';

const app: Application = express();
const PORT = process.env.PORT || 3000;

// --- Middlewares ---
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// --- API Routes ---
app.use('/api/employees', employeeRoutes);
app.use('/api/assets', assetRoutes);

// --- Health Check Endpoint ---
app.get('/health', async (req: Request, res: Response) => {
    try {
        await prisma.$queryRaw`SELECT 1`;

        res.status(200).json({ status: 'OK', message: 'HRMS API is running and Database is connected.' });
    } catch (error) {
        res.status(500).json({ status: 'ERROR', message: 'Database connection failed.' });
    }
});

app.use(globalErrorHandler);

app.listen(PORT, () => {
    console.log(`🚀 HRMS Backend is running on http://localhost:${PORT}`);
});