// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public cost;
    uint256 public maxSupply;
    uint256 public allowMintingOn;
    uint256 public maxMintAmount;
    string public baseURI;
    string public baseExtension = '.json';
    bool public paused = false;

    mapping(address => uint256) public addressMintedBalance;

    event Mint(uint256 amount, address minter);
    event Withdraw(uint256 amount, address owner);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _cost,
        uint256 _maxSupply,
        uint256 _allowMintingOn,
        uint256 _maxMintAmount,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        cost = _cost;
        maxSupply = _maxSupply;
        allowMintingOn = _allowMintingOn;
        maxMintAmount = _maxMintAmount;
        baseURI = _baseURI;
    }

    function mint(uint256 _mintAmount) public payable {
        require(block.timestamp >= allowMintingOn, "Minting not allowed yet");
        require(_mintAmount > 0, "Must mint at least 1 token");
        require(addressMintedBalance[msg.sender] + _mintAmount <= maxMintAmount, "Cannot mint more than maxMintAmount");
        require(msg.value >= cost * _mintAmount, "Not enough payment");
        require(!paused, "Minting is paused");

        uint256 supply = totalSupply();
        require(supply + _mintAmount <= maxSupply, "Not enough tokens remaining");

        // Create tokens
        for(uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
            addressMintedBalance[msg.sender] += 1;
        }

        // Emit event
        emit Mint(_mintAmount, msg.sender);
    }

    // Return metadata IPFS url
    // e.g. 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/1.json'
    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(_tokenId), 'Token does not exist');
        return(string(abi.encodePacked(baseURI, _tokenId.toString(), baseExtension)));
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for(uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    // Owner functions

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Failed to withdraw Ether");

        emit Withdraw(balance, msg.sender);
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }
}
