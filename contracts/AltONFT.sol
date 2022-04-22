// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// NOTE: this ONFT contract has no minting logic.
// must implement your own minting logic in child classes
contract AltONFT is NonblockingLzApp, ERC1155 {

    constructor(
        string memory _uri, 
        address _lzEndpoint
    ) ERC1155(_uri) NonblockingLzApp(_lzEndpoint) {}

    event SendToChain(address indexed _sender, uint16 indexed _dstChainId, bytes indexed _toAddress, uint _tokenId, uint64 _nonce);

    event ReceiveFromChain(uint16 _srcChainId, address _toAddress, uint _tokenId, uint64 _nonce);
    
    function sendFrom(
        address _from, 
        uint16 _dstChainId, 
        bytes calldata _toAddress, 
        uint _tokenId, 
        address payable _refundAddress, 
        address _zroPaymentAddress, 
        bytes calldata _adapterParam
        ) external payable virtual {
        _send(_from, _dstChainId, _toAddress, _tokenId, _refundAddress, _zroPaymentAddress, _adapterParam);
    }
    
    function send(
        uint16 _dstChainId, 
        bytes calldata _toAddress, 
        uint _tokenId, 
        address payable _refundAddress, 
        address _zroPaymentAddress, 
        bytes calldata _adapterParam
        ) external payable virtual {
        _send(_msgSender(), _dstChainId, _toAddress, _tokenId, _refundAddress, _zroPaymentAddress, _adapterParam);
    }

    function _send(
        address _from, 
        uint16 _dstChainId, 
        bytes memory _toAddress, 
        uint _tokenId, 
        address payable _refundAddress, 
        address _zroPaymentAddress, 
        bytes calldata _adapterParam
        ) internal virtual {
        require(
            _from == _msgSender() || isApprovedForAll(_from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _beforeSend(_from, _dstChainId, _toAddress, _tokenId);

        bytes memory payload = abi.encode(_toAddress, _tokenId);
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParam);

        uint64 nonce = lzEndpoint.getOutboundNonce(_dstChainId, address(this));
        emit SendToChain(_from, _dstChainId, _toAddress, _tokenId, nonce);
        _afterSend(_from, _dstChainId, _toAddress, _tokenId);
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId, 
        bytes memory _srcAddress, 
        uint64 _nonce, 
        bytes memory _payload) 
        internal virtual override 
        {
        _beforeReceive(_srcChainId, _srcAddress, _payload);

        // decode and load the toAddress
        (bytes memory toAddress, uint tokenId) = abi.decode(_payload, (bytes, uint));
        address localToAddress;
        assembly {
            localToAddress := mload(add(toAddress, 20))
        }

        // if the toAddress is 0x0, burn it or it will get cached
        if (localToAddress == address(0x0)) localToAddress == address(0xdEaD);

        _afterReceive(_srcChainId, localToAddress, tokenId);

        emit ReceiveFromChain(_srcChainId, localToAddress, tokenId, _nonce);
    }

    function _beforeSend(address /* _from */, uint16 /* _dstChainId */, bytes memory /* _toAddress */, uint _tokenId) internal virtual {
        _burn(_msgSender(), _tokenId, 1);
    }

    function _afterSend(address /* _from */, uint16 /* _dstChainId */, bytes memory /* _toAddress */, uint /* _tokenId */) internal virtual {}

    function _beforeReceive(uint16 /* _srcChainId */, bytes memory /* _srcAddress */, bytes memory /* _payload */) internal virtual {}

    function _afterReceive(uint16 /* _srcChainId */, address _toAddress, uint _tokenId) internal virtual {
        _mint(_toAddress, _tokenId, 1, "");
    }
}
