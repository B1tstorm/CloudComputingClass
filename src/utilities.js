import crypto from 'crypto'

export function generateRandomFileName() {
    const fileNumber = generateUUID(6)
    const sessionNumber = generateUUID(6)
    const fileType = ".json"
    return `file-${fileNumber}-session-${sessionNumber}${fileType}`;
}

export function generateUUID(length) {
    return crypto.randomUUID().slice(0, length);
}

export function prefixJson(json) {
    const jsonString = JSON.stringify(json);
    const id = crypto.randomUUID().slice(0,6);
    return `{"id":"${id}",` + jsonString.substring(1);
}