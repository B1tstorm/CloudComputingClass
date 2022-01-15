import crypto from 'crypto'

export function generateRandomFileName() {
    const fileNumber = generateUUID(12)
    const fileType = ".json"
    return `${fileNumber}${fileType}`;
}

export function generateUUID(length = 6) {
    return crypto.randomUUID().slice(0, length);
}

export function prefixJson(json) {
    const jsonString = JSON.stringify(json);
    const id = generateUUID();
    return `{"id":"${id}",` + jsonString.substring(1);
}

export function isFile(req) {
    console.log(`Request contains File: ${req.hasOwnProperty('files')}`);
    return req.hasOwnProperty('files');
}