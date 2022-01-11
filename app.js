import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'
import crypto from 'crypto'
import cors from 'cors'
import aws from 'aws-sdk'
import path from 'path'

const app = express();
const port = 3333;
const writeDirectory = "./write/";
const readDirectory = "./read/";
const encoding = "utf8"

app.use(fileUpload());
app.use(express.json())
app.use(cors());

let generateRandomFileName = () => {
    const fileNumber = crypto.randomUUID().slice(0, 6);
    const sessionNumber = crypto.randomUUID().slice(0, 6)
    const fileType = ".json"
    return `file-${fileNumber}-session-${sessionNumber}${fileType}`;
}

app.post('/api/file', (req, res) => {
    console.log(`File successfully uploaded: ${req.files.file.name}`)
    const bufferedFile = req.files.file.data;
    try {
        JSON.parse(bufferedFile.toString(encoding))
    } catch (error) {
        console.log("File was not valid JSON\n" + error)
        res.sendStatus(400);
        return;
    }

    const s3 = new aws.S3()
    const bucketname = ''
    let uploadParams = {Bucket: bucketname, Key: '', Body: ''};

    // ----------- Alternative 1 --------------------------------------------------------------------
    // Speichert das ankommende File lokal zwischen und liest es dann erneut, um AWS Tutorial nachzumachen.
    const filePath = writeDirectory + generateRandomFileName();

    fs.writeFile(filePath, bufferedFile, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The file has been saved to ${filePath}`);
    })

    const fileStream = fs.createReadStream(filePath);
    fileStream.on('error', (err) => {
        console.log('Error reading file', err)
    });

    uploadParams.Body = fileStream;
    uploadParams.key = path.basename(filePath)

    // // ----------- Alternative 2 --------------------------------------------------------------------
    // // Gibt direkt den gesendeten InputBuffer weiter ohne ihn zu speichern
    //
    // uploadParams.Body = bufferedFile;
    // uploadParams.key = generateRandomFileName();
    // // ----------- Alternative 2 Ende --------------------------------------------------------------------

    s3.upload(uploadParams, (err, data) => {
        if(err) {
            console.log('Error', err);
        } if (data) {
            console.log('Upload Success', data.Location);
        }
    })



    fs.writeFile(filePath, bufferedFile, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The file has been saved to ${filePath}`);
    })

    let jsonResponse = {
        "status": "OK",
        "message": "File successfully uploaded",
        "data": {
            "name": req.files.file.name,
            "mime": req.files.file.mimetype,
            "size": req.files.file.size
        }
    }
    res.status(200);
    res.send(jsonResponse);
});

app.post('/api/json', (req, res) => {
    console.log(req.body);

    const filePath = writeDirectory + generateRandomFileName()
    const jsonString = JSON.stringify(req.body);

    fs.writeFile(filePath,jsonString, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The JSON has been saved as file to ${filePath}`);
    })

    res.sendStatus(200)
})

app.get('/', (req, res) => {
    res.send('Server is listening at port ' + port);
});

const server = app.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
