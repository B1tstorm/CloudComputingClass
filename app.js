import express from 'express'
import fileUpload from 'express-fileupload'
import fs from 'fs'
import * as websocket from 'ws'
import http from 'http'

import cors from 'cors'
import path from 'path'

import * as utilities from './src/utilities.js'
import * as aws from './src/awsConnect.js'

const app = express();
const port = 3333;
const server = http.createServer(app)
const websocketServer = new websocket.WebSocketServer({ noServer: true, path: "/websocket"})
const writeDirectory = "./write/";
const encoding = "utf8"

app.use(fileUpload());  // use fileupload middleware for convenience
app.use(express.json()) // enable json parsing for middleware
app.use(cors());    // enable cross-origin-resource-sharing

const registeredClients = new Map();

class Users {
    constructor() {
        this.userList = {};
        this.saveUser = this.saveUser.bind(this)
    }
    saveUser(userId, websocket) {
        this.userList[userId] = websocket;
    }
}

const users = new Users();

server.on("upgrade", (request, socket, head) => {
    websocketServer.handleUpgrade(request, socket, head, (websocket) => {
        websocketServer.emit("connection", websocket, request);
    })
})

websocketServer.on('connection', (websocketConnection, connectionRequest) => {
    const [_path, parameters] = connectionRequest?.url?.split("=");
    const connectionParameters = parameters;
    console.log(connectionParameters);

    websocketConnection.send("Hey there is a connection")
    registeredClients.set(parameters, websocketConnection);

    // users.saveUser(parameters, websocketConnection);

    // console.log(`Registered Client: ${parameters} with ${users.userList[parameters]}`)
    // console.log(users.userList[parameters])

    console.log(`Registered Client: ${parameters} with ` + registeredClients.get(parameters))
    console.log(registeredClients.get(parameters))
    websocketConnection.on("message", (message) => {
        websocketConnection.send("You sent: " +  message);
    })

    // sendFromAnywhere("Wow")
})

websocketServer.clients.forEach((client) => {
    client.send("Wow")
})



function sendFromAnywhere(message) {
    // const existingWebsocket = registeredClients.get(123123);
    // existingWebsocket.send("hallo");

    websocketServer.clients.forEach((client) => {
        client.send(message)
    })
}


// websocketServer.on('request', (request) => {
//     console.log(`${new Date()} – New Connection from: ${request.origin}`)
// })
app.post('/api/parsed', (req, res) => {
    console.log("req.body = " + req.body);
    console.log("parsed.req.body = " + JSON.stringify(req.body));
    const object = req.body;
    console.log(object.clientid)
    console.log(object.asda)
    if(object.clientid === undefined) {
        console.log("Received JSON did not content clientId")
    }
    if(registeredClients.has(object.clientid)) {
        registeredClients.get(object.clientid).send("This comes from another Endpoint.")
    } else {
        console.log("Client is not registered, cliendId: " + object.clientid)
    }

    res.sendStatus(200);

});


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
    // registeredClients.set(clientId, fileName.slice(0, -5))
    jsonResponse.clientId = clientId;

    // sendFromAnywhere("Outside Context")

    // websocketServer.clients.forEach((client) => client.send("hallo")) // works

    // users.userList["123123"].send("hallo was geht"); // works
    const param = "123123"
    registeredClients.get(param).send("hallo da.")

    res.status(200);
    res.send(jsonResponse);
});

server.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
