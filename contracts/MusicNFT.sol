//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract MusicNFT is ERC1155, Ownable {
    using SafeMath for uint256;

    // コントラクトの作成者
    address creator;
    // コントラクト名
    string private _name;
    // NFT単位
    string private _symbol;
    // 総供給量
    uint256 public totalSupply;
    //全ての購入制限の可否
    bool private _whenAllReleased = false;
    //販売状態
    bool private _nowOnSale = false;
    //画像データ
    string private _uri = "ipfs://QmZUzZ88HX8USBkaGCowxVzasfi4StsEqs5TuxWYWciU7x/metadata/{id}.json";
    
    //@notice レアリティごとの供給量
    mapping(uint256 => uint256) private _supplyOfEach;
    //@notice レアリティごとの最大供給量
    mapping(uint256 => uint256) private _AMOUNT_OF_MAX_MINT;
    //@notice WhiteList用
    mapping(address => bool) private _isAuthenticated;
    //@notice 許可された代行者
    mapping(address => bool) private _agent;

    constructor() ERC1155("ipfs://QmZUzZ88HX8USBkaGCowxVzasfi4StsEqs5TuxWYWciU7x/metadata/{id}.json") {

        /*
        * ミント上限の設定
        * for giveaway(WL対象)
        */
        // Normal for domesticaly giveaway
        _AMOUNT_OF_MAX_MINT[1] = 10;
        // Normal for internationally giveaway
        _AMOUNT_OF_MAX_MINT[2] = 10;

        /*
        * ミント上限の設定
        * for Raffle(WL対象)
        */
        // Cool Rulers Collab male for WAGMI Raffle
        _AMOUNT_OF_MAX_MINT[3] = 1;
        // Cool Rulers Collab female for WAGMI Raffle
        _AMOUNT_OF_MAX_MINT[4] = 1;
        // Rimix for RTTT Raffle
        _AMOUNT_OF_MAX_MINT[5] = 1;

        /*
        * ミント上限の設定
        * for presale(WL対象)
        */
        // Normal for presale
        _AMOUNT_OF_MAX_MINT[6] = 20;
        // NTP Collab male for presale
        _AMOUNT_OF_MAX_MINT[7] = 3;
        // NTP Collab female for presale
        _AMOUNT_OF_MAX_MINT[8] = 3;
        // Cool Rulers Collab male for presale
        _AMOUNT_OF_MAX_MINT[9] = 2;
        // Cool Rulers Collab female for presale
        _AMOUNT_OF_MAX_MINT[10] = 2;
        // Acappella for presale
        _AMOUNT_OF_MAX_MINT[11] = 5;
        // Instrumental for presale
        _AMOUNT_OF_MAX_MINT[12] = 5;

        /*
        * ミント上限の設定
        * for public sale
        */
        // Normal for public sale
        _AMOUNT_OF_MAX_MINT[13] = 10;
        // NTP Collab male for public sale
        _AMOUNT_OF_MAX_MINT[14] = 2;
        // NTP Collab female for public sale
        _AMOUNT_OF_MAX_MINT[15] = 2;
        // Cool Rulers Collab male for public sale
        _AMOUNT_OF_MAX_MINT[16] = 2;
        // Cool Rulers Collab female for public sale
        _AMOUNT_OF_MAX_MINT[17] = 2;
        // Acappella for public sale
        _AMOUNT_OF_MAX_MINT[18] = 5;
        // Instrumental for public sale
        _AMOUNT_OF_MAX_MINT[19] = 5;
        // Remix for public sale
        _AMOUNT_OF_MAX_MINT[20] = 9;

        creator = _msgSender();
    }

    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    event URI(
        string _value
    );

    event SoldForGiveaway(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    )

    event SoldForPresale(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    )

    event SoldForPublicSale(
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    )

    event NowOnSale(
        bool _onsale
    )

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
        totalSupply += _amount;

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
            totalSupply += _amounts[i];
        }

        _mintBatch(_msgSender(), _tokenIds, _amounts, "");

        emit TransferBatch(_msgSender(), address(0), _msgSender(), _tokenIds, _amounts);
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

        if (from == address(0) || from != owner()) { return; }

        require(_nowOnSale, "Sale is suspended now");

        if(_nowOnSale && !_whenAllReleased){
            for (uint256 i = 0; i < ids.length; i++) {
                /*
                *レアリティごとの販売制限の指定(ToDo)
                */
                if (ids[i] <= 5){
                    require(creator == _msgSender()||_agent[_msgSender()],"This is not allowed except for creator or agent")
                    emit SoldForGiveaway(from, to, ids[i], amounts[i])
                }
                else if (ids[i] <= 12) {
                    require(_isAuthenticated[_msgSender()], "This address is not authenticated");
                    require(balanceOf(_msgSender(), ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                    emit SoldForPresale(from, to, ids[i], amounts[i])

                } else {
                    require(balanceOf(_msgSender(), ids[i]) + amounts[i] <= 1, "Can't buy same songs more than two record");
                    emit SoldForPublicSale(from, to, ids[i], amounts[i])
                }
            }
        }
    }

    /*
    * @title releasedLimitations
    * @notice 全ての購入制限の解除
    */
    function releasedLimitations() public onlyCreatorOrAgent {
        _whenAllReleased = true;
    }

    /*
    * @title releasedLimitations
    * @notice 販売開始
    */
    function startSale() public onlyCreatorOrAgent {
        _nowOnSale = true;
        emit NowOnSale(_nowOnSale)
    }

    /*
    * @title releasedLimitations
    * @notice 販売停止
    */
    function suspendSale() public onlyCreatorOrAgent {
        _nowOnSale = false;
        emit NowOnSale(_nowOnSale)
    }

    /*
    * @title reveal
    * @notice リビール用
    */
    function reveal() public onlyCreatorOrAgent {
        _setURI(_uri);
        emit URI(_uri);
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
        emit URI(_EMGuri);
    }

    /*
    * @title license
    * @notice 代行者の許可
    * @param agentAddr
    */
    function license(address agentAddr) public onlyCreatorOrAgent {
        agent[agentAddr] = true;
    }

    /*
    * @title license
    * @notice 代行者の削除
    * @param agentAddr
    */
    function unlicense(address agentAddr) public onlyCreatorOrAgent {
        agent[agentAddr] = false;
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