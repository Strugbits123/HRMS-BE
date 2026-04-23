import type { Response } from 'express';

export class ApiResponse {
    static send(res: Response, statusCode: number, message: string, data: any = null) {
        return res.status(statusCode).json({
            success: true,
            message,
            data,
        });
    }
}