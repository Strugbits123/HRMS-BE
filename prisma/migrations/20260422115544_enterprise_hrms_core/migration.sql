/*
  Warnings:

  - The values [IN_REPAIR] on the enum `AssetStatus` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `assetTag` on the `Asset` table. All the data in the column will be lost.
  - You are about to drop the column `assignedDate` on the `Asset` table. All the data in the column will be lost.
  - You are about to drop the column `make` on the `Asset` table. All the data in the column will be lost.
  - You are about to drop the column `model` on the `Asset` table. All the data in the column will be lost.
  - You are about to drop the column `type` on the `Asset` table. All the data in the column will be lost.
  - You are about to drop the column `headId` on the `Department` table. All the data in the column will be lost.
  - You are about to drop the column `baseSalary` on the `Employee` table. All the data in the column will be lost.
  - You are about to drop the column `jobTitle` on the `Employee` table. All the data in the column will be lost.
  - You are about to drop the column `joinDate` on the `Employee` table. All the data in the column will be lost.
  - You are about to alter the column `totalDays` on the `Leave` table. The data in that column could be lost. The data in that column will be cast from `Integer` to `Decimal(4,2)`.
  - A unique constraint covering the columns `[employeeId]` on the table `Employee` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[workEmail]` on the table `Employee` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `category` to the `Asset` table without a default value. This is not possible if the table is not empty.
  - Added the required column `subCategory` to the `Asset` table without a default value. This is not possible if the table is not empty.
  - Added the required column `title` to the `Asset` table without a default value. This is not possible if the table is not empty.
  - Added the required column `designation` to the `Employee` table without a default value. This is not possible if the table is not empty.
  - Added the required column `employeeId` to the `Employee` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "MaritalStatus" AS ENUM ('SINGLE', 'MARRIED', 'DIVORCED');

-- CreateEnum
CREATE TYPE "EmploymentType" AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERNSHIP');

-- CreateEnum
CREATE TYPE "AssetCategory" AS ENUM ('IT', 'ADMIN');

-- CreateEnum
CREATE TYPE "AssetCondition" AS ENUM ('NEW', 'GOOD', 'USED', 'DAMAGED');

-- CreateEnum
CREATE TYPE "DocumentCategory" AS ENUM ('ONBOARDING', 'EDUCATIONAL', 'WARNING', 'PROMOTION', 'EXPERIENCE', 'OTHER');

-- CreateEnum
CREATE TYPE "RequestType" AS ENUM ('REGULARIZATION', 'EXEMPTION', 'WFH', 'OVERTIME', 'SHIFT_CHANGE_TEMP', 'SHIFT_CHANGE_PERM');

-- CreateEnum
CREATE TYPE "RequestStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'FORCE_APPROVED');

-- CreateEnum
CREATE TYPE "NoticeTiming" AS ENUM ('OVER_24_HOURS', 'SAME_DAY', 'UNDER_1_HOUR', 'NO_NOTICE');

-- CreateEnum
CREATE TYPE "CommunicationMode" AS ENUM ('EMAIL', 'WHATSAPP', 'CALL', 'IN_PERSON');

-- AlterEnum
BEGIN;
CREATE TYPE "AssetStatus_new" AS ENUM ('AVAILABLE', 'ASSIGNED', 'UNDER_REPAIR', 'RETIRED');
ALTER TABLE "public"."Asset" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Asset" ALTER COLUMN "status" TYPE "AssetStatus_new" USING ("status"::text::"AssetStatus_new");
ALTER TYPE "AssetStatus" RENAME TO "AssetStatus_old";
ALTER TYPE "AssetStatus_new" RENAME TO "AssetStatus";
DROP TYPE "public"."AssetStatus_old";
ALTER TABLE "Asset" ALTER COLUMN "status" SET DEFAULT 'AVAILABLE';
COMMIT;

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "AttendanceStatus" ADD VALUE 'SHORT_DAY';
ALTER TYPE "AttendanceStatus" ADD VALUE 'MISSING_PUNCH';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "EmploymentStatus" ADD VALUE 'ON_NOTICE';
ALTER TYPE "EmploymentStatus" ADD VALUE 'RESIGNED';
ALTER TYPE "EmploymentStatus" ADD VALUE 'INACTIVE';

-- AlterEnum
ALTER TYPE "LeaveType" ADD VALUE 'SHORT_LEAVE';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "UserRole" ADD VALUE 'TA';
ALTER TYPE "UserRole" ADD VALUE 'ADMIN';
ALTER TYPE "UserRole" ADD VALUE 'IT';

-- DropIndex
DROP INDEX "Asset_assetTag_key";

-- DropIndex
DROP INDEX "Asset_assignedToId_idx";

-- DropIndex
DROP INDEX "Asset_status_idx";

-- DropIndex
DROP INDEX "CalendarEvent_date_idx";

-- DropIndex
DROP INDEX "Department_headId_key";

-- DropIndex
DROP INDEX "Employee_departmentId_idx";

-- DropIndex
DROP INDEX "Employee_email_idx";

-- DropIndex
DROP INDEX "Employee_email_key";

-- DropIndex
DROP INDEX "Leave_employeeId_idx";

-- DropIndex
DROP INDEX "Leave_status_idx";

-- DropIndex
DROP INDEX "Payroll_month_year_idx";

-- AlterTable
ALTER TABLE "Asset" DROP COLUMN "assetTag",
DROP COLUMN "assignedDate",
DROP COLUMN "make",
DROP COLUMN "model",
DROP COLUMN "type",
ADD COLUMN     "assignmentDate" DATE,
ADD COLUMN     "assignmentRemarks" TEXT,
ADD COLUMN     "category" "AssetCategory" NOT NULL,
ADD COLUMN     "condition" "AssetCondition" NOT NULL DEFAULT 'NEW',
ADD COLUMN     "conditionAtIssue" "AssetCondition",
ADD COLUMN     "purchaseCost" DECIMAL(10,2),
ADD COLUMN     "purchaseDate" DATE,
ADD COLUMN     "subCategory" TEXT NOT NULL,
ADD COLUMN     "title" TEXT NOT NULL,
ADD COLUMN     "vendorName" TEXT,
ADD COLUMN     "warrantyExpiry" DATE;

-- AlterTable
ALTER TABLE "Attendance" ADD COLUMN     "checkInIp" TEXT,
ADD COLUMN     "checkInLat" DOUBLE PRECISION,
ADD COLUMN     "checkInLng" DOUBLE PRECISION,
ADD COLUMN     "checkOutIp" TEXT,
ADD COLUMN     "checkOutLat" DOUBLE PRECISION,
ADD COLUMN     "checkOutLng" DOUBLE PRECISION,
ADD COLUMN     "earlyExitReason" TEXT,
ADD COLUMN     "isHalfDay" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "isLate" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "Department" DROP COLUMN "headId";

-- AlterTable
ALTER TABLE "Employee" DROP COLUMN "baseSalary",
DROP COLUMN "jobTitle",
DROP COLUMN "joinDate",
ADD COLUMN     "accountTitle" TEXT,
ADD COLUMN     "bankName" TEXT,
ADD COLUMN     "basicSalary" DECIMAL(10,2),
ADD COLUMN     "bypassGeofence" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "bypassIp" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "cnic" TEXT,
ADD COLUMN     "designation" TEXT NOT NULL,
ADD COLUMN     "dob" DATE,
ADD COLUMN     "emergencyContact" TEXT,
ADD COLUMN     "employeeId" TEXT NOT NULL,
ADD COLUMN     "employmentType" "EmploymentType",
ADD COLUMN     "exitRemarks" TEXT,
ADD COLUMN     "exitType" TEXT,
ADD COLUMN     "gender" "Gender",
ADD COLUMN     "grossSalary" DECIMAL(10,2),
ADD COLUMN     "iban" TEXT,
ADD COLUMN     "joiningDate" DATE,
ADD COLUMN     "lastWorkingDay" DATE,
ADD COLUMN     "maritalStatus" "MaritalStatus",
ADD COLUMN     "noticePeriodServed" BOOLEAN,
ADD COLUMN     "shiftId" TEXT,
ADD COLUMN     "workEmail" TEXT,
ADD COLUMN     "workLocation" TEXT;

-- AlterTable
ALTER TABLE "Leave" ALTER COLUMN "totalDays" SET DATA TYPE DECIMAL(4,2);

-- DropEnum
DROP TYPE "AssetType";

-- CreateTable
CREATE TABLE "OfficeLocation" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "ipAddress" TEXT,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "radiusMeters" INTEGER NOT NULL DEFAULT 100,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OfficeLocation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Shift" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "startTime" TEXT NOT NULL,
    "endTime" TEXT NOT NULL,
    "graceTimeMins" INTEGER NOT NULL DEFAULT 15,
    "workingHours" DECIMAL(4,2) NOT NULL DEFAULT 9.0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Shift_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AttendanceRequest" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "type" "RequestType" NOT NULL,
    "requestDate" DATE NOT NULL,
    "timeFrom" TEXT,
    "timeTo" TEXT,
    "newShiftId" TEXT,
    "reason" TEXT NOT NULL,
    "informedInAdvance" BOOLEAN NOT NULL DEFAULT false,
    "noticeTiming" "NoticeTiming",
    "communicationMode" "CommunicationMode",
    "status" "RequestStatus" NOT NULL DEFAULT 'PENDING',
    "managerId" TEXT,
    "managerRemarks" TEXT,
    "hrRemarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AttendanceRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PenaltyRecord" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "dateApplied" DATE NOT NULL,
    "penaltyType" TEXT NOT NULL,
    "deductionDays" DECIMAL(4,2) NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PenaltyRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "performedById" TEXT NOT NULL,
    "targetEntity" TEXT NOT NULL,
    "targetId" TEXT NOT NULL,
    "details" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Dependent" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "relation" TEXT NOT NULL,
    "dob" DATE,

    CONSTRAINT "Dependent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EmployeeDocument" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "category" "DocumentCategory" NOT NULL,
    "documentName" TEXT NOT NULL,
    "fileUrl" TEXT NOT NULL,
    "uploadedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "EmployeeDocument_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SalaryHistory" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "basicSalary" DECIMAL(10,2) NOT NULL,
    "grossSalary" DECIMAL(10,2) NOT NULL,
    "effectiveDate" DATE NOT NULL,
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SalaryHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AssetAssignment" (
    "id" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "issueDate" DATE NOT NULL,
    "issuedById" TEXT NOT NULL,
    "conditionAtIssue" "AssetCondition" NOT NULL,
    "issueRemarks" TEXT,
    "returnDate" DATE,
    "returnedToId" TEXT,
    "conditionAtReturn" "AssetCondition",
    "damageNotes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AssetAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "JobHistory" (
    "id" TEXT NOT NULL,
    "employeeId" TEXT NOT NULL,
    "department" TEXT,
    "designation" TEXT NOT NULL,
    "effectiveDate" DATE NOT NULL,
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "JobHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_DepartmentHeads" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_DepartmentHeads_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "OfficeLocation_name_key" ON "OfficeLocation"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Shift_code_key" ON "Shift"("code");

-- CreateIndex
CREATE INDEX "AttendanceRequest_employeeId_idx" ON "AttendanceRequest"("employeeId");

-- CreateIndex
CREATE INDEX "AttendanceRequest_status_idx" ON "AttendanceRequest"("status");

-- CreateIndex
CREATE INDEX "_DepartmentHeads_B_index" ON "_DepartmentHeads"("B");

-- CreateIndex
CREATE UNIQUE INDEX "Employee_employeeId_key" ON "Employee"("employeeId");

-- CreateIndex
CREATE UNIQUE INDEX "Employee_workEmail_key" ON "Employee"("workEmail");

-- CreateIndex
CREATE INDEX "Employee_workEmail_idx" ON "Employee"("workEmail");

-- CreateIndex
CREATE INDEX "Employee_employeeId_idx" ON "Employee"("employeeId");

-- CreateIndex
CREATE INDEX "Employee_status_idx" ON "Employee"("status");

-- AddForeignKey
ALTER TABLE "Employee" ADD CONSTRAINT "Employee_shiftId_fkey" FOREIGN KEY ("shiftId") REFERENCES "Shift"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceRequest" ADD CONSTRAINT "AttendanceRequest_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceRequest" ADD CONSTRAINT "AttendanceRequest_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "Employee"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PenaltyRecord" ADD CONSTRAINT "PenaltyRecord_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_performedById_fkey" FOREIGN KEY ("performedById") REFERENCES "Employee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Dependent" ADD CONSTRAINT "Dependent_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EmployeeDocument" ADD CONSTRAINT "EmployeeDocument_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SalaryHistory" ADD CONSTRAINT "SalaryHistory_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AssetAssignment" ADD CONSTRAINT "AssetAssignment_assetId_fkey" FOREIGN KEY ("assetId") REFERENCES "Asset"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AssetAssignment" ADD CONSTRAINT "AssetAssignment_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "JobHistory" ADD CONSTRAINT "JobHistory_employeeId_fkey" FOREIGN KEY ("employeeId") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_DepartmentHeads" ADD CONSTRAINT "_DepartmentHeads_A_fkey" FOREIGN KEY ("A") REFERENCES "Department"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_DepartmentHeads" ADD CONSTRAINT "_DepartmentHeads_B_fkey" FOREIGN KEY ("B") REFERENCES "Employee"("id") ON DELETE CASCADE ON UPDATE CASCADE;
