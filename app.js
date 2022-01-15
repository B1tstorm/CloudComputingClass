import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'

import cors from 'cors'
import path from 'path'

import * as utilities from './src/utilities.js'
import * as aws from './src/awsConnect.js'

const app = express();
const port = 3333;
const writeDirectory = "./write/";
const encoding = "utf8"

app.use(fileUpload());  // use fileupload middleware for convenience
app.use(express.json()) // enable json parsing for middleware
app.use(cors());    // enable cross-origin-resource-sharing

const clients = new Map();

app.post('/api/file', (req, res) => {

    let generatedFileName = utilities.generateRandomFileName();
    //local path to write temp file to
    const filePath = writeDirectory + generatedFileName

    let jsonResponse = {
        status: "",
        message: "",
        clientId: ""
        // data: {}
    };

    if (!utilities.isFile(req)) {
        console.log(`JSON received: ${JSON.stringify(req.body)}`);
        // prefix received JSON file with id for storing it in database
        const idPrefixedJsonString = utilities.prefixJson(req.body);
        // save file locally
        fs.writeFile(filePath, idPrefixedJsonString, encoding, (error) => {
            if (error) return console.log(error);
            console.log(`The JSON has been saved as file to ${filePath}`);
        })

        jsonResponse.status = "OK";
        jsonResponse.message = "JSON successfully uploaded";

    } else if (utilities.isFile(req)) {
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
        // save file locally
        fs.writeFile(filePath, bufferedFile, encoding, (error) => {
            if (error) return console.log(error);
            console.log(`The file has been saved to ${filePath}`);
        })
        console.log(`File successfully uploaded: ${req.files.file.name}`)

        jsonResponse.status = "OK";
        jsonResponse.message = "File successfully uploaded";
        // jsonResponse.data = {
        //     name: req.files.file.name,
        //     mimetype: req.files.file.mimetype,
        //     size: req.files.file.size
        // };
    }

    const fileName = path.basename(filePath)
    const fileStream = fs.createReadStream(filePath);
    fileStream.on('error', (err) => {
        console.log('Error reading file', err)
    });

    console.log(`Filename: ${fileName}, Filepath: ${filePath}`);

    aws.upload(fileStream, fileName);

    const clientId = utilities.generateUUID();
    clients.set(clientId, fileName.slice(0, -5))
    jsonResponse.clientId = clientId;

    res.status(200);
    res.send(jsonResponse);
});

const server = app.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
