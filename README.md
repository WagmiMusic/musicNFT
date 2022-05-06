### musicNFT

## Fulfill mandatory values
* .env
```
NODE_ENV=dev
APP_ID= YOUR_MORALIS_APPLICATION_ID
API_URL= YOUR_MORALIS_API_URL
API_KEY= YOUR_MORALIS_API_KEY
SERVER_URL= YOUR_MORALIS_SERVER_URL
MASTER_KEY= YOUR_MORALIS_MASTER_KEY
ETH_CONTRACT_ADDRESS= "" //fulfill later
MATIC_CONTRACT_ADDRESS= "" //fulfill later
```
* secrets.json
```json
{
    "privateKey": "YOUR_WALLET_PRIVATE_KEY",
    "alchemyApiKey": "YOUR_ALCHEMY_API_KEY"
}
```
## deploy
# for Ethereum
rinkebyにデプロイ
本番環境: rinkeby => ethereum
'''
npx hardhat run --network rinkeby scripts/deploy.js
'''
以下の値が表示されるので
ETH_CONTRACT_ADDRESSを保存しておく
'''
NFT deployed to: ETH_CONTRACT_ADDRESS
GasPrice(gwei): GAS_PRICE
GasLimit: GAS_LIMIT
GasFee: GAS_FEE
'''
* Fulfill mandatory values
* .env
```
ETH_CONTRACT_ADDRESS= "ETH_CONTRACT_ADDRESS"
```
全てのNFTを一括ミントします
本番環境: rinkeby => ethereum
'''
npx hardhat run --network rinkeby scripts/mint/mint_eth.js
'''
# for Polygon(matic)
mumbai(matic_testnet)にデプロイ
本番環境: mumbai => matic_mainnet
'''
npx hardhat run --network matic_testnet scripts/deploy.js
'''
以下の値が表示されるので
MATIC_CONTRACT_ADDRESSを保存しておく
'''
NFT deployed to: MATIC_ONTRACT_ADDRESS
GasPrice(gwei): GAS_PRICE
GasLimit: GAS_LIMIT
GasFee: GAS_FEE
'''
* Fulfill mandatory values
* .env
```
MATIC_CONTRACT_ADDRESS= "MATIC_ONTRACT_ADDRESS"
```
全てのNFTを一括ミントします
本番環境: mumbai => matic_mainnet
'''
npx hardhat run --network rinkeby scripts/mint/mint_matic.js
'''
## Verify contract code
# for etherscan
etherscanにコントラクトを登録し，UIで実行できるようにします
本番環境: rinkeby => ethereum
          0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA => ...
'''
npx hardhat verify --network rinkeby ETH_CONTRACT_ADDRESS "WAGMI Music" "disc" "0x79a63d6d8BBD5c6dfc774dA79bCcD948EAcb53FA" "1" "5"
'''
# for polygonscan
etherscanにコントラクトを登録し，UIで実行できるようにします
hardhat.config.jsを書き換え
'''js
etherscan: {
// apiKey: etherscanApiKey // コメントアウト
apiKey: polygonscanApiKey // コメントイン
}
'''
本番環境: mumbai => matic_mainnet
          0xf69186dfBa60DdB133E91E9A4B5673624293d8F8 => ...
'''
npx hardhat verify --network mumbai MATIC_CONTRACT_ADDRESS "WAGMI Music" "disc" "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8" "6" "18"
'''
### option: OmniChain
## setTrustedRemote
# for Ethereum
本番環境: rinkeby => ethereum
'''
npx hardhat run --network rinkeby scripts/setTrustedRemote/str_eth.js
'''
# for Polygon
本番環境: mumbai => matic_mainnet
'''
npx hardhat run --network mumbai scripts/setTrustedRemote/str_matic.js
'''
## send Omnichain NFT
# Ethereum to Polygon
'''
npx hardhat run --network rinkeby scripts/omniSend/send_eth.js
'''
# Polygon to Ethereum
'''
npx hardhat run --network mumbai scripts/omniSend/send_matic.js
'''
# start sale
Etherscan,PolygonscanのUIで実行
# finish presale
Etherscan,PolygonscanのUIで実行
# option: reveal or suspend sale for emergency
Etherscan,PolygonscanのUIで実行
