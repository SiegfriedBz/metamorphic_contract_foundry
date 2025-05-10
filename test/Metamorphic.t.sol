// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Metamorphic.sol";

/**
 * @notice on deployed contracts addresses
 * - CREATE => deploy @ address = f ( deployer address, NONCE of deployer account )
 * - CREATE2 => deploy @ address = f ( deployer address + salt + bytecode to deploy )
 *
 * @notice SELFDESTRUCT
 *  - Transfers ETH to the caller
 *  - After Cancun (EIP-6780), this no longer removes code or resets nonce
 *       !! unless called in the same tx as contract creation
 *       !! ===> kill a + factory instances INSIDE setUp below
 */

/**
 * @notice CREATE => deploy @ address = f ( deployerAddress, NONCE of deployer account
 * @notice CREATE2 => deploy @ address = f ( deployerAddress + salt + bytecode to deploy )
 */
contract MetamorphicTest is Test {
    A public a;
    B public b;
    Factory public factory;

    /**
     * @notice "selfdestruct" has been deprecated. Note that, starting from the Cancun hard fork,
     * the underlying opcode
     * !! no longer deletes the code and data associated with an account and only transfers its Ether to the beneficiary,
     * !! unless executed in the same transaction in which the contract was created (see EIP-6780).
     *
     * @dev ===> kill a + factory instances INSIDE setUp below
     */
    function setUp() public {
        /**
         * deploy factory with CREATE2
         * !! => factory address = f ( deployerAddress + salt + factory bytecode )
         */
        factory = new Factory{salt: keccak256(abi.encodePacked("eve"))}();

        /**
         * deploy a instance with CREATE
         * @notice at this point NONCE of factory account = X
         * !! => a address = f ( factory address, NONCE of factory account )
         */
        a = A(factory.helloA());

        /**
         * destroy a
         */
        a.kill();

        /**
         * destroy factory
         * we will deploy a NEW factory in test
         *  !! => with SAME ADDRESS + FRESH NONCE
         */
        factory.kill();
    }

    function test_Metamorphic() public {
        /**
         * deploy a NEW factory with CREATE2
         * !! => factory address = f ( deployerAddress + salt + factory bytecode )
         * !! ===> factory address is the SAME as in setUp + FRESH NONCE
         */
        factory = new Factory{salt: keccak256(abi.encodePacked("eve"))}();

        /**
         * deploy b instance with CREATE
         * @notice at this point NONCE of factory account = X
         * !! => b address = f ( factory address, NONCE of factory account )
         */
        b = B(factory.helloB());

        assertEq(address(a), address(b));
        // !! B was deployed to the SAME ADDRESS as A
    }
}
