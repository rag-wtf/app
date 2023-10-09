//const backendUrl = "http://localhost:8000/ingest";
const backendUrl =
    "https://avrxsvqa57at4c54zb54uo4wfu0onjio.lambda-url.us-east-1.on.aws/ingest";
const allowedExtensions = "txt,pdf,html,md,ppt,pptx,doc,docx,epub,eml,gz";
const unknownFileName = "Unknown";
const fileStreamExceptionMessage = "Cannot read file from null stream!";
const maximumFileSize = "The maximum file size to upload is 10MB.";
const uploadFileZoneMessage = "Click or tap here to upload file";
const uploadProgressSemanticsLabel = "upload progress";
const processProgressSemanticsLabel = "process progress";
