import { Router } from 'express';
import {
    createEmployee,
    getAllEmployees,
    getEmployeeById,
    updateEmployee,
    offboardEmployee
} from './employee.controller.js';

const router = Router();

router.post('/', createEmployee);
router.get('/', getAllEmployees);
router.get('/:id', getEmployeeById);
router.patch('/:id', updateEmployee);
router.post('/:id/offboard', offboardEmployee);

export default router;