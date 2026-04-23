import type { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/AppError.js';

export const globalErrorHandler = (
    err: any,
    req: Request,
    res: Response,
    next: NextFunction
): void => {
    let statusCode = err.statusCode || 500;
    let message = err.message || 'Internal Server Error';

    // --- Prisma Errors ---
    if (err.code === 'P2002') {
        statusCode = 400;
        message = `Duplicate field value: ${err.meta?.target}. Please use another value.`;
    }

    res.status(statusCode).json({
        success: false,
        error: {
            message,
            ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
        },
    });
};