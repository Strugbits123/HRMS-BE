import { Router } from 'express';
import {
    createAsset,
    getAllAssets,
    assignAsset,
    returnAsset
} from './asset.controller.js';

const router = Router();

router.post('/', createAsset);
router.get('/', getAllAssets);
router.post('/:id/assign', assignAsset);
router.post('/:id/return', returnAsset);

export default router;