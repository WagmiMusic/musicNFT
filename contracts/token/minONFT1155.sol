// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IONFT1155.sol";
import "../lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract minONFT1155 is NonblockingLzApp, ERC1155 {
    
    event SendToChain(address indexed _sender, uint16 indexed _dstChainId, bytes indexed _toAddress, uint _tokenId, uint _amount, uint64 _nonce);
    event ReceiveFromChain(uint16 _srcChainId, address _toAddress, uint _tokenId, uint _amount, uint64 _nonce);
    event ReceiveBatchFromChain(uint16 _srcChainId, address _toAddress, uint[] _tokenIds, uint[] _amounts, uint64 _nonce);

    constructor(
        string memory _uri, 
        address _lzEndpoint
    ) ERC1155(_uri) NonblockingLzApp(_lzEndpoint) {}
    
    function sendFrom(
        address _from, 
        uint16 _dstChainId, 
        bytes calldata _toAddress, 
        uint _tokenId, 
        uint _amount, 
        address payable _refundAddress, 
        address _zroPaymentAddress, 
        bytes calldata _adapterParam
        ) external payable virtual {
        require(msg.value >= 1 ether);
        _send(_from, _dstChainId, _toAddress, _tokenId, _amount, _refundAddress, _zroPaymentAddress, _adapterParam);
    }

    function _send(address _from, uint16 _dstChainId, bytes memory _toAddress, uint _tokenId, uint _amount, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParam) internal virtual {
        require(_msgSender() == _from || isApprovedForAll(_from, _msgSender()), "ERC1155: transfer caller is not owner nor approved");

        _beforeSend(_from, _dstChainId, _toAddress, _tokenId, _amount);

        uint[] memory tokenIds = new uint[](1);
        uint[] memory amounts = new uint[](1);
        tokenIds[0] = _tokenId;
        amounts[0] = _amount;
        bytes memory payload = abi.encode(_toAddress, tokenIds, amounts);

        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParam);

        uint64 nonce = lzEndpoint.getOutboundNonce(_dstChainId, address(this));
        emit SendToChain(_from, _dstChainId, _toAddress, _tokenId, _amount, nonce);
    }

    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual override {

        (bytes memory toAddress, uint[] memory tokenIds, uint[] memory amounts) = abi.decode(_payload, (bytes, uint[], uint[]));
        address localToAddress;
        assembly {
            localToAddress := mload(add(toAddress, 20))
        }

        if (localToAddress == address(0x0)) localToAddress == address(0xdEaD);

        if (tokenIds.length == 1) {
            _afterReceive(_srcChainId, localToAddress, tokenIds[0], amounts[0]);
            emit ReceiveFromChain(_srcChainId, localToAddress, tokenIds[0], amounts[0], _nonce);
        } else if (tokenIds.length > 1) {
            _afterReceiveBatch(_srcChainId, localToAddress, tokenIds, amounts);
            emit ReceiveBatchFromChain(_srcChainId, localToAddress, tokenIds, amounts, _nonce);
        }
    }
    
    function _beforeSend(
        address _from,
        uint16, /* _dstChainId */
        bytes memory, /* _toAddress */
        uint _tokenId,
        uint _amount
    ) internal virtual {
        _burn(_from, _tokenId, _amount);
    }

    function _afterReceive(
        uint16, /* _srcChainId */
        address _toAddress,
        uint _tokenId,
        uint _amount
    ) internal virtual {
        _mint(_toAddress, _tokenId, _amount, "0x");
    }

    function _afterReceiveBatch(
        uint16, /* _srcChainId */
        address _toAddress,
        uint[] memory _tokenIds,
        uint[] memory _amounts
    ) internal virtual {
        _mintBatch(_toAddress, _tokenIds, _amounts, "0x");
    }
}
