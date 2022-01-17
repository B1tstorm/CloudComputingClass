import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'
import * as websocket from 'ws'
import http from 'http'
import cors from 'cors'
import path from 'path'

import * as utilities from './src/utilities.js'
import {log} from './src/logging.js'
import * as aws from './src/awsConnect.js'

const app = express();
const port = 3333;
const server = http.createServer(app)
const websocketServer = new websocket.WebSocketServer({noServer: true, path: "/websocket"})
const writeDirectory = "./write/";
const encoding = "utf8"
const registeredClients = new Map();

app.use(fileUpload());  // use fileupload middleware for convenience
app.use(express.json()) // enable json parsing for middleware
app.use(cors());    // enable cross-origin-resource-sharing

// use existing server for websockets, not a dedicated server, both have same port
server.on("upgrade", (request, socket, head) => {
    websocketServer.handleUpgrade(request, socket, head, (websocket) => {
        websocketServer.emit("connection", websocket, request);
    })
})

websocketServer.on('connection', (websocketConnection, connectionRequest) => {
    const [_path, parameters] = connectionRequest?.url?.split("=");
    const connectionId = parameters;
    websocketConnection.isAlive = true;

    websocketConnection.send(JSON.stringify({response: `Websocket established for clientId: ${connectionId}`}))
    registeredClients.set(connectionId, websocketConnection);

    log.info(`Registered Client with clientId: ${parameters}`)

    websocketConnection.on("message", (message) => {
        log.info("Message received: " + message)
    })

    websocketConnection.on("pong", () => {
        websocketConnection.isAlive = true;
        log.info("pong received from " + connectionId + " is alive")
    })

    websocketConnection.on("close", () => {
        if (registeredClients.has(connectionId)) {
            log.info("Connection disconnected, removing: " + connectionId)
            registeredClients.delete(connectionId)
        }
    })
})

// Healthcheck for Websockets
const interval = setInterval( function healthCheck() {
    registeredClients.forEach((client, clientId) => {
        if(client.isAlive === false) {
            log.info("Client is being terminated and removed: " + clientId)
            registeredClients.delete(clientId)
            return
        }
        client.isAlive = false;
        client.ping();
    })
}, 10000)

app.post('/api/parsed', (req, res) => {
    log.debug("req.body = " + req.body)
    log.info("parsed.req.body = " + JSON.stringify(req.body))
    const object = req.body;
    log.info(object.clientid)
    if (object.clientid === undefined) {
        log.info("Received JSON did not content clientId")
    }
    if (registeredClients.has(object.clientid)) {
        registeredClients.get(object.clientid).send(JSON.stringify({
            message: `File has been parsed to: ${object.clientid}.csv`,
            clientId: object.clientid
        }))
    } else {
        log.info("Client is not registered, cliendId: " + object.clientid)
    }
    // aws.downloadFile("input/0356b7b5-151.json")

    res.sendStatus(200);
});


app.post('/api/file', (req, res) => {

    let generatedFileName = utilities.generateRandomFileName();
    //local path to write temp file to
    const filePath = writeDirectory + generatedFileName

    let jsonResponse = {
        status: "",
        message: "",
        clientId: "",
        data: {}
    };

    if (utilities.isFile(req)) {
        // Data is received as streambuffer
        const bufferedFile = req.files.file.data;
        // validate JSON entity
        try {
            JSON.parse(bufferedFile.toString(encoding))
        } catch (error) {
            log.info("File was not valid JSON\n" + error)
            res.sendStatus(400);
            return;
        }
        // save file locally
        fs.writeFile(filePath, bufferedFile, encoding, (error) => {
            if (error) return log.info(error);
            log.info(`The file has been saved to ${filePath}`);
        })
        log.info(`File successfully uploaded: ${req.files.file.name}`)

        jsonResponse.status = "OK";
        jsonResponse.message = "File successfully uploaded";
        jsonResponse.data = {
            name: req.files.file.name,
            mimetype: req.files.file.mimetype,
            size: req.files.file.size
        };
    } else {
        log.info(`JSON received: ${JSON.stringify(req.body)}`);
        // prefix received JSON file with id for storing it in database
        const idPrefixedJsonString = utilities.prefixJson(req.body);
        // save file locally
        fs.writeFile(filePath, idPrefixedJsonString, encoding, (error) => {
            if (error) return log.info(error);
            log.info(`The JSON has been saved as file to ${filePath}`);
        })

        jsonResponse.status = "OK";
        jsonResponse.message = "JSON successfully uploaded";
    }

    const fileName = path.basename(filePath)
    const fileStream = fs.createReadStream(filePath);
    fileStream.on('error', (err) => {
        log.info('Error reading file', err)
    });

    log.info(`Filename: ${fileName}, Filepath: ${filePath}`);

    aws.upload(fileStream, fileName);

    const clientId = generatedFileName.slice(0,6);
    log.info("client registered with id: " + clientId)
    jsonResponse.clientId = clientId;

    res.status(200);
    res.send(jsonResponse);
});

server.listen(port, () => {
    log.info(`Listening at http://localhost:${port}/file`)
    log.info(`Listening at ws://localhost:${port}/websocket`)
})
