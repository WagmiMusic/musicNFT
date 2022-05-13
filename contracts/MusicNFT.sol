//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token/ONFT1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract ContextMixin {
    function msgSender()
        internal
        view
        returns (address payable sender)
    {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                // Load the 32 bytes word from memory with the address on the lower 20 bytes, and mask those.
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = payable(msg.sender);
        }
        return sender;
    }
}

contract MusicNFT is ONFT1155, ContextMixin {
    using SafeMath for uint256;
    address creator;
    string private _name;
    string private _symbol;
    uint public minMintId;
    uint public maxMintId;
    uint256 public totalSupply;
    bool private _whenAllReleased = false;
    bool private _nowOnSale = false;
    bool private _nowOnPresale = false;
    string private _uri = "ipfs://QmVvxpCLUjtKDVqYy1vtKdsd1TBiT6oJAPVYEJtUEoFCej/metadata/{id}.json";
    mapping(uint256 => uint256) private _supplyOfEach;
    mapping(uint256 => uint256) private _AMOUNT_OF_MAX_MINT;
    mapping(address => bool) private _isAuthenticated;
    mapping(address => bool) private _agent;
    constructor(
        string memory name_,
        string memory symbol_,
        address _lzEndpointAddress,
        uint _minMintId,
        uint _maxMintId
    ) ONFT1155(_uri, _lzEndpointAddress){
        _AMOUNT_OF_MAX_MINT[1] = 5;
        _AMOUNT_OF_MAX_MINT[2] = 5;
        _AMOUNT_OF_MAX_MINT[3] = 5;
        _AMOUNT_OF_MAX_MINT[4] = 55;
        _AMOUNT_OF_MAX_MINT[5] = 10;
        _AMOUNT_OF_MAX_MINT[6] = 10;
        _AMOUNT_OF_MAX_MINT[7] = 10;
        minMintId = _minMintId;
        maxMintId = _maxMintId;
        _name = name_;
        _symbol = symbol_;
        creator = msg.sender;
    }

    event SoldForGiveaway(address indexed _from,address indexed _to,uint256 _id,uint256 _amount);
    event SoldForPresale(address indexed _from,address indexed _to,uint256 _id,uint256 _amount);
    event SoldForPublicSale(address indexed _from,address indexed _to,uint256 _id,uint256 _amount);
    event NowOnSale(bool onsale);
    modifier onlyCreatorOrAgent(){
        require(creator == msg.sender||_agent[msg.sender],"This is not allowed except for creator or agent");
        _;
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
    function mint(address _to, uint256 _tokenId, uint256 _amount) public onlyCreatorOrAgent supplyCheck(_tokenId, _amount){
        require(_tokenId >= minMintId && _tokenId <= maxMintId, "tokenId is not allowed on this chain");
        _supplyOfEach[_tokenId] += _amount;
        totalSupply += _amount;
        _mint(_to, _tokenId, _amount, "");
    }
    function mintBatch(
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public onlyCreatorOrAgent supplyCheckBatch(_tokenIds, _amounts){
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(_tokenIds[i] >= minMintId && _tokenIds[i] <= maxMintId, "tokenId is not allowed on this chain");
            _supplyOfEach[_tokenIds[i]] += _amounts[i];
            totalSupply += _amounts[i];
        }
        _mintBatch(_to, _tokenIds, _amounts, "");
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
        if (from == address(0) || to == address(0) || from != creator) { return; }
        require(_nowOnSale, "Sale is suspended now");
        for (uint256 i = 0; i < ids.length; i++) {
            if(creator == msg.sender||_agent[msg.sender]){
                emit SoldForGiveaway(from, to, ids[i], amounts[i]);
            }else if (_nowOnPresale) {
                require(_isAuthenticated[to], "This address is not authenticated");
                if(ids[i] <= 3){
                    require(balanceOf(to, ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                }else{
                    require(balanceOf(to, ids[i]) + amounts[i] <= 2, "Can't buy same songs more than three record");
                }
                _isAuthenticated[to] = false;
                emit SoldForPresale(from, to, ids[i], amounts[i]);
            }else{
                if(ids[i] <= 3){
                    require(balanceOf(to, ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                }else{
                    require(balanceOf(to, ids[i]) + amounts[i] <= 2, "Can't buy same songs more than three record");
                }
                emit SoldForPublicSale(from, to, ids[i], amounts[i]);
            }
        }
    }
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public override view returns (bool isOperator) {
       if (_operator == address(0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101)) {
            return true;
        }
        return ERC1155.isApprovedForAll(_owner, _operator);
    }
    function addAllowlist(address[] memory allowAddr) public onlyCreatorOrAgent {
        for (uint256 i = 0; i < allowAddr.length; i++) {
             _isAuthenticated[allowAddr[i]] = true;
        }
    }
    function setLimitations() public onlyCreatorOrAgent {
        _whenAllReleased = false;
    }
    function releasedLimitations() public onlyCreatorOrAgent {
        _whenAllReleased = true;
    }
    function startSale() public onlyCreatorOrAgent {
        _nowOnSale = true;
        _nowOnPresale = true;
        emit NowOnSale(_nowOnSale);
    }
    function presaleFinished() public onlyCreatorOrAgent {
        _nowOnPresale = false;
        emit NowOnSale(_nowOnSale);
    }
    function suspendSale() public onlyCreatorOrAgent {
        _nowOnSale = false;
        emit NowOnSale(_nowOnSale);
    }
    function EMGreveal(
        string memory _EMGuri
    ) public onlyCreatorOrAgent {
        _setURI(_EMGuri);
    }
    function license(address agentAddr) public onlyCreatorOrAgent {
        _agent[agentAddr] = true;
    }
    function unlicense(address agentAddr) public onlyCreatorOrAgent {
        _agent[agentAddr] = false;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}