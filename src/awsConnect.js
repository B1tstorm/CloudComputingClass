import aws from "aws-sdk";
import {log} from './logging.js'
import {S3Client, GetObjectCommand} from '@aws-sdk/client-s3'
import fs from 'fs'


const s3 = new aws.S3()
const s3Client = new S3Client();
const bucketname = 'backendbucket-123'
const filepath = 'input/'
let uploadParams = {Bucket: bucketname, Key: '', Body: ''};

export function upload(filestream, fileName) {

    uploadParams.Body = filestream;
    uploadParams.Key = filepath + fileName;

    s3.upload(uploadParams, (err, data) => {
        if (err) {
            log.info('Error', err);
        }
        if (data) {
            log.info('Upload Success', data.Location);
        }
    })
}

export const downloadFile = async (fileUri) => {

    const parameters = {
        Bucket: bucketname,
        Key: fileUri
    }

    let readStream = s3.getObject(parameters).createReadStream();
    let writeStream = fs.createWriteStream("./write/aaas.json");
    readStream.pipe(writeStream);
};

export const run = async () => {

    const parameters = {
        Bucket: bucketname,
        Key: "input/0356b7b5-151.json"
    }

    try {
        const streamToString = (stream) => {
            new Promise((resolve, reject) => {
                const chunks = [];
                stream.on("data", (chunk) => chunks.push(chunk));
                stream.on("error", reject);
                stream.on("end", () => resolve(Buffer.concat(chunks).toString("utf8")))
            });
        }
        const data = await s3Client.send(new GetObjectCommand(parameters));
        console.log("data" + data.Body);
        const bodyContents = await streamToString(data.Body);
        log.info(bodyContents);
        return bodyContents;

    } catch (error) {
        log.error("Error downloading", error);
    }
};

export const downloadFileAsString = async (fileUri) => {

    const parameters = {
        Bucket: bucketname,
        Key: fileUri
    }

    let readStream = s3.getObject(parameters).createReadStream();
    const chunks = [];
    for await (const chunk of readStream) {
        chunks.push((Buffer.from(chunk)))
    }

    let a = Buffer.concat(chunks).toString("utf-8");

    log.info(JSON.parse(a))
};


