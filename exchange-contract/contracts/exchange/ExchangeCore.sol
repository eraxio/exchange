// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../registry/ProxyRegistry.sol";
import "../registry/TokenTransferProxy.sol";
import "../registry/AuthenticatedProxy.sol";
import "../common/ArrayUtils.sol";
import "../common/ReentrancyGuarded.sol";
import "./SaleKindInterface.sol";


/**
 * @title ExchangeCore
 * @author Project Erax Developers
 */
contract ExchangeCore is ReentrancyGuarded, Ownable {

    /* User registry. */
    ProxyRegistry public registry;

    /* Token transfer proxy. */
    TokenTransferProxy public tokenTransferProxy;

    /* Cancelled / finalized orders, by hash. */
    mapping(bytes32 => bool) public cancelledOrFinalized;

    /* The asset contract which use standard version. */
    mapping(address => bool) public sharedProxyAddresses;

    uint public maximumOriginatorFee = 0x3e8;

    uint public maximumAgentFee = 0xfa0;

    /* Fee method: protocol fee or split fee. */
    enum FeeMethod { ProtocolFee, SplitFee }

    /* Inverse basis point. */
    uint public constant INVERSE_BASIS_POINT = 10000;

    /* An ECDSA signature. */
    struct Sig {
        /* v parameter */
        uint8 v;
        /* r parameter */
        bytes32 r;
        /* s parameter */
        bytes32 s;
    }

    /* An order on the exchange. */
    struct Order {
        /* Exchange address, intended as a versioning mechanism. */
        address exchange;
        /* Order maker address. */
        address maker;
        /* Order taker address, if specified. */
        address taker;
        /* Maker relayer fee of the order, unused for taker order. */
        uint makerRelayerFee;
        /* Taker relayer fee of the order, or maximum taker fee for a taker order. */
        uint takerRelayerFee;
        /* Maker protocol fee of the order, unused for taker order. */
        uint makerProtocolFee;
        /* Taker protocol fee of the order, or maximum taker fee for a taker order. */
        uint takerProtocolFee;
        /* Order fee recipient or zero address for taker order. */
        address feeRecipient;
        /* Fee method (protocol token or split fee). */
        FeeMethod feeMethod;
        /* Side (buy/sell). */
        SaleKindInterface.Side side;
        /* Kind of sale. */
        SaleKindInterface.SaleKind saleKind;
        /* Target. */
        address target;
        /* HowToCall. */
        AuthenticatedProxy.HowToCall howToCall;
        /* Calldata. */
        bytes callData;
        /* Calldata replacement pattern, or an empty byte array for no replacement. */
        bytes replacementPattern;
        /* Agent who can help sell the good. */
        address agent;
        /* Agent fee nee to be charged. */
        uint agentFee;
        /* Token used to pay for the order, or the zero-address as a sentinel value for Ether. */
        address paymentToken;
        /* Base price of the order (in paymentTokens). */
        uint basePrice;
        /* Auction extra parameter - minimum bid increment for English auctions, starting/ending price difference. */
        uint extra;
        /* Listing timestamp. */
        uint listingTime;
        /* Expiration timestamp - 0 for no expiry. */
        uint expirationTime;
        /* Order salt, used to prevent duplicate hashes. */
        uint salt;
        }

        event OrderCancelled          (bytes32 indexed hash);
        event OrdersMatched           (bytes32 buyHash, bytes32 sellHash, address indexed maker, address indexed taker, uint price, bytes32 indexed metadata);

        /**
             * @dev Allows owner to add a shared proxy address
             */
        function addSharedProxyAddress(address _address) public onlyOwner {
            sharedProxyAddresses[_address] = true;
        }

        /**
         * @dev Allows owner to remove a shared proxy address
         */
        function removeSharedProxyAddress(address _address) public onlyOwner {
            delete sharedProxyAddresses[_address];
        }



        /**
         * @dev Change the maximum originator fee paid to originator (owner only)
         * @param _maximumOriginatorFee New fee to set in basis points
         */
        function changeMaximumOriginatorFee(uint _maximumOriginatorFee)
        public
        onlyOwner
        {
            maximumOriginatorFee = _maximumOriginatorFee;
        }


        /**
         * @dev Change the maximum agent fee paid to the agent (owner only)
         * @param _maximumAgentFee New fee to set in basis points
         */
        function changeMaximumAgentFee(uint _maximumAgentFee)
        public
        onlyOwner
        {
            maximumAgentFee = _maximumAgentFee;
        }



        /**
         * @dev Transfer tokens
         * @param token Token to transfer
         * @param from Address to charge fees
         * @param to Address to receive fees
         * @param amount Amount of protocol tokens to charge
         */
        function transferTokens(address token, address from, address to, uint amount)
        internal
        {
            if (amount > 0) {
                require(tokenTransferProxy.transferFrom(token, from, to, amount),"5");
            }
        }

        /**
         * Calculate size of an order struct when tightly packed
         *
         * @param order Order to calculate size of
         * @return Size in bytes
         */
        function sizeOf(Order memory order)
        internal
        pure
        returns (uint)
        {
            return ((0x14 * 7) + (0x20 * 10) + 4 + order.callData.length + order.replacementPattern.length);
        }

        /**
         * @dev Hash an order, returning the canonical order hash, without the message prefix
         * @param order Order to hash
         * @return hash Hash of order
         */
        function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 hash)
        {
            /* Unfortunately abi.encodePacked doesn't work here, stack size constraints. */
            uint size = sizeOf(order);
            bytes memory array = new bytes(size);
            uint index;
            assembly {
                index := add(array, 0x20)
            }
            index = ArrayUtils.unsafeWriteAddress(index, order.exchange);
            index = ArrayUtils.unsafeWriteAddress(index, order.maker);
            index = ArrayUtils.unsafeWriteAddress(index, order.taker);
            index = ArrayUtils.unsafeWriteUint(index, order.makerRelayerFee);
            index = ArrayUtils.unsafeWriteUint(index, order.takerRelayerFee);
            index = ArrayUtils.unsafeWriteUint(index, order.makerProtocolFee);
            index = ArrayUtils.unsafeWriteUint(index, order.takerProtocolFee);
            index = ArrayUtils.unsafeWriteAddress(index, order.feeRecipient);
            index = ArrayUtils.unsafeWriteUint8(index, uint8(order.feeMethod));
            index = ArrayUtils.unsafeWriteUint8(index, uint8(order.side));
            index = ArrayUtils.unsafeWriteUint8(index, uint8(order.saleKind));
            index = ArrayUtils.unsafeWriteAddress(index, order.target);
            index = ArrayUtils.unsafeWriteUint8(index, uint8(order.howToCall));
            index = ArrayUtils.unsafeWriteBytes(index, order.callData);
            index = ArrayUtils.unsafeWriteBytes(index, order.replacementPattern);
            index = ArrayUtils.unsafeWriteAddress(index, order.agent);
            index = ArrayUtils.unsafeWriteUint(index, order.agentFee);
            index = ArrayUtils.unsafeWriteAddress(index, order.paymentToken);
            index = ArrayUtils.unsafeWriteUint(index, order.basePrice);
            index = ArrayUtils.unsafeWriteUint(index, order.extra);
            index = ArrayUtils.unsafeWriteUint(index, order.listingTime);
            index = ArrayUtils.unsafeWriteUint(index, order.expirationTime);
            index = ArrayUtils.unsafeWriteUint(index, order.salt);
            assembly {
                hash := keccak256(add(array, 0x20), size)
            }
            return hash;
        }

        /**
         * @dev Hash an order, returning the hash that a client must sign, including the standard message prefix
         * @param order Order to hash
         * @return Hash of message prefix and order hash per Ethereum format
         */
        function hashToSign(Order memory order)
        internal
        pure
        returns (bytes32)
        {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashOrder(order)));
        }

        /**
         * @dev Assert an order is valid and return its hash
         * @param order Order to validate
         * @param sig ECDSA signature
         */
        function requireValidOrder(Order memory order, Sig memory sig)
        internal
        view
        returns (bytes32)
        {
            bytes32 hash = hashToSign(order);
            require(validateOrder(hash, order, sig),"6");
            return hash;
        }

        /**
         * @dev Validate order parameters (does *not* check signature validity)
         * @param order Order to validate
         */
        function validateOrderParameters(Order memory order)
        internal
        view
        returns (bool)
        {
            /* Order must be targeted at this protocol version (this Exchange contract). */
            if (order.exchange != address(this)) {
                return false;
            }

            /* Order must possess valid sale kind parameter combination. */
            if (!SaleKindInterface.validateParameters(order.saleKind, order.expirationTime)) {
                return false;
            }


            return true;
        }

        /**
         * @dev Validate a provided previously approved / signed order, hash, and signature.
         * @param hash Order hash (already calculated, passed to avoid recalculation)
         * @param order Order to validate
         * @param sig ECDSA signature
         */
        function validateOrder(bytes32 hash, Order memory order, Sig memory sig)
        internal
        view
        returns (bool)
        {
            /* Not done in an if-conditional to prevent unnecessary ecrecover evaluation, which seems to happen even though it should short-circuit. */

            /* Order must have valid parameters. */
            if (!validateOrderParameters(order)) {
                return false;
            }

            /* Order must have not been canceled or already filled. */
            if (cancelledOrFinalized[hash]) {
                return false;
            }


            /* or (b) ECDSA-signed by maker. */
            if (ecrecover(hash, sig.v, sig.r, sig.s) == order.maker) {
                return true;
            }

            return false;
        }


        /**
         * @dev Cancel an order, preventing it from being matched. Must be called by the maker of the order
         * @param order Order to cancel
         * @param sig ECDSA signature
         */
        function cancelOrder(Order memory order, Sig memory sig)
        internal
        {
            /* CHECKS */

            /* Calculate order hash. */
            bytes32 hash = requireValidOrder(order, sig);

            /* Assert sender is authorized to cancel order. */
            require(msg.sender == order.maker,"9");

            /* EFFECTS */

            /* Mark order as cancelled, preventing it from being matched. */
            cancelledOrFinalized[hash] = true;

            /* Log cancel event. */
            emit OrderCancelled(hash);
        }

        /**
         * @dev Calculate the current price of an order (convenience function)
         * @param order Order to calculate the price of
         * @return The current price of the order
         */
        function calculateCurrentPrice (Order memory order)
        internal
        view
        returns (uint)
        {
            return SaleKindInterface.calculateFinalPrice(order.side, order.saleKind, order.basePrice, order.extra, order.listingTime, order.expirationTime);
        }

        /**
         * @dev Calculate the price two orders would match at, if in fact they would match (otherwise fail)
         * @param buy Buy-side order
         * @param sell Sell-side order
         * @return Match price
         */
        function calculateMatchPrice(Order memory buy, Order memory sell)
        view
        internal
        returns (uint)
        {
            /* Calculate sell price. */
            uint sellPrice = SaleKindInterface.calculateFinalPrice(sell.side, sell.saleKind, sell.basePrice, sell.extra, sell.listingTime, sell.expirationTime);

            /* Calculate buy price. */
            uint buyPrice = SaleKindInterface.calculateFinalPrice(buy.side, buy.saleKind, buy.basePrice, buy.extra, buy.listingTime, buy.expirationTime);

            /* Require price cross. */
            require(buyPrice >= sellPrice,"10");

            /* Maker/taker priority. */
            return sell.feeRecipient != address(0) ? sellPrice : buyPrice;
        }


        function getOriginator(bytes memory _callData)
        internal
        returns (address)
        {
            uint originator;
            assembly {
                originator := mload(add(_callData, 0x64))
            }
            return address(originator >> 96);
        }


        function getOriginatorFee(bytes memory _callData)
        internal
        returns (uint)
        {
            uint originatorFee;
            assembly {
                originatorFee := mload(add(_callData, 0x78))
            }
            return originatorFee >> 232;
        }
        /**
         * @dev Execute all ERC20 token / Ether transfers associated with an order match (fees and buyer => seller transfer)
         * @param buy Buy-side order
         * @param sell Sell-side order
         */
        function executeFundsTransfer(Order memory buy, Order memory sell)
        internal
        returns (uint)
        {
            /* Only payable in the special case of unwrapped Ether. */
            if (sell.paymentToken != address(0)) {
                require(msg.value == 0,"11");
            }

            /* Calculate match price. */
            uint price = calculateMatchPrice(buy, sell);
            require(price > 0, "40");

            /* If paying using a token (not Ether), transfer tokens. This is done prior to fee payments to that a seller will have tokens before being charged fees. */
            if (sell.paymentToken != address(0)) {
                transferTokens(sell.paymentToken, buy.maker, sell.maker, price);
            }else{
                /* Special-case Ether, order must be matched by buyer. */
                require(msg.value >= price,"17");
            }

            /* We need seller to pay the fee */
            require (sell.feeRecipient != address(0),"12");
            require (sell.makerRelayerFee >= 0,"13");

            uint makerRelayerFee = SafeMath.div(SafeMath.mul(sell.makerRelayerFee, price), INVERSE_BASIS_POINT);
            uint fee = makerRelayerFee;
            uint agentFee;
            uint originatorFee;
            address originator;

            if(sell.agent!= address(0) && sell.agentFee > 0){
                require(sell.agentFee <= maximumAgentFee, "43");
                agentFee = SafeMath.div(SafeMath.mul(sell.agentFee, price), INVERSE_BASIS_POINT);
                fee = SafeMath.add(fee, agentFee);
            }

            if (sharedProxyAddresses[sell.target]) {
                originatorFee = getOriginatorFee(sell.callData);

                if(originatorFee > 0){
                    require(originatorFee <= maximumOriginatorFee, "41");
                    originator = getOriginator(sell.callData);
                    originatorFee = SafeMath.div(SafeMath.mul(originatorFee, price), INVERSE_BASIS_POINT);
                    fee = SafeMath.add(fee, originatorFee);
                }
            }

            /*The seller received must be greater than 0*/
            require (price > fee,"46");

            if (sell.paymentToken == address(0)) {

                /* charge fee */
                payable(sell.feeRecipient).transfer(makerRelayerFee);

                if(agentFee>0){
                    payable(sell.agent).transfer(agentFee);
                }

                if(originatorFee>0){
                    payable(originator).transfer(originatorFee);
                }

                /* safe math will ensure price > fee*/
                payable(sell.maker).transfer(SafeMath.sub(price, fee));

                /* Allow overshoot for variable-price auctions, refund difference. */
                uint diff = SafeMath.sub(msg.value, price);
                if (diff > 0) {
                    payable(buy.maker).transfer(diff);
                }
            }else{

                /* charge fee */
                transferTokens(sell.paymentToken, sell.maker, sell.feeRecipient, makerRelayerFee);

                if(agentFee>0){
                    transferTokens(sell.paymentToken, sell.maker, payable(sell.agent), agentFee);
                }

                if(originatorFee>0){
                    transferTokens(sell.paymentToken, sell.maker, originator, originatorFee);
                }

            }

            /* This contract should never hold Ether, however, we cannot assert this, since it is impossible to prevent anyone from sending Ether e.g. with selfdestruct. */

            return price;
        }

        /**
         * @dev Return whether or not two orders can be matched with each other by basic parameters (does not check order signatures / calldata or perform static calls)
         * @param buy Buy-side order
         * @param sell Sell-side order
         * @return Whether or not the two orders can be matched
         */
        function ordersCanMatch(Order memory buy, Order memory sell)
        internal
        view
        returns (bool)
        {
            return (
            /* Must be opposite-side. */
            (buy.side == SaleKindInterface.Side.Buy && sell.side == SaleKindInterface.Side.Sell) &&
            /* Must use same fee method. */
            (buy.feeMethod == sell.feeMethod) &&
            /* Must use same payment token. */
            (buy.paymentToken == sell.paymentToken) &&
            /* Must match maker/taker addresses. */
            (sell.taker == address(0) || sell.taker == buy.maker) &&
            (buy.taker == address(0) || buy.taker == sell.maker) &&
            /* One must be maker and the other must be taker (no bool XOR in Solidity). */
            ((sell.feeRecipient == address(0) && buy.feeRecipient != address(0)) || (sell.feeRecipient != address(0) && buy.feeRecipient == address(0))) &&
            /* Must match target. */
            (buy.target == sell.target) &&
            /* Must match howToCall. */
            (buy.howToCall == sell.howToCall) &&
            /* Buy-side order must be settleable. */
            SaleKindInterface.canSettleOrder(buy.listingTime, buy.expirationTime) &&
            /* Sell-side order must be settleable. */
            SaleKindInterface.canSettleOrder(sell.listingTime, sell.expirationTime)
            );
        }

        /**
         * @dev Atomically match two orders, ensuring validity of the match, and execute all associated state transitions. Protected against reentrancy by a contract-global lock.
         * @param buy Buy-side order
         * @param buySig Buy-side order signature
         * @param sell Sell-side order
         * @param sellSig Sell-side order signature
         */
        function atomicMatch(Order memory buy, Sig memory buySig, Order memory sell, Sig memory sellSig, bytes32 metadata)
        internal
        reentrancyGuard
        {
            /* CHECKS */

            /* Ensure buy order validity and calculate hash if necessary. */
            bytes32 buyHash;
            if (buy.maker == msg.sender) {
                require(validateOrderParameters(buy),"18");
            } else {
                buyHash = requireValidOrder(buy, buySig);
            }

            /* Ensure sell order validity and calculate hash if necessary. */
            bytes32 sellHash;
            if (sell.maker == msg.sender) {
                require(validateOrderParameters(sell),"19");
            } else {
                sellHash = requireValidOrder(sell, sellSig);
            }

            /* Must be matchable. */
            require(ordersCanMatch(buy, sell),"20");

            /* Target must exist (prevent malicious selfdestructs just prior to order settlement). */
            uint size;
            address target = sell.target;
            assembly {
                size := extcodesize(target)
            }
            require(size > 0,"21");

            /* Must match calldata after replacement, if specified. */
            if (buy.replacementPattern.length > 0) {
                ArrayUtils.guardedArrayReplace(buy.callData, sell.callData, buy.replacementPattern);
            }
            if (sell.replacementPattern.length > 0) {
                ArrayUtils.guardedArrayReplace(sell.callData, buy.callData, sell.replacementPattern);
            }
            require(ArrayUtils.arrayEq(buy.callData, sell.callData),"22");

            /* Retrieve delegateProxy contract. */
            OwnableDelegateProxy delegateProxy = registry.proxies(sell.maker);

            /* Proxy must exist. */
            require(address(delegateProxy) != address(0),"23");

            /* Assert implementation. */
            require(delegateProxy.implementation() == registry.delegateProxyImplementation(),"24");

            /* Access the passthrough AuthenticatedProxy. */
            AuthenticatedProxy proxy = AuthenticatedProxy(payable(delegateProxy));

            /* EFFECTS */

            /* Mark previously signed or approved orders as finalized. */
            if (msg.sender != buy.maker) {
                cancelledOrFinalized[buyHash] = true;
            }
            if (msg.sender != sell.maker) {
                cancelledOrFinalized[sellHash] = true;
            }

            /* INTERACTIONS */

            /* Execute funds transfer and pay fees. */
            uint price = executeFundsTransfer(buy, sell);

            /* Execute specified call through proxy. */
            require(proxy.proxy(sell.target, sell.howToCall, sell.callData),"25");


            /* Log match event. */
            emit OrdersMatched(buyHash, sellHash, sell.feeRecipient != address(0) ? sell.maker : buy.maker, sell.feeRecipient != address(0) ? buy.maker : sell.maker, price, metadata);
        }

}
