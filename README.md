## 項目簡介
我們想要做的是一個NFT的流動性解決方案
用戶透過把NFT質押到智能合約裡面可以換取合約發行的代幣
每種NFT對應不同的合約也對應不同的代幣，但同一種類NFT對應同一個合約也對應同一個代幣
(ex.有專門負責質押punk的合約並發行punk coin，也有專門質押Sandbox land 的合約並發行 Sandbos’s land coin。但是 ape#1 和 ape#999 對應同一個合約，當然我們知道稀有猴的價值應該跟地板猴不一樣，這兩者應該要分成兩個合約，不過這部分暫時先不做)
代幣就跟一般的erc20代幣一樣可以被分割，也有從合約內贖回的NFT的功能
也因為每個代幣背後都有NFT作為底層資產支持，也有申購贖回的套利機制，就像以NFT價值做為錨定的穩定幣一樣，所以這個項目就叫做 NFTStableCoin
並且這個穩定幣可以通過跨鏈橋的機制在任何EVM相容的鏈上面交易

## 參考項目 NFTX : miro 架構圖  
https://miro.com/app/board/uXjVOLZwNkY=/?invite_link_id=293227344446  

## Run the project

```
npm install
truffle compile
npm install @truffle/hdwallet-provider
npm install dotenv
```

## Contracts in testnet
```
ethTestnet (rinkeby):
Migrations : 0xBB9B7d561D22F2c1Abce40E19bcBa255d5Ccc5ed
MyNFT : 0x9E097EdAF385a482a6c35E89C8De483142836B17
TokenEth : 0x495d17f225890eeb612170b6A56aaf48fAb803Cb
BridgeEth : 0x40C48f597D745284186e608822838Ec045e1dc37

bscTestnet :
Migrations : 0x9e27fACc5A0A079a68758FAa90D1B59F018Eac03
TokenBsc : 0x9c2ABb8E8E35Ed0c5D74b853C2a8c87E8B99718A
BridgeBsc : 0x6Ee622De2d936Db360FD92Bb6a49eA0aB8e1e88F
```





## Steps

### .env example
```
DEV_PRIVATE_KEY= (不加0x)
ETHERSCAN_API=
BSCSCAN_APIKEY=
```

### 1. Deploy contract , mint 1 NFT , and deposit in contract to swap for 1 NFT stable coin

```
truffle migrate --reset --network ethTestnet
truffle migrate --reset --network bscTestnet

```

### 2. Check token balance before transfer (the first one should be 1000 and the second one should be 0)

```
truffle exec scripts/eth-token-balance.js --network ethTestnet
truffle exec scripts/bsc-token-balance.js --network bscTestnet
```

### 3. Run the bridge script (keep the script opened in a separate terminal)

```
node scripts/eth-bsc-bridge.js
```

### 4. Transfer token (the bridge will listen to the event and do the bridging after transfer)

```
truffle exec scripts/eth-TransferTo-bsc.js --network ethTestnet
```

### 5. Check token balance after transfer

```
truffle exec scripts/eth-token-balance.js --network ethTestnet
truffle exec scripts/bsc-token-balance.js --network bscTestnet
```
