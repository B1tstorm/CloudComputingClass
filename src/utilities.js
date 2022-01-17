import crypto from 'crypto'
import {log} from './logging.js'

export function generateRandomFileName() {
    const fileNumber = generateUuid(12)
    const fileType = ".json"
    return `${fileNumber}${fileType}`;
}

export function generateUuid(length = 6) {
    return crypto.randomUUID().slice(0, length);
}

export function prefixJson(json) {
    const jsonString = JSON.stringify(json);
    const id = generateUuid();
    return `{"id":"${id}",` + jsonString.substring(1);
}

export function isFile(req) {
    log.info(`Request contains File: ${req.hasOwnProperty('files')}`);
    return req.hasOwnProperty('files');
}