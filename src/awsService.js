import {log} from './logging.js'
import {S3Client, GetObjectCommand, ListObjectsCommand, PutObjectCommand, DeleteObjectCommand} from '@aws-sdk/client-s3'
import fs from 'fs'
import {Readable} from 'stream'

const S3_CLIENT = new S3Client();
const BUCKET_NAME = 'backendbucket-123'
const FILE_PATH_PREFIX = 'input/'
let parameters = {Bucket: BUCKET_NAME, Key: '', Body: ''};

export const download = async (filepath) => {

    const parameters = {
        Bucket: BUCKET_NAME,
        Key: filepath
    }

    try {
        const streamToString = (stream) => {
            return new Promise((resolve, reject) => {
                const _chunks = [];
                stream.on("data", (chunk) => _chunks.push(chunk));
                stream.on("error", reject);
                stream.on("end", () => resolve(Buffer.concat(_chunks).toString("utf8")))
            });
        }
        const data = await S3_CLIENT.send(new GetObjectCommand(parameters));

        const bodyContents = await streamToString(data.Body);
        console.log(bodyContents)
        return bodyContents;

    } catch (error) {
        log.error("Error downloading", error);
    }
};

export const upload = async (filestream, fileName) => {

    parameters.Body = filestream;
    parameters.Key = FILE_PATH_PREFIX + fileName;

    try {
        const _cmd = new PutObjectCommand(parameters);
        const _data = await S3_CLIENT.send(_cmd);
        log.info(`File: ${fileName} successfully uploaded to Bucket: ${parameters.Bucket}`)
    } catch (error) {
        log.error("Error: ", error)
    }
}

export const searchForFile = async (filename, bucket = BUCKET_NAME) => {

    let filelist = await listAllFilesAsNamesFromS3(bucket)
    let fileUris = filter(filename, filelist);
    log.info(fileUris);

}

/**
 * Returns an array of exisiting filenames from S3 Bucket
 * @param name of the bucket
 * @returns {Promise<*[]>} Returns an array of filenames as Promise
 */
const listAllFilesAsNamesFromS3 = async (bucketName) => {

    const bucketParams = {
        Bucket: bucketName
    };

    try {
        const cmd = new ListObjectsCommand(bucketParams)
        const data = await S3_CLIENT.send(cmd)
        const filenames = [];
        data.Contents.forEach((file) => {
            filenames.push(file.Key)
        })
        return filenames
    } catch (error) {
        console.log(error)
    }
}

const filter = (filename, array ) => {
    return array.filter((file) => {
        return file.includes(filename);
    })
}

export const downloadLocally = async (filepath) => {

    const dataString = await download(filepath);

    const readable = Readable.from([dataString]);
    let writeStream = fs.createWriteStream(`./write/newFile.json`);
    readable.pipe(writeStream);

}

export const downloadAndSaveFile = async (remoteFileUri, localDirectory, newFileName) => {

    const dataString = await download(remoteFileUri);
    await saveLocally(dataString, localDirectory, newFileName)

}

export const saveLocally = async (dataAsString, localDirectory, newFileName) => {
    const readable = Readable.from([dataAsString]);
    let writeStream = fs.createWriteStream(localDirectory + newFileName);
    readable.pipe(writeStream);
}

export const deleteFile = async (fileUri, bucketname = BUCKET_NAME) => {

    parameters.Bucket = bucketname;
    parameters.Key = fileUri;

    try {
        const _cmd = new DeleteObjectCommand(parameters);
        const _data =  await S3_CLIENT.send(_cmd);
        log.info("Object successfully deleted", _data)
    } catch (error) {
        log.error("Error", error)
    }

}