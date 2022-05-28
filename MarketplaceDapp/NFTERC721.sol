// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/ERC721.sol)

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title A NFT contract example
/// @author JWMatheo - member of NFTSet Team
/// @notice You can use this contract in order to create your NFT collection !
/// @dev ERC721 basic contract
contract MonNft is ERC721Enumerable {
    using Strings for uint256;
    event CreatedURI(string _realisedURI, uint _tokenId);
    string public extension = ".json";
    string _baseCollectionURI;
    address MsgSenderAddress;
    address NFTcreators;


    using Counters for Counters.Counter; 
 
    Counters.Counter private _tokenId;

    constructor (string memory _Collectionname,
                 string memory _Collectionsymbol,
                 string memory _CollectionBaseUri) ERC721(_Collectionname,_Collectionsymbol){

        _baseCollectionURI = _CollectionBaseUri;
    }
    /**
    * @dev set the msg.sender. Use it if you call from a NFT Factory using a Marketplace
    */
function setAddressToMsgSenderOfListTokenFromMarketPlaceContract(address _MsgSenderAddress) public {
    MsgSenderAddress = _MsgSenderAddress;
}

    /**
    * @dev see @openzeppelin ERC721 documentation
    */
function setApprovalForAll(address operator, bool approved) public virtual override(ERC721, IERC721) {
        _setApprovalForAll(MsgSenderAddress, operator, approved);
    }
    /**
    * @dev see @openzeppelin ERC721 documentation
    */
function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        require(_isApprovedOrOwner(from, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }
    /**
    * @dev Create NFT by minting.
    * return the id 'id' of the NFT you just mint. 
    */
function mint(address ownerOfNFTContratIs) public returns(uint){
    _tokenId.increment();     
    uint256 id = _tokenId.current();
    NFTcreators = ownerOfNFTContratIs;
    _mint(ownerOfNFTContratIs, id);
    return (id);
}
    /**
    * @dev return the tokenURI of a NFT
    *
    * Requirements:
    *
    * - Cannot get the URI of unexistent tokenID.
    */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return (bytes(_baseCollectionURI).length > 0 ? string(abi.encodePacked(_baseCollectionURI, tokenId.toString(), extension)) : "");
    }
}