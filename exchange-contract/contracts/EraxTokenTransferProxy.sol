// SPDX-License-Identifier: MIT
/*

  << Project Erax Token Transfer Proxy >.

*/

pragma solidity ^0.7.4;

import "./registry/TokenTransferProxy.sol";

contract EraxTokenTransferProxy is TokenTransferProxy {

    constructor (ProxyRegistry registryAddr)
        public
    {
        registry = registryAddr;
    }

}
