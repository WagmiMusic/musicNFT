const Moralis = require("moralis/node");
const fs = require("fs");
require("dotenv").config();

const ethers = Moralis.web3Library;

const btoa = (text) => {
    return Buffer.from(text, "binary").toString("base64");
}

const exFunction = async () => {
    // Moralis initiation
    const serverUrl = process.env.serverUrl;
    const appId = process.env.appId;
    const masterKey = process.env.masterKey;
    await Moralis.start({ serverUrl, appId, masterKey});

    // upload the image and metadata on IPFS and encoding the URL, then return it
    const ipfs = await getURIonIPFS();
    return ipfs
}

const uploadImage = async(data) => {
    // data from ./output/icon.png
    const image_base64 = await btoa(fs.readFileSync("./asset/image.png"));
    const music_base64 = await btoa(fs.readFileSync("./asset/music.wav"));
    const image_file = new Moralis.File("image.png", { base64: `data:image/png;base64,${image_base64}` });
    const music_file = new Moralis.File("music.wav", { base64: `data:audio/wav;base64,${music_base64}` });
    await image_file.saveIPFS({ useMasterKey: true });
    await music_file.saveIPFS({ useMasterKey: true });
    console.log("IPFS address of Image: ", image_file.ipfs());
    console.log("IPFS address of Music: ", music_file.ipfs());
    return {
        imageURL:image_file.ipfs(), 
        musicURL:music_file.ipfs()
    };
}

const getURIonIPFS = async() => {
    const {imageURL, musicURL}  = await uploadImage();

    const metadata = {
        "name": "Risin' to the top",
        "description": "Rising to the top.",
        "image": imageURL,
        "animation_url": musicURL
    }
    
    const file = new Moralis.File("file.json", { base64: btoa(JSON.stringify(metadata)) });
    await file.saveIPFS({ useMasterKey: true });
    console.log("IPFS address of metadata", file.ipfs());
    return file.ipfs();
}

exFunction()