import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'
import crypto from 'crypto'
import cors from 'cors'
import WebSocket, {WebSocketServer} from 'ws';

const app = express();
const port = 3333;
const writeDirectory = "./write/";
const readDirectory = "./read/";
const encoding = "utf8"
const websocketServer = WebSocket.Server({port: 7071});

const clients = new Map();

app.use(fileUpload());
app.use(express.json())
app.use(cors());


let generateRandomFileName = () => {
    const fileNumber = crypto.randomUUID().slice(0, 6);
    const sessionNumber = crypto.randomUUID().slice(0, 6)
    const fileType = ".json"
    return `file-${fileNumber}-session-${sessionNumber}${fileType}`;
}

websocketServer.on('connection', (websocketClient) => {
    const clientId = crypto.randomUUID().slice(0,8);
    clients.set(clientId, websocketClient);
    websocketClient.send('{"Status":"Connected"}');

    websocketClient.on('message', (message) => {
        message.
    })


})

app.post('/api/file', (req, res) => {
    console.log(`File successfully uploaded: ${req.files.file.name}`)
    const bufferedFile = req.files.file.data;gt
    try {
        JSON.parse(bufferedFile.toString(encoding))
    } catch (error) {
        console.log("File was not valid JSON\n" + error)
        res.sendStatus(400);
        return;
    }



    const filePath = writeDirectory + generateRandomFileName();

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
