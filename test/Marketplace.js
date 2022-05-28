const Marketplace = artifacts.require("Market");
const Factory = artifacts.require("NFTFactory");
const NFTERC721 = artifacts.require("MonNft");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
contract('Marketplace', accounts => {
    const owner = accounts[0];
    const second = accounts[1];
    // let Marketplace;
    describe('showToken function + DeployMyNFTCollection function + getListing', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
        })
        it("...should set Creator to Owner in Listing struct", async () => {           
            const storedData = await MarketplaceInstance.getListing(1);                
            expect(storedData.Creator).to.equal(owner); 
        })
        it("...should set seller to Owner in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);   
            expect(storedData.seller).to.equal(owner); 
        })
        it("...should set tokenId to 1 in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);           
            expect(new BN(storedData.tokenId)).to.be.bignumber.equal(new BN(1)); 
        })
        it("...should set price to defaultprice in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);           
            expect(new BN(storedData.price)).to.be.bignumber.equal(new BN(1000000000000000000000n)); 
        })
        it("...should set collection to 'gg' in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);           
            expect(storedData.collection).to.equal("gg"); 
        })
        it("...should set JSONTokenURI to 'gg1.json' in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);           
            expect(storedData.JSONTokenURI).to.equal("gg1.json"); 
        })   
    })
    describe('listToken function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            await MarketplaceInstance.listToken(1, 1, {from:owner});
        })
        it("...should set price to 1 wei in Listing struct", async () => {           
            const storedData = await MarketplaceInstance.getListing(1);                
            expect(new BN(storedData.price)).to.be.bignumber.equal(new BN(1));
        })
        it("...should set status to Active in Listing struct", async () => {           
            const storedData = await MarketplaceInstance.getListing(1);                
            expect(new BN(storedData.status)).to.be.bignumber.equal(new BN(1)); 
        })   
    })
    describe('buyToken function when seller is creator + getListOfNFTfromUser function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            await MarketplaceInstance.listToken(1, 1, {from:owner});
            await MarketplaceInstance.buyToken(1, {from:second, value:1});
        })
        it("...should set status to Showable in Listing struct", async () => {           
            const storedData = await MarketplaceInstance.getListing(1);                
            expect(new BN(storedData.status)).to.be.bignumber.equal(new BN(0)); 
        })
        it("...should set seller to Second in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);   
            expect(storedData.seller).to.equal(second); 
        })
        it("...should set price to defaultprice in Listing struct", async () => {
            const storedData = await MarketplaceInstance.getListing(1);           
            expect(new BN(storedData.price)).to.be.bignumber.equal(new BN(1000000000000000000000n)); 
        })  
        it("...should set tokenId to 1 in MyBuyedNFT struct", async () => {
            const storedData = await MarketplaceInstance.getListOfNFTfromUser(second);           
            expect(new BN(storedData[0].tokenId)).to.be.bignumber.equal(new BN(1)); 
        }) 
        it("...should set collection to 'gg' in MyBuyedNFT struct", async () => {
            const storedData = await MarketplaceInstance.getListOfNFTfromUser(second);           
            expect(storedData[0].collection).to.equal("gg"); 
        }) 
        it("...should set myindex to 0 in MyBuyedNFT struct", async () => {
            const storedData = await MarketplaceInstance.getListOfNFTfromUser(second);           
            expect(new BN(storedData[0].myindex)).to.be.bignumber.equal(new BN(0)); 
        })  
    })
    //buyToken function when seller isn't creator
    describe('cancel function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            await MarketplaceInstance.listToken(1, 1, {from:owner});
            await MarketplaceInstance.cancel(1, {from:owner});
        })
        it("...should set status to Showable in Listing struct", async () => {           
            const storedData = await MarketplaceInstance.getListing(1);                
            expect(new BN(storedData.status)).to.be.bignumber.equal(new BN(0)); 
        })
    })
    describe('addItemToCollection function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            const storedData = await MarketplaceInstance.getListing(1); 
            await MarketplaceInstance.addItemToCollection(storedData.tokenContract, {from:owner});
        })
        it("...should set tokenId to 2 in Listing struct", async () => {           
            const storedData2 = await MarketplaceInstance.getListing(2);                
            expect(new BN(storedData2.tokenId)).to.be.bignumber.equal(new BN(2)); 
        })
    })
    describe('getUserCollections function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
        })
        it("...should tokenContract in Listing struct equal to getUserCollections at 0 address", async () => {   
            const storedData = await MarketplaceInstance.getListing(1);
            const collectionAddress = storedData.tokenContract;        
            const storedData2 = await MarketplaceInstance.getUserCollections(owner);                
            expect(storedData2[0]).to.equal(collectionAddress); 
        })
    })
    describe('getSellActivity function', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            await MarketplaceInstance.listToken(1, 1, {from:owner});
            await MarketplaceInstance.buyToken(1, {from:second, value:1});
        })
        it("...should set at index 0 the owner address", async () => {      
            const storedData = await MarketplaceInstance.getSellActivity(1);                
            expect(storedData[0]).to.equal(owner); 
        })
        it("...should set at index 1 the buyer address", async () => {      
            const storedData = await MarketplaceInstance.getSellActivity(1);                
            expect(storedData[1]).to.equal(second); 
        })
    })
    describe('require', () => {
        before(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            NFTERC721Instance = await NFTERC721.new("zz", "zz", "zz", MarketplaceInstance.address, {from:owner})
            await NFTERC721Instance.mint(owner, {from:owner});  
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 2, {from:owner});
            await MarketplaceInstance.listToken(1, 1, {from:owner});   
        })
        it("...showToken revert", async () => {             
            expectRevert(MarketplaceInstance.showToken(NFTERC721Instance.address, 1, {from:second}), "Caller is not the token owner")
        })
        it("...listToken revert not exist", async () => {             
            expectRevert(MarketplaceInstance.listToken(3, 1, {from:owner}), "Insert a valid listingId")
        })
        it("...listToken revert not owner", async () => {             
            expectRevert(MarketplaceInstance.listToken(1, 1, {from:second}), "You are not the owner")
        })
        it("...listToken revert cannot be listed twice a the same time", async () => {     
            expectRevert(MarketplaceInstance.listToken(1, 1, {from:owner}), "The NFT is already to sale")
        })
        it("...buyToken revert can only buy listed to sale NFT", async () => {     
            expectRevert(MarketplaceInstance.buyToken(2, {from:second, value:1}), "Listing is not active")
        })
        it("...buyToken revert cannot buy your own token", async () => {     
            expectRevert(MarketplaceInstance.buyToken(1, {from:owner, value:1}), "seller cannot be buyer")
        })
        it("...buyToken revert not good amount", async () => {     
            expectRevert(MarketplaceInstance.buyToken(1, {from:second, value:0}), "Insuficient amount")
        }).address
        it("...cancel revert not owner", async () => {     
            expectRevert(MarketplaceInstance.cancel(1, {from:second}), "Only seller can cancel listing")
        })
        it("...cancel revert not listed to sale", async () => {     
            expectRevert(MarketplaceInstance.cancel(2, {from:owner}), "Listing is not active")
        })
    })
    describe('Event triggering', () => {
        beforeEach(async function() {
            MarketplaceInstance = await Marketplace.new({from:owner});
            FactoryInstance = await Factory.new({from:owner});
            NFTERC721Instance = await NFTERC721.new("zz", "zz", "zz", MarketplaceInstance.address, {from:owner});
            await NFTERC721Instance.mint(owner, {from:owner});
            await MarketplaceInstance.setFactoryAddress(FactoryInstance.address);
            // await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 2, {from:owner});
            // await MarketplaceInstance.listToken(1, 1, {from:owner});   
        })
        it('get event Showed', async () => {
            const findEvent = await MarketplaceInstance.showToken(NFTERC721Instance.address, 1, {from:owner});
            expectEvent(findEvent,"Showed",{status: new BN(0), listingId: new BN(1), Creator: owner, seller: owner, token: NFTERC721Instance.address, tokenId: new BN(1), collection: "zz", JSONTokenURI: "zz1.json"});
        })
        it('get event Listed', async () => {
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            const storedData = await MarketplaceInstance.getListing(1);
            const _token = storedData.tokenContract;
            const _Creator = storedData.Creator;
            const _seller = storedData.seller;
            const _collection = storedData.collection;
            const _JSONTokenURI = storedData.JSONTokenURI;
            const findEvent = await MarketplaceInstance.listToken(1, 1, {from:owner});
            expectEvent(findEvent,"Listed",{status: new BN(1), listingId: new BN(1), Creator: _Creator, seller: _seller, token: _token, tokenId: new BN(1), price: new BN(1), collection: _collection, JSONTokenURI: _JSONTokenURI});
        })
        it('get event Buyed', async () => {
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            const storedData = await MarketplaceInstance.getListing(1);
            const _token = storedData.tokenContract;
            const _Creator = storedData.Creator;
            const _collection = storedData.collection;
            const _JSONTokenURI = storedData.JSONTokenURI;
            await MarketplaceInstance.listToken(1, 1, {from:owner});
            const findEvent = MarketplaceInstance.buyToken(1, {from:second, value: 1});
            expectEvent(findEvent,"Buyed",{status: new BN(0), listingId: new BN(1), Creator: _Creator, seller: second, token: _token, tokenId: new BN(1), collection: _collection, JSONTokenURI: _JSONTokenURI});
        })
        it('get event Canceled', async () => {
            await MarketplaceInstance.DeployMyNFTCollection("gg", "gg", "gg", 1, {from:owner});
            const storedData = await MarketplaceInstance.getListing(1);
            const _token = storedData.tokenContract;
            const _Creator = storedData.Creator;
            const _collection = storedData.collection;
            const _JSONTokenURI = storedData.JSONTokenURI;
            await MarketplaceInstance.listToken(1, 1, {from:owner});
            const findEvent = MarketplaceInstance.cancel(1, {from:owner});
            expectEvent(findEvent,"Cancelled",{status: new BN(0), listingId: new BN(1), Creator: _Creator, seller: owner, token: _token, tokenId: new BN(1), collection: _collection, JSONTokenURI: _JSONTokenURI});
        })
    })
})