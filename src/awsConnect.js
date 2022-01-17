import aws from "aws-sdk";
import {log} from './logging.js'


const s3 = new aws.S3()
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

