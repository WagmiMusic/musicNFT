//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./minONFT1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract minMusicNFT is minONFT1155 {
    using SafeMath for uint256;

    // コントラクトの作成者
    address creator;
    // コントラクト名
    string private _name;
    // NFT単位
    string private _symbol;
    // チェーンごとのIDの範囲
    uint public minMintId;
    uint public maxMintId;
    // デフォルトのオムニセンド先チェーン
    uint16 private defaultDstChainId;
    // 全ての購入制限の可否
    bool private _whenAllReleased = false;
    // 販売状態
    bool private _nowOnSale = false;
    // プレセール状態
    bool private _nowOnPresale = false;
    // 画像データ
    string private _uri = "ipfs://QmZUzZ88HX8USBkaGCowxVzasfi4StsEqs5TuxWYWciU7x/metadata/{id}.json";
    
    //@notice レアリティごとの供給量
    mapping(uint256 => uint256) private _supplyOfEach;
    //@notice レアリティごとの最大供給量
    mapping(uint256 => uint256) private _AMOUNT_OF_MAX_MINT;
    //@notice WhiteList用
    mapping(address => bool) private _isAuthenticated;
    //@notice 許可された代行者
    mapping(address => bool) private _agent;

    constructor(
        string memory name_,
        string memory symbol_,
        address _lzEndpoint,
        uint _minMintId,
        uint _maxMintId,
        uint16 _defaultDstChainId
    ) minONFT1155(_uri, _lzEndpoint){
// Etherium(rinkeby)

        //fot giveaway/Raffle
        // NTP Collab female
        _AMOUNT_OF_MAX_MINT[1] = 1;

        // for presale
        // NTP Collab male
        _AMOUNT_OF_MAX_MINT[2] = 3;
        // NTP Collab female
        _AMOUNT_OF_MAX_MINT[3] = 2;

        // for public sale
        // NTP Colab male
        _AMOUNT_OF_MAX_MINT[4] = 2;
        // NTP Colab female
        _AMOUNT_OF_MAX_MINT[5] = 2;

        minMintId = _minMintId;
        maxMintId = _maxMintId;

        _name = name_;
        _symbol = symbol_;

        creator = _msgSender();
        defaultDstChainId = _defaultDstChainId;
    }

    event SoldForGiveaway(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );

    event SoldForPresale(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );

    event SoldForPublicSale(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );

    event NowOnSale(
        bool onsale
    );

    /*
    * @notice 執行者を認証する(コントラクトの作成者と許可された代行者のみ)
    */
    modifier onlyCreatorOrAgent(){
        require(creator == _msgSender()||_agent[_msgSender()],"This is not allowed except for creator or agent");
        _;
    }

    /*
    * @notice 最大Mint数の制限
    * @param _tokenIds ミントするレアリティのID
    * @param _amounts ミントする数
    */
    modifier supplyCheck(
        uint256 _tokenId,
        uint256 _amount
    ){
        require(_tokenId >= minMintId && _tokenId <= maxMintId, "tokenId is not allowed on this chain");
        require(_supplyOfEach[_tokenId] + _amount <= _AMOUNT_OF_MAX_MINT[_tokenId], "Max supply reached");
        _;
    }

    /*
    * @notice 最大Mint数の制限(複数Mint用)
    * @param _tokenIds ミントするレアリティのID
    * @param _amounts ミントする数
    */
    modifier supplyCheckBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ){
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(_tokenIds[i] >= minMintId && _tokenIds[i] <= maxMintId, "tokenId is not allowed on this chain");
            require(_supplyOfEach[_tokenIds[i]] + _amounts[i] <= _AMOUNT_OF_MAX_MINT[_tokenIds[i]], "Max supply reached");
        }
        _;
    }

    /*
    * @title mint
    * @notice ミント
    * @param _tokenId ミントするレアリティのID
    * @param _amount ミントする数
    */
    function mint(uint256 _tokenId, uint256 _amount) public onlyCreatorOrAgent supplyCheck(_tokenId, _amount){
        _supplyOfEach[_tokenId] += _amount;
        _mint(_msgSender(), _tokenId, _amount, "");

        emit TransferSingle(_msgSender(), address(0), _msgSender(), _tokenId, _amount);
    }
    
    /*
    * @title mintBatch
    * @notice 複数レアリティのミント
    * @param _tokenIds ミントするレアリティのID
    * @param _amounts ミントする数
    */
    function mintBatch(
        uint256[] memory _tokenIds,
        uint256[] memory _amounts
    ) public onlyCreatorOrAgent supplyCheckBatch(_tokenIds, _amounts){
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _supplyOfEach[_tokenIds[i]] += _amounts[i];
        }

        _mintBatch(_msgSender(), _tokenIds, _amounts, "");

        emit TransferBatch(_msgSender(), address(0), _msgSender(), _tokenIds, _amounts);
    }

    /*
    * @title simpleSend
    * @notice 簡易的なオムニセンド（直コン用）
    */
    function simpleSend(
        uint _tokenId,
        uint _amount,
        bytes calldata _toAddress,
        bytes calldata _adapterParam
    ) public payable {
        _send(_msgSender(), defaultDstChainId, _toAddress, _tokenId, _amount, payable(_msgSender()), address(0x0), _adapterParam);
    }

    /*
    * @title _beforeTokenTransfer
    * @notice transferに連動する購入制限
    * @param operator 実行者アドレス
    * @param from 移転元アドレス
    * @param to 移転先アドレス
    * @param ids 移転するレアリティのID
    * @param amounts 移転する数
    * @param data オプションパラメータ
    * @dev ConsumerApiからprofileを取得して格納
    */
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

        /*
        * 一次流通&トランスファー時&販売状態&購入制限状態
        * にのみ実行
        */
        if(_nowOnSale && !_whenAllReleased){
            for (uint256 i = 0; i < ids.length; i++) {
                /*
                * for giveaway/Raffle
                * @require 執行者の限定
                */
                if (ids[i] == 1) {
                    require(creator == _msgSender()||_agent[_msgSender()],"This is not allowed except for creator or agent");
                    emit SoldForGiveaway(from, to, ids[i], amounts[i]);
                }
                /*
                * for presale
                * @require 購入上限枚数
                * @require Allowlist判定
                */
                if (ids[i] <= 3){
                    require(balanceOf(to, ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                    if(_nowOnPresale){
                        require(_isAuthenticated[to], "This address is not authenticated");
                        emit SoldForPresale(from, to, ids[i], amounts[i]);
                    } else {
                        emit SoldForPublicSale(from, to, ids[i], amounts[i]);
                    }
                }
                /*
                * for public sale
                * @require 購入上限枚数
                */
                else {
                    require(balanceOf(to, ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                    emit SoldForPublicSale(from, to, ids[i], amounts[i]);
                } 
            }
        }
    }

    /*
    * @title addAllowlist
    * @notice AllowListへの追加
    */
    function addAllowlist(address allowAddr) public onlyCreatorOrAgent {
        _isAuthenticated[allowAddr] = true;
    }

    /*
    * @title releasedLimitations
    * @notice 全ての購入制限の実行
    */
    function setLimitations() public onlyCreatorOrAgent {
        _whenAllReleased = false;
    }

    /*
    * @title releasedLimitations
    * @notice 全ての購入制限の解除
    */
    function releasedLimitations() public onlyCreatorOrAgent {
        _whenAllReleased = true;
    }

    /*
    * @title startSale
    * @notice 販売開始
    */
    function startSale() public onlyCreatorOrAgent {
        _nowOnSale = true;
        _nowOnPresale = true;
        emit NowOnSale(_nowOnSale);
    }

    /*
    * @title presaleFinished
    * @notice プレセール終了
    */
    function presaleFinished() public onlyCreatorOrAgent {
        _nowOnPresale = false;
        emit NowOnSale(_nowOnSale);
    }

    /*
    * @title releasedLimitations
    * @notice 販売停止
    */
    function suspendSale() public onlyCreatorOrAgent {
        _nowOnSale = false;
        emit NowOnSale(_nowOnSale);
    }

    /*
    * @title reveal
    * @notice リビール用
    */
    function reveal() public onlyCreatorOrAgent {
        _setURI(_uri);
    }

    /*
    * @title EMGreveal
    * @notice 緊急リビール用
    * @param _EMGuri 緊急用uri
    * @dev 画像データに対する信頼性の点から，要検討
    */
    function EMGreveal(
        string memory _EMGuri
    ) public onlyCreatorOrAgent {
        _setURI(_EMGuri);
    }

    /*
    * @title license
    * @notice 代行者の許可
    * @param agentAddr
    */
    function license(address agentAddr) public onlyCreatorOrAgent {
        _agent[agentAddr] = true;
    }

    /*
    * @title license
    * @notice 代行者の削除
    * @param agentAddr
    */
    function unlicense(address agentAddr) public onlyCreatorOrAgent {
        _agent[agentAddr] = false;
    }

    /*
    * @title name
    * @notice コントラクト名の呼び出し
    * @return _name コントラクト名
    * @dev OpenSeaに表示するための技術要件
    */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /*
    * @title symbol
    * @notice NFT単位の呼び出し
    * @return _symbol NFT単位
    * @dev OpenSeaに表示するための技術要件
    */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
}