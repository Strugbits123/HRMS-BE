import type { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { Prisma } from '../../generated/prisma/client/client.js'; // Using your custom generation path
import prisma from '../../config/db.js';
import { catchAsync } from '../../utils/catchAsync.js';
import { AppError } from '../../utils/AppError.js';
import { ApiResponse } from '../../utils/ApiResponse.js';

const generateEmployeeId = async (): Promise<string> => {
  const lastEmployee = await prisma.employee.findFirst({
    orderBy: { createdAt: 'desc' },
    select: { employeeId: true },
  });

  if (!lastEmployee || !lastEmployee.employeeId) return 'EMP-0001';

  const parts = lastEmployee.employeeId.split('-');
  const lastNumber = parts.length === 2 ? parseInt(parts[1], 10) : 0;

  if (isNaN(lastNumber)) return 'EMP-0001';

  return `EMP-${(lastNumber + 1).toString().padStart(4, '0')}`;
};

// CREATE EMPLOYEE
export const createEmployee = catchAsync(async (req: Request, res: Response) => {
  const data = req.body;

  if (!data.email) {
    throw new AppError('Primary email is required to create an employee profile.', 400);
  }

  const existingUser = await prisma.employee.findFirst({
    where: {
      OR: [
        { email: data.email },
        ...(data.workEmail ? [{ workEmail: data.workEmail }] : [])
      ]
    }
  });

  if (existingUser) {
    throw new AppError('An employee with this personal or work email already exists.', 400);
  }

  const newEmployeeId = await generateEmployeeId();
  const rawPassword = Math.random().toString(36).slice(-10) + "!";
  const passwordHash = await bcrypt.hash(rawPassword, 10);

  const employeePayload: Prisma.EmployeeUncheckedCreateInput = {
    employeeId: newEmployeeId,
    passwordHash,
    role: data.role || 'EMPLOYEE',
    firstName: data.firstName || '',
    lastName: data.lastName || '',
    email: data.email,
    workEmail: data.workEmail || null,
    phone: data.phone || null,
    cnic: data.cnic || null,
    dob: data.dob ? new Date(data.dob) : null,
    gender: data.gender || null,
    maritalStatus: data.maritalStatus || null,
    address: data.address || null,
    designation: data.designation || 'TBD',
    employmentType: data.employmentType || null,
    joiningDate: data.joiningDate ? new Date(data.joiningDate) : null,
    workLocation: data.workLocation || null,
    basicSalary: data.basicSalary ? Number(data.basicSalary) : null,
    grossSalary: data.grossSalary ? Number(data.grossSalary) : null,
    bankName: data.bankName || null,
    accountTitle: data.accountTitle || null,
    iban: data.iban || null,
  };

  if (data.departmentId) {
    employeePayload.departmentId = data.departmentId;
  }

  if (data.dependents && Array.isArray(data.dependents) && data.dependents.length > 0) {
    employeePayload.dependentsList = {
      create: data.dependents.map((dep: any) => ({
        name: dep.name,
        relation: dep.relation,
        dob: dep.dob ? new Date(dep.dob) : null,
      }))
    };
  }

  const newEmployee = await prisma.employee.create({
    data: employeePayload,
    include: {
      dependentsList: true,
      department: true,
    }
  });

  const { passwordHash: _, ...safeEmployeeData } = newEmployee;

  ApiResponse.send(res, 201, 'Employee onboarded successfully!', {
    employee: safeEmployeeData,
    generatedCredentials: {
      email: data.workEmail || data.email,
      temporaryPassword: rawPassword
    }
  });
});

export const getAllEmployees = catchAsync(async (req: Request, res: Response) => {
  const employees = await prisma.employee.findMany({
    where: {
      status: { not: 'INACTIVE' }
    },
    select: {
      id: true,
      employeeId: true,
      firstName: true,
      lastName: true,
      email: true,
      workEmail: true,
      designation: true,
      department: { select: { name: true } },
      status: true,
      joiningDate: true,
      avatarUrl: true,
    },
    orderBy: { createdAt: 'desc' }
  });

  ApiResponse.send(res, 200, 'Employees retrieved successfully', employees);
});

// GET SINGLE EMPLOYEE PROFILE
export const getEmployeeById = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;

  const employee = await prisma.employee.findUnique({
    where: { id },
    include: {
      department: true,
      dependentsList: true,
      documents: true,
      assetAssignments: {
        include: { asset: true }
      },
      jobHistory: {
        orderBy: { effectiveDate: 'desc' }
      },
    }
  });

  if (!employee) {
    throw new AppError('Employee not found', 404);
  }

  const { passwordHash: _, ...safeData } = employee;
  ApiResponse.send(res, 200, 'Employee profile retrieved successfully', safeData);
});

// UPDATE EMPLOYEE
export const updateEmployee = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const data = req.body;

  const existingEmployee = await prisma.employee.findUnique({ where: { id } });
  if (!existingEmployee) {
    throw new AppError('Employee not found', 404);
  }

  const updateData: Prisma.EmployeeUpdateInput = {};

  if (data.firstName !== undefined) updateData.firstName = data.firstName;
  if (data.lastName !== undefined) updateData.lastName = data.lastName;
  if (data.phone !== undefined) updateData.phone = data.phone;
  if (data.designation !== undefined) updateData.designation = data.designation;
  if (data.workLocation !== undefined) updateData.workLocation = data.workLocation;
  if (data.address !== undefined) updateData.address = data.address;
  if (data.departmentId !== undefined) {
    updateData.department = { connect: { id: data.departmentId } };
  }

  const updatedEmployee = await prisma.employee.update({
    where: { id },
    data: updateData,
  });

  const { passwordHash: _, ...safeData } = updatedEmployee;
  ApiResponse.send(res, 200, 'Employee updated successfully', safeData);
});

// OFFBOARD EMPLOYEE (Soft Delete)
export const offboardEmployee = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { exitType, lastWorkingDay, noticePeriodServed, exitRemarks } = req.body;

  const existingEmployee = await prisma.employee.findUnique({ where: { id } });
  if (!existingEmployee) {
    throw new AppError('Employee not found', 404);
  }

  if (existingEmployee.status === 'INACTIVE') {
    throw new AppError('Employee is already offboarded', 400);
  }

  const offboardedEmployee = await prisma.employee.update({
    where: { id },
    data: {
      status: 'INACTIVE',
      exitType,
      lastWorkingDay: lastWorkingDay ? new Date(lastWorkingDay) : null,
      noticePeriodServed,
      exitRemarks,
    }
  });

  const { passwordHash: _, ...safeData } = offboardedEmployee;
  ApiResponse.send(res, 200, 'Employee has been successfully offboarded', safeData);
});