// SPDX-License-Identifier: MIT
/*

  EraxOwnableDelegateProxy

*/

pragma solidity ^0.7.4;

import "./ProxyRegistry.sol";
import "./AuthenticatedProxy.sol";
import "./proxy/OwnedUpgradeabilityProxy.sol";

contract OwnableDelegateProxy is OwnedUpgradeabilityProxy {

    constructor(address owner, address initialImplementation, bytes memory callData)
    {
        setUpgradeabilityOwner(owner);
        _upgradeTo(initialImplementation);
        (bool result, ) = initialImplementation.delegatecall(callData);
        require(result,"30");
    }

}
