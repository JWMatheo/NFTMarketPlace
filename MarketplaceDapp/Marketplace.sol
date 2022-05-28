// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./NFTFactory.sol";
import "./NFTERC721.sol";

/// @title A NFT marketplace example
/// @author JWMatheo - member of NFTSet Team
/// @notice You can use this contract in order to build a marketplace Dapp
/// @dev NFT marketplace contract. You need to deploy FactoryV3.sol first and implement the Factory address.
contract Market {
    enum ListingStatus {Showable, Active}

    struct Listing {
        ListingStatus status;
        address Creator;
        address seller;
        address tokenContract;
        uint tokenId;
        uint price;
        string collection;
        string JSONTokenURI;
    }
    struct MyBuyedNFT {
        address tokenContract;
        uint tokenId;
        string collection;
        string JSONTokenURI;
        uint myindex;
    }
 
    event  Showed(
        ListingStatus status,
        uint listingId,
        address Creator,
        address seller,
        address token,
        uint tokenId,
        string collection,
        string JSONTokenURI
    );

    event  Listed(
        ListingStatus status,
        uint listingId,
        address Creator,
        address seller,
        address token,
        uint tokenId,
        uint price,
        string collection,
        string JSONTokenURI
    );

    event Buyed(
        ListingStatus status,
        uint listingId,
        address Creator,
        address seller,
        address token,
        uint tokenId,
        string collection,
        string JSONTokenURI
    );

    event Cancelled(
        ListingStatus status,
        uint listingId,
        address Creator,
        address seller,
        address token,
        uint tokenId,
        string collection,
        string JSONTokenURI
    );
    
    uint private _buyedTokenCounter;
    bool _forApproved = true;
    uint private _listingId = 0;
    uint private _defaultPrice = 1000 ether;
    address private _factoryAddress;
    mapping(uint=>Listing) _listings;
    mapping(address =>address[]) CollectionsOfOwner;
    mapping(uint=>address[]) SellActivty;
    mapping (address=>MyBuyedNFT[]) ListOfNFTfromUser;

    function setFactoryAddress(address factoryAdress) public {
        _factoryAddress = factoryAdress;
    }

    /**
    * @notice Get the structure for a listed NFT.
    * @dev  Get the structure from mapping a listed NFT Id.
    * @param listingId The listed NFT Id to check.
    * @return Listing structure of the entered listed NFT Id.
    */
    function getListing(uint listingId) public view returns(Listing memory){
        return _listings[listingId];
    }

    /**
    * @notice Get all collection address created of an address.
    * @dev  Get an array wich contains all collection address created for a given address.
    * @param _yourAddress The address to check.
    * @return address[] The array which contains all colection address.
    */
    function getUserCollections(address _yourAddress) public view returns(address[] memory) {
        return CollectionsOfOwner[_yourAddress];
    }

    /**
    * @notice Get sells activities from a NFT.
    * @dev  Get an array wich contains all addresses having been in possession of the listed nft.
    * @param listingId The listed NFT Id to check.
    * @return address[] The array which contains all addresses having been in possession of the listed nft.
    */
    function getSellActivity(uint listingId) public view returns(address[] memory){
        Listing memory listing = _listings[listingId];
        return SellActivty[listing.tokenId];
    }

    /**
    * @notice Get all the NFT purchased and currently owned.
    * @dev  Get an array wich contains a structure for each NFT purchased && currently owned.
    * @param _youraddress The address to check.
    * @return MyBuyedNFT[] The array wich contains a structure for each NFT purchased && currently owned.
    */
    function getListOfNFTfromUser(address _youraddress) public view returns(MyBuyedNFT[] memory) {
        return ListOfNFTfromUser[_youraddress];
    }

    /**
    * @dev Verify that the listedId '_thelistingId' exist.
    *
    * Requirements:
    *
    * - Insert an existing listed NFT Id '_thelistingId'
    */
    modifier isListingExist(uint _thelistingId) {
        require(_listings[_thelistingId].tokenContract != address(0), "Insert a valid listingId");
        _;
    }

    /**
    * @notice Make your NFT appear in the marketplace.
    * @dev Create a 'Listing' structure to make your NFT appear in the marketplace.
    * '_defaultPrice' in 'Listing' is set to prevent a potentially vulnerability attack.
    *
    * Requirements:
    *
    * - 'msg.sender' is the owner of the tokenId '_tokenId' at address '_tokenContract'
    *
    * Emits a {Showed} event. 
    */
    function showToken(address _tokenContract, uint _tokenId) public {
        require(ERC721(_tokenContract).ownerOf((_tokenId)) == msg.sender, "Caller is not the token owner");
        string memory _collectionName = ERC721(_tokenContract).name();
        string memory _JSONTokenURI = MonNft(_tokenContract).tokenURI(_tokenId);
        Listing memory listing = Listing(
            ListingStatus.Showable,
            msg.sender,
            msg.sender,
            _tokenContract,
            _tokenId,   
            _defaultPrice,
            _collectionName,
            _JSONTokenURI
        );

        _listingId++;
        _listings[_listingId] = listing;
        emit Showed(listing.status ,_listingId, msg.sender, msg.sender, _tokenContract, _tokenId, _collectionName, _JSONTokenURI); 
    }

    /**
    * @notice List to sale your NFT in the marketplace.
    * @dev Set a price and status to make the NFT buyable then transfer the NFT to the marketplace.
    *
    * Requirements:
    *
    * - 'msg.sender' is the owner of the tokenId 'listing.tokenId' at address 'listing.tokenContract'
    * - The Nft is not already listed to sale
    *
    * Emits a {Listed} event. 
    */
    function listToken(uint listingId, uint _price) external isListingExist(listingId) {
        
        Listing storage listing = _listings[listingId];
        address testadress = address(this);
        require(ERC721(listing.tokenContract).ownerOf((listing.tokenId)) == msg.sender, "You are not the owner");
        require(listing.status == ListingStatus.Showable, "The NFT is already to sale");

        listing.price = _price;
        listing.status = ListingStatus.Active;
        MonNft(listing.tokenContract).setAddressToMsgSenderOfListTokenFromMarketPlaceContract(msg.sender);
        ERC721(listing.tokenContract).setApprovalForAll(testadress, _forApproved);
        IERC721(listing.tokenContract).transferFrom(msg.sender, testadress, listing.tokenId);   

        emit Listed(listing.status, _listingId, listing.Creator, msg.sender, listing.tokenContract, listing.tokenId, listing.price, listing.collection, listing.JSONTokenURI);   
    }

    /**
    * @notice Buy a Nft.
    * @dev Buy NFT function. Transfer the NFT to the msg.sender.
    *
    * Requirements:
    *
    * - The Nft is listed to sale,
    * - Cannot buy your own NFT.
    * - Send the good amount.
    *
    * Emits a {Buyed} event. 
    */
    function buyToken(uint listingId) external payable isListingExist(listingId) {
        Listing storage listing = _listings[listingId];
        uint lengthOfListOfNFTfromUser = ListOfNFTfromUser[listing.seller].length;
        require(listing.status == ListingStatus.Active, "Listing is not active");
        require(msg.sender != listing.seller, "seller cannot be buyer");
        require(msg.value == listing.price, "Insuficient amount");
        /**
        * @dev If Creator is the seller it doesn't delete 'MyBuyedNFT' structure beacause it doesn't exist.
        */
        if (listing.seller != listing.Creator) {
            uint indexOfDeletedNFT;
            for (uint256 i = 0; i < lengthOfListOfNFTfromUser; i++) {
                if (listing.tokenContract == ListOfNFTfromUser[listing.seller][i].tokenContract && listing.tokenId == ListOfNFTfromUser[listing.seller][i].tokenId) {
                    indexOfDeletedNFT = i; 
                    break;            
                }
            }
            delete ListOfNFTfromUser[listing.seller][indexOfDeletedNFT];
        }
        
        payable(listing.seller).transfer(listing.price);
        IERC721(listing.tokenContract).transferFrom(address(this), msg.sender, listing.tokenId);
        

        listing.status = ListingStatus.Showable;
        listing.seller = msg.sender;
        listing.price = _defaultPrice;
        SellActivty[listing.tokenId].push(msg.sender);
        ListOfNFTfromUser[msg.sender].push(MyBuyedNFT(
            listing.tokenContract,
            listing.tokenId,
            listing.collection,
            listing.JSONTokenURI,
            lengthOfListOfNFTfromUser
        ));

        emit Buyed(listing.status, listingId, listing.Creator, listing.seller, listing.tokenContract, listing.tokenId, listing.collection, listing.JSONTokenURI);
    }

    /**
    * @notice Cancel a listed to sale NFT.
    * @dev Cancel a listed to sale NFT. Transfer back the NFT from Marketplace to the msg.sender.
    *
    * Requirements:
    *
    * - Only seller can cancel listing,
    * - The NFT is listed to sale.
    *
    * Emits a {Cancelled} event. 
    */
    function cancel(uint listingId) public payable isListingExist(listingId) {
        Listing storage listing = _listings[listingId];

        require(msg.sender == listing.seller, "Only seller can cancel listing");
        require(listing.status == ListingStatus.Active, "Listing is not active");

        listing.status = ListingStatus.Showable;

        IERC721(listing.tokenContract).transferFrom(address(this), msg.sender, listing.tokenId);

        emit Cancelled(listing.status ,listingId, listing.Creator, msg.sender, listing.tokenContract, listing.tokenId, listing.collection, listing.JSONTokenURI);
    }

    /**
    * @notice Deploy a NFT collection.
    * @dev Deploy a NFT collection . Can be impove by letting user set his own _salt.
    *
    *
    * Emits a {Showed} event. 
    */
    function DeployMyNFTCollection(
        string calldata _Collectionname,
        string calldata _Collectionsymbol,
        string calldata _CollectionBaseUri,
        uint _NumberOfNftToMint) public payable {
        uint _salt = 8;
        address ownerOfNFTContratIs = msg.sender;
        address _addressCollection = NFTFactory(_factoryAddress).DeployYourNFT(_salt, _Collectionname, _Collectionsymbol, _CollectionBaseUri);
        CollectionsOfOwner[msg.sender].push(_addressCollection);
        for (uint256 i = 0; i < _NumberOfNftToMint ; i++) {
            uint _tokenId = MonNft(_addressCollection).mint(ownerOfNFTContratIs);
            showToken(_addressCollection, _tokenId);
            SellActivty[_tokenId].push(msg.sender);
        }
    }

    /**
    * @notice Add a NFT to an existing collection.
    * @dev  Triggers 'mint' function in the collection address '_thisCollection'. Can be improved with 'for' to set a number of item to add.
    * @param _thisCollection The collection address in wich the nft is added.
    */
    function addItemToCollection(address _thisCollection) public {
        uint _tokenId = MonNft(_thisCollection).mint(msg.sender);
        showToken(_thisCollection, _tokenId);
    }   
}