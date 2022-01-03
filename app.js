import express from 'express'
import fileUpload from 'express-fileupload'

const app = express();
const port = 3333;

app.use(fileUpload());

app.post('api/upload', (req, res) => {
    console.log("File successfully uploaded: ${req.files.file.name}")
    res.sendStatus(200)
});

app.get('/', (req, res) => {
    res.send('Server is listening');
})

const server = app.listen(port, () => {
    console.log(`Listening at http://localhost:${port}/api`)
})
