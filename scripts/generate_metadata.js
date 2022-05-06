// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

const Moralis = require("moralis/node");
const request = require("request");
const fs = require("fs");
const { default: axios } = require("axios");
const { editionSize, assetElement } = require("../asset/config.js");

const serverUrl = process.env.SERVER_URL;
const appId = process.env.APP_ID;
const masterKey = process.env.MASTER_KEY;
const apiUrl = process.env.API_URL;
const apiKey = process.env.API_KEY;

Moralis.start({ serverUrl, appId, masterKey});

const btoa = (text) => {
  return Buffer.from(text, "binary").toString("base64");
}

// ローカルにmetadataを書き込み
const writeMetaData = (metadata) => {
  fs.writeFileSync("./output/_metadata.json", JSON.stringify(metadata));
};

// モラリスにアップロード
const saveToDb = async (metaHash) => {
  for(let i = 1; i < editionSize + 1; i++){
    let id = i.toString();
    let paddedHex = (
      "0000000000000000000000000000000000000000000000000000000000000000" + id
    ).slice(-64);
    let url = `https://ipfs.moralis.io:2053/ipfs/${metaHash}/metadata/${paddedHex}.json`;
    let options = { json: true };
  
    request(url, options, (error, res, body) => {
      if (error) {
        return console.log(error);
      }
  
      if (!error && res.statusCode == 200) {
        // moralisのダッシュボードにセーブ
        const FileDatabase = new Moralis.Object("Metadata");
        FileDatabase.set("BookName", body.name);
        FileDatabase.set("Description", body.description);
        FileDatabase.set("image", body.image);
        FileDatabase.set("attributes", body.animation_url);
        FileDatabase.set("meta_hash", metaHash);
        FileDatabase.save();
      }
    });
  }
};

const uploadImage = async () => {
  const UrlArray = [];

  for (let i = 1; i < editionSize + 1; i++) {
    let id = i.toString();
    let image_base64, music_base64, ifiletype, mfiletype;
    
    // データをIPFSにアップロード
    if(fs.existsSync(`./asset/${id}/image.jpg`)){
      image_base64 = await btoa(fs.readFileSync(`./asset/${id}/image.jpg`));
      ifiletype = "jpg";
    } else if(fs.existsSync(`./asset/${id}/animation.gif`)) {
      image_base64 = await btoa(fs.readFileSync(`./asset/${id}/animation.gif`, (err,data) => {
        console.log(err)
      }));
      ifiletype = "gif";
    }
    if(fs.existsSync(`./asset/${id}/music.wav`)){
      music_base64 = await btoa(fs.readFileSync(`./asset/${id}/music.wav`));
      mfiletype = "wav";
    } else if(fs.existsSync(`./asset/${id}/music.mp3`)) {
      music_base64 = await btoa(fs.readFileSync(`./asset/${id}/music.mp3`));
      mfiletype = "mp3";
    } else if(fs.existsSync(`./asset/${id}/music.mp4`)) {
      music_base64 = await btoa(fs.readFileSync(`./asset/${id}/music.mp4`, (err,data) => {
        console.log(err)
      }));
      mfiletype = "mp3";
    }

    let image_file = new Moralis.File("image", { base64: `data:image/${ifiletype};base64,${image_base64}` });
    let music_file = new Moralis.File("music", { base64: `data:audio/${mfiletype};base64,${music_base64}` });
    await image_file.saveIPFS({ useMasterKey: true });
    await music_file.saveIPFS({ useMasterKey: true });
    console.log(`Processing ${i}/${editionSize}...`)
    console.log("IPFS address of Image: ", image_file.ipfs());
    console.log("IPFS address of Music: ", music_file.ipfs());

    UrlArray.push({
      imageURL:image_file.ipfs(), 
      musicURL:music_file.ipfs()
    })
  }

  console.log(UrlArray)
  return UrlArray
}

const createMetadata = async () => {

  const metaDataArray = [];
  const DataArray  = await uploadImage();

  for (let i = 0; i < editionSize; i++){
    let id = (i+1).toString()
    let imageURL = DataArray[i].imageURL
    let musicURL = DataArray[i].musicURL
  
    // メタデータを記述
    let metadata = {
      "name": assetElement[i].name,
      "description": assetElement[i].description,
      "image": imageURL,
      "animation_url": musicURL,
      "attributes": assetElement[i].attributes
    }
    metaDataArray.push(metadata);
  
    fs.writeFileSync(
      `./output/${id}.json`,
      JSON.stringify(metadata)
    );
  }
  writeMetaData(metaDataArray);
}

const uploadMetadata = async () => {
  const promiseArray = []; 
  const ipfsArray = []; 

  for(let i = 1; i < editionSize + 1; i++){
    let id = i.toString();
    let paddedHex = (
      "0000000000000000000000000000000000000000000000000000000000000000" + id
    ).slice(-64);
  
    // jsonファイルをipfsArrayにpush
    promiseArray.push(
      new Promise((res, rej) => {
        fs.readFile(`./output/${id}.json`, (err, data) => {
          if (err) rej();
          ipfsArray.push({
            path: `metadata/${paddedHex}.json`,
            content: data.toString("base64")
          });
          res();
        });
      })
    );
  }

  //プロミスが返ってきたらipfsArrayをapiにpost
  Promise.all(promiseArray).then(() => {
  axios
    .post(apiUrl, ipfsArray, {
      headers: {
        "X-API-Key": apiKey,
        "content-type": "application/json",
        accept: "application/json"
      }
    })
    .then(res => {
      let metaCID = res.data[0].path.split("/")[4];
      console.log("META FILE PATHS:", res.data);
      //モラリスにアップロード
      saveToDb(metaCID);
    })
    .catch(err => {
      console.log(err);
    });
  });
};

const startCreating = async () => {
  await createMetadata();
  await uploadMetadata();
};

startCreating();

