// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./TokenBase.sol";


interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


contract ERC721SafeHolderUpgradeable is IERC721ReceiverUpgradeable {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

// TokenEth is NFTStableCoin
contract TokenEth is TokenBase , ERC721SafeHolderUpgradeable {
    address assetAddress;
    uint256 constant base = 10**18;
    uint[] public AllTokenId;
    constructor() TokenBase("ETH Token", "ETK") {}  // The name of NFT stable coin

    function getAllTokenId() public view returns (uint[] memory) {
        return AllTokenId;
    }

    function isTokenIdInThisContract(uint tokenId) public view returns (bool){
        return (IERC721(assetAddress).ownerOf(tokenId) == address(this));
    }

    function setAssetAddress(address _assetAddress) external {
        require(msg.sender == admin, "only admin");
        assetAddress = _assetAddress;
    }

    function getAssetAddres() public view returns (address){
        return assetAddress;
    }

    function swapForNftStableCoin(address to , uint tokenId) public {
        require(assetAddress != address(0) , 'assetAddress not set');
        //ERC721 nft = ERC721(assetAddress);
        require(IERC721(assetAddress).getApproved(tokenId)==address(this) , 'NFT not approved');
        IERC721(assetAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        
        // 確認收到 NFT ，發行一枚NFT穩定幣給user
        AllTokenId.push(tokenId);
        _mint(to , base*1);

    }

    function redeemNftStableCoinToNft(address owner , uint tokenId) public{
        require(assetAddress != address(0) , 'assetAddress not set');
        //ERC721 nft = ERC721(assetAddress);
        IERC721(assetAddress).safeTransferFrom(address(this), msg.sender, tokenId);

        // 收到NFT穩定幣，將合約內的NFT轉給用戶完成贖回
        for (uint i=0; i<AllTokenId.length ; i++){
            if (AllTokenId[i] ==  tokenId){
                delete AllTokenId[i];
                break;
            }
        }
        _burn(owner , base*1);
    }

    function NFTflashloan(uint tokenId) external{
        require(isTokenIdInThisContract(tokenId), "Contract don't have this NFT.");
        IERC721(assetAddress).safeTransferFrom(address(this), msg.sender, tokenId);

        (bool success,) = msg.sender.call(
            abi.encodeWithSignature(
                "receiveFlashLoan(uint256)",
                tokenId
            )
        );
        require(success, "External call failed");

        require(isTokenIdInThisContract(tokenId), "Flash loan NFT not paid back");        
    }


}