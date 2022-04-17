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
    uint256 public totalSupply;
    
    //レアリティごとの供給量
    mapping(uint256 => uint256) private _supplyOfEach;
    //レアリティごとの最大供給量
    mapping(uint256 => uint256) private _AMOUNT_OF_MAX_MINT;
    //WhiteList用
    mapping(address => bool) private _isAuthenticated;

    constructor() ERC1155("ipfs://QmZUzZ88HX8USBkaGCowxVzasfi4StsEqs5TuxWYWciU7x/metadata/{id}.json") {
        // Normal A
        _AMOUNT_OF_MAX_MINT[1] = 10;
        // Normal B
        _AMOUNT_OF_MAX_MINT[2] = 10;
        // Normal C
        _AMOUNT_OF_MAX_MINT[3] = 20;
        // Normal D
        _AMOUNT_OF_MAX_MINT[4] = 20;
        // NTP Collab A
        _AMOUNT_OF_MAX_MINT[5] = 1;
        // NTP Collab B
        _AMOUNT_OF_MAX_MINT[6] = 4;
        // NTP Collab C
        _AMOUNT_OF_MAX_MINT[7] = 1;
        // NTP Collab D
        _AMOUNT_OF_MAX_MINT[8] = 4;
        // Cool Rulers Collab A
        _AMOUNT_OF_MAX_MINT[9] = 1;
        // Cool Rulers Collab B
        _AMOUNT_OF_MAX_MINT[10] = 2;
        // Cool Rulers Collab C
        _AMOUNT_OF_MAX_MINT[11] = 2;
        // Cool Rulers Collab D
        _AMOUNT_OF_MAX_MINT[12] = 1;
        // Cool Rulers Collab E
        _AMOUNT_OF_MAX_MINT[13] = 2;
        // Cool Rulers Collab F
        _AMOUNT_OF_MAX_MINT[14] = 2;
        // Acappella A
        _AMOUNT_OF_MAX_MINT[15] = 5;
        // Acappella B
        _AMOUNT_OF_MAX_MINT[16] = 5;
        // Instrumental A
        _AMOUNT_OF_MAX_MINT[17] = 5;
        // Instrumental A
        _AMOUNT_OF_MAX_MINT[18] = 5;
    }

    modifier supplyCheck(
        uint256 _tokenId,
        uint256 _amount
    ){
        require(_supplyOfEach[_tokenId] + _amount <= _AMOUNT_OF_MAX_MINT[_tokenId], "Max supply reached");
        _;
    }

    modifier supplyCheckBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ){
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(_supplyOfEach[_tokenIds[i]] + _amounts[i] <= _AMOUNT_OF_MAX_MINT[_tokenIds[i]], "Max supply reached");
        }
        _;
    }

    function mint(uint256 _tokenId, uint256 _amount) public onlyOwner supplyCheck(_tokenId, _amount){
        _supplyOfEach[_tokenId] += _amount;
        totalSupply += _amount;

        _mint(_msgSender(), _tokenId, _amount, "");
    }
    
    function mintBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public onlyOwner supplyCheckBatch(_tokenIds, _amounts){
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _supplyOfEach[_tokenIds[i]] += _amounts[i];
            totalSupply += _amounts[i];
        }

        _mintBatch(_msgSender(), _tokenIds, _amounts, "");
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) { return; }
        require(_isAuthenticated[to], "This address is not authenticated");
        require(balanceOf(_msgSender(), ids[0]) <= 1, "Can't buy same songs more than two record");
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}
