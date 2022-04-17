// import dependencies
const dotenv = require("dotenv");
dotenv.config(); // setup dotenv

const Moralis = require("moralis/node");
const request = require("request");
const fs = require("fs");
const { default: axios } = require("axios");

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
  let id = "1";
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
};
const uploadImage = async () => {

  const UrlArray = [];

  // data from ./output/icon.png
  const image_base64 = await btoa(fs.readFileSync("./asset/image.png"));
  const music_base64 = await btoa(fs.readFileSync("./asset/music.wav"));
  const image_file = new Moralis.File("image.png", { base64: `data:image/png;base64,${image_base64}` });
  const music_file = new Moralis.File("music.wav", { base64: `data:audio/wav;base64,${music_base64}` });
  await image_file.saveIPFS({ useMasterKey: true });
  await music_file.saveIPFS({ useMasterKey: true });
  console.log("IPFS address of Image: ", image_file.ipfs());
  console.log("IPFS address of Music: ", music_file.ipfs());

  UrlArray.push({
    imageURL:image_file.ipfs(), 
    musicURL:music_file.ipfs()
  })

  console.log(UrlArray)
  return UrlArray
}

const createMetadata = async () => {

  const DataArray  = await uploadImage();
  const imageURL = DataArray[0].imageURL
  const musicURL = DataArray[0].musicURL

  const metadata = {
    "name": "Risin' to the top",
    "description": "Rising to the top.",
    "image": imageURL,
    "animation_url": musicURL
  }

  fs.writeFileSync(
    `./output/risingToTheTop.json`,
    JSON.stringify(metadata)
  );
  writeMetaData(metadata);
}

const uploadMetadata = async () => {
  const promiseArray = []; // array of promises so that only if finished, will next promise be initiated
  const ipfsArray = []; // holds all IPFS data

  let id = "1";
  let paddedHex = (
    "0000000000000000000000000000000000000000000000000000000000000000" + id
  ).slice(-64);

  // jsonファイルをipfsArrayにpush
  promiseArray.push(
    new Promise((res, rej) => {
      fs.readFile(`./output/risingToTheTop.json`, (err, data) => {
        if (err) rej();
        ipfsArray.push({
          path: `metadata/${paddedHex}.json`,
          content: data.toString("base64")
        });
        res();
      });
    })
  );

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

