import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'

import cors from 'cors'
import aws from 'aws-sdk'
import path from 'path'

import * as utilities from './src/utilities.js'
import * as awsConnect from './src/awsConnect.js'

const app = express();
const port = 3333;
const writeDirectory = "./write/";
const readDirectory = "./read/";
const encoding = "utf8"

app.use(fileUpload());  // use fileupload middleware for convenience
app.use(express.json()) // enable json parsing for middleware
app.use(cors());    // enable cross-origin-resource-sharing

app.post('/api/file', (req, res) => {
    console.log(`File successfully uploaded: ${req.files.file.name}`)

    // Data is received as streambuffer
    const bufferedFile = req.files.file.data;
    // validate JSON entity
    try {
        JSON.parse(bufferedFile.toString(encoding))
    } catch (error) {
        console.log("File was not valid JSON\n" + error)
        res.sendStatus(400);
        return;
    }

    const filePath = writeDirectory + utilities.generateRandomFileName();

    // save file locally
    fs.writeFile(filePath, bufferedFile, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The file has been saved to ${filePath}`);
    })

    const fileName = path.basename(filePath)
    const fileStream = fs.createReadStream(filePath);
    console.log("File Path" + filePath);
    fileStream.on('error', (err) => {
        console.log('Error reading file', err)
    });

    console.log(`Filename: ${fileName}, Filepath: ${filePath}`);

    awsConnect.upload(fileStream, fileName);

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
    // req.body is JSON object and needs to be stringified
    console.log(`JSON received: ${JSON.stringify(req.body)}`);

    let generatedFileName = utilities.generateRandomFileName();

    //local path to write temp file to
    const filePath = writeDirectory + generatedFileName

    // prefix received JSON file with id for storing it in database
    const idPrefixedJsonString = utilities.prefixJson(req.body);

    // save file locally
    fs.writeFile(filePath,idPrefixedJsonString, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The JSON has been saved as file to ${filePath}`);
    })

    const fileStream = fs.createReadStream(filePath);

    awsConnect.upload(fileStream, generatedFileName)
    res.sendStatus(200)
})

const server = app.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
