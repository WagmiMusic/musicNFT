//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract MusicNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenCounter;

    constructor() ERC721("MusicNFT","Music") {}
    function mint(string memory _tokenURI) public onlyOwner {
        _tokenCounter.increment();
        uint256 _newItemId = _tokenCounter.current();
        _safeMint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);
    }
    function transfer(address _to, uint256 _itemId) public onlyOwner {
        safeTransferFrom(msg.sender, _to, _itemId);
    }
}












