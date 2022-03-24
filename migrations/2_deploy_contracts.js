const TokenEth = artifacts.require('TokenEth');
const TokenBsc = artifacts.require('TokenBsc.sol');
const BridgeEth = artifacts.require('BridgeEth.sol');
const BridgeBsc = artifacts.require('BridgeBsc.sol');
const MyNFT = artifacts.require('MyNFT.sol');

module.exports = async function (deployer, network, addresses) {
  if(network === 'ethTestnet' || network === 'development') {
    // myNFT 是自己發行的NFT
    await deployer.deploy(MyNFT);
    const myNFT = await MyNFT.deployed();
    await myNFT.mint(addresses[0] , 0);

    // TokenEth 是發行NFT穩定幣的合約
    await deployer.deploy(TokenEth);
    const tokenEth = await TokenEth.deployed();
    await tokenEth.setAssetAddress(myNFT.address);  //設定NFT穩定幣合約的AssetAddress
    await myNFT.approve(tokenEth.address , 0);   
    await tokenEth.swapForNftStableCoin(addresses[0] , 0); //將NFT存進合約內換取NFT穩定幣

    // BridgeEth 是跨鏈橋
    await deployer.deploy(BridgeEth, tokenEth.address);
    const bridgeEth = await BridgeEth.deployed();
    await tokenEth.updateAdmin(bridgeEth.address);

  }
  if(network === 'bscTestnet') {
    await deployer.deploy(TokenBsc);
    const tokenBsc = await TokenBsc.deployed();
    await deployer.deploy(BridgeBsc, tokenBsc.address);
    const bridgeBsc = await BridgeBsc.deployed();
    await tokenBsc.updateAdmin(bridgeBsc.address);
  }
};