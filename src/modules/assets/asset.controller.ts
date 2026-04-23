import type { Request, Response } from 'express';
import { Prisma } from '../../generated/prisma/client/client.js';
import prisma from '../../config/db.js';
import { catchAsync } from '../../utils/catchAsync.js';
import { AppError } from '../../utils/AppError.js';
import { ApiResponse } from '../../utils/ApiResponse.js';

// CREATE ASSET
export const createAsset = catchAsync(async (req: Request, res: Response) => {
    const data = req.body;

    const existingAsset = await prisma.asset.findUnique({
        where: { serialNumber: data.serialNumber }
    });

    if (existingAsset) {
        throw new AppError('An asset with this serial number already exists.', 400);
    }

\    const newAsset = await prisma.asset.create({
    data: {
        title: data.title,
        serialNumber: data.serialNumber,
        category: data.category, // IT or ADMIN
        subCategory: data.subCategory,
        purchaseDate: data.purchaseDate ? new Date(data.purchaseDate) : null,
        purchaseCost: data.purchaseCost ? Number(data.purchaseCost) : null,
        vendorName: data.vendorName || null,
        warrantyExpiry: data.warrantyExpiry ? new Date(data.warrantyExpiry) : null,
        condition: data.condition || 'NEW',
        status: 'AVAILABLE',
    }
});

ApiResponse.send(res, 201, 'Asset added to inventory successfully', newAsset);
});

// GET ALL ASSETS
export const getAllAssets = catchAsync(async (req: Request, res: Response) => {
    const assets = await prisma.asset.findMany({
        include: {
            assignedTo: {
                select: { firstName: true, lastName: true, employeeId: true }
            }
        },
        orderBy: { createdAt: 'desc' }
    });

    ApiResponse.send(res, 200, 'Assets retrieved successfully', assets);
});

// ASSIGN ASSET TO EMPLOYEE
export const assignAsset = catchAsync(async (req: Request, res: Response) => {
    const { id: assetId } = req.params;
    const { employeeId, issueDate, issuedById, conditionAtIssue, issueRemarks } = req.body;

    const asset = await prisma.asset.findUnique({ where: { id: assetId } });
    if (!asset) throw new AppError('Asset not found', 404);
    if (asset.status !== 'AVAILABLE') throw new AppError(`Asset is currently ${asset.status} and cannot be assigned.`, 400);

    const [assignmentRecord, updatedAsset] = await prisma.$transaction([
        prisma.assetAssignment.create({
            data: {
                assetId,
                employeeId,
                issueDate: new Date(issueDate),
                issuedById,
                conditionAtIssue,
                issueRemarks: issueRemarks || null,
            }
        }),

        prisma.asset.update({
            where: { id: assetId },
            data: {
                status: 'ASSIGNED',
                assignedToId: employeeId,
                assignmentDate: new Date(issueDate),
                conditionAtIssue,
                assignmentRemarks: issueRemarks || null,
            }
        })
    ]);

    ApiResponse.send(res, 200, 'Asset assigned successfully', updatedAsset);
});

// RETURN ASSET TO INVENTORY
export const returnAsset = catchAsync(async (req: Request, res: Response) => {
    const { id: assetId } = req.params;
    const { returnDate, returnedToId, conditionAtReturn, damageNotes } = req.body;

    const asset = await prisma.asset.findUnique({ where: { id: assetId } });
    if (!asset) throw new AppError('Asset not found', 404);
    if (asset.status !== 'ASSIGNED' || !asset.assignedToId) {
        throw new AppError('This asset is not currently assigned to anyone.', 400);
    }

    const openAssignment = await prisma.assetAssignment.findFirst({
        where: {
            assetId,
            employeeId: asset.assignedToId,
            returnDate: null
        }
    });

    if (!openAssignment) {
        throw new AppError('Could not find an active assignment record for this asset.', 500);
    }

    const [closedAssignment, returnedAsset] = await prisma.$transaction([
        prisma.assetAssignment.update({
            where: { id: openAssignment.id },
            data: {
                returnDate: new Date(returnDate),
                returnedToId,
                conditionAtReturn,
                damageNotes: damageNotes || null,
            }
        }),

        prisma.asset.update({
            where: { id: assetId },
            data: {
                status: 'AVAILABLE',
                assignedToId: null,
                assignmentDate: null,
                conditionAtIssue: null,
                assignmentRemarks: null,
                condition: conditionAtReturn,
            }
        })
    ]);

    ApiResponse.send(res, 200, 'Asset returned to inventory successfully', returnedAsset);
});