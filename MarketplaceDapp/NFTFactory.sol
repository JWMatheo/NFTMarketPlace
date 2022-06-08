// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./NFTERC721.sol";
/// @title A NFT Factory example
/// @author JWMatheo
/// @notice You can use this contract in order to create other contract !
/// @dev Create new contract 'MonNFT' instance
contract NFTFactory {
    event Deploy(address _address);
    /**
    * @notice Deploy your NFT Collection.
    * @dev Deploy a new NFT contract and return his address.
    *
    * Emits a {Deploy} event. 
    */
    function DeployYourNFT(uint _salt,
        string calldata _Collectionname,
        string calldata _Collectionsymbol,
        string calldata _CollectionBaseUri)
        external returns(address){
        MonNft _contract = new MonNft{
            salt: bytes32(_salt)
        }(_Collectionname, _Collectionsymbol, _CollectionBaseUri);
        emit Deploy(address(_contract));
        return address(_contract);      
    }
}
