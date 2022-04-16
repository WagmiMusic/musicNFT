//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MusicNFT is ERC1155, Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;

    mapping(address => bool) private _isAuthenticated;

    constructor() ERC1155("ipfs://QmWYoz78X9B4s9cHwRv6UW11aBDFzmYa4oVWf1mUiNmAzp/metadata/{id}.json") {
        mint(1, 2);
    }

    function mint(uint256 _tokenId, uint256 amount) public onlyOwner {
        _mint(msg.sender, _tokenId, amount, "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override view {
        if (from == address(0)) { return; }
        require(_isAuthenticated[to], "This address is not authenticated");
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}
