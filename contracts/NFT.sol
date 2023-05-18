// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ERC721Enumerable.sol";
import "./Ownable.sol";

/**
 * @title NFT
 * @dev Extends ERC721 Enumerable Non-Fungible Token Standard basic implementation
 */
contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public cost;
    uint256 public maxSupply;
    uint256 public allowMintingOn;
    uint256 public maxMintAmount;
    string public baseURI;
    string public baseExtension = '.json';
    bool public paused = false;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public addressMintedBalance;

    event Mint(uint256 amount, address minter);
    event Withdraw(uint256 amount, address owner);

    /**
     * @dev Sets the values for the name and symbol of the token, cost per mint, total supply,
     * allowed minting time, maximum mint amount per address, and base URI for the token metadata.
     */
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

     /**
     * @dev Mints `_mintAmount` tokens and assigns them to `msg.sender`.
     * Emits a {Mint} event.
     */
    function mint(uint256 _mintAmount) public payable {
        require(block.timestamp >= allowMintingOn, "Minting not allowed yet");
        require(whitelisted[msg.sender], "Address not whitelisted");
        require(_mintAmount > 0, "Must mint at least 1 token");
        require(addressMintedBalance[msg.sender] + _mintAmount <= maxMintAmount, "Cannot mint more than maxMintAmount");
        require(msg.value >= cost * _mintAmount, "Not enough payment");
        require(!paused, "Minting is paused");

        uint256 supply = totalSupply();
        require(supply + _mintAmount <= maxSupply, "Not enough tokens remaining");

        for(uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
            addressMintedBalance[msg.sender] += 1;
        }

        emit Mint(_mintAmount, msg.sender);
    }

    /**
     * @dev Returns an URI for a given token ID.
     * e.g. 'ipfs://QmQ2jnDYecFhrf3asEWjyjZRX1pZSsNWG3qHzmNDvXa9qg/1.json'
     * Throws if the token ID does not exist.
     *
     * See {ERC721-tokenURI}.
     */
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

    /**
     * @dev Returns all token ids owned by `_owner`.
     *
     * See {ERC721-balanceOf}.
     */
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for(uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Owner functions

    /**
     * @dev Allows the contract owner to withdraw the Ether stored in the contract.
     * Emits a {Withdraw} event.
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "Failed to withdraw Ether");

        emit Withdraw(balance, msg.sender);
    }

    /**
     * @dev Allows the contract owner to change the cost per mint.
     */
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    /**
     * @dev Allows the contract owner to pause or resume minting.
     */
    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    /**
     * @dev Allows the contract owner to whitelist an address, enabling it to mint tokens.
     */
    function whitelistUser(address _address) public onlyOwner {
        whitelisted[_address] = true;
    }
}
