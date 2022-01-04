import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'
import crypto from 'crypto'

const app = express();
const port = 3333;
const writeDirectory = "./write/";
const readDirectory = "./read/";
const encoding = "utf8"

app.use(fileUpload());

app.post('/api', (req, res) => {
    console.log(`File successfully uploaded: ${req.files.file.name}`)
    const bufferedFile = req.files.file.data;
    try {
        JSON.parse(bufferedFile.toString(encoding))
    } catch (error) {
        console.log("File was not valid JSON\n" + error)
        res.sendStatus(400);
        return;
    }

    const fileNumber = crypto.randomUUID().slice(0, 6);
    const sessionNumber = crypto.randomUUID().slice(0, 6)
    const fileType = ".json"
    let randomFileName = `file-${fileNumber}-session-${sessionNumber}${fileType}`;

    const filePath = writeDirectory + randomFileName;

    fs.writeFile(filePath, bufferedFile, encoding, (error) => {
        if (error) return console.log(error);
        console.log(`The file has been saved to ${filePath}`);
    })

    let jsonResponse = {
        "name" : req.files.file.name,
        "mime" : req.files.file.mimetype,
        "size" : req.files.file.size,
        "status" : "OK"
    }
    res.status(200);
    res.send(jsonResponse);
});

app.get('/', (req, res) => {
    res.send('Server is listening at port ' + port);
});

app.get('/api', (req, res) => {
    fs.readFile("./read/dummy.json", "utf8", (error, jsonString) => {
        if (error) {
            console.log("Failed to read File", error);
            return;
        }
        res.send(jsonString)
    })
});

const server = app.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
