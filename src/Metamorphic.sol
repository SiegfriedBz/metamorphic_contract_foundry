// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract A {
    function getVersion() public pure returns (string memory) {
        return "A";
    }

    function kill() public {
        selfdestruct(payable(msg.sender));
    }
}

contract B {
    function getVersion() public pure returns (string memory) {
        return "B";
    }
}

contract Factory {
    function helloA() public returns (address) {
        // deploy A using CREATE
        // deployer is this = factory instance
        // deploy @ address = f ( address(this), NONCE of this account )
        // address of A is derived from address of factory account and the factory account current nonce
        return address(new A());
    }

    function helloB() public returns (address) {
        // deploy B using CREATE
        // deployer is this = factory instance
        // deploy @ address = f ( address(this), NONCE of this account )
        // address of B is derived from address of factory account and the factory account current nonce
        return address(new B());
    }

    function kill() public {
        // Transfers ETH to the caller
        // After Cancun (EIP-6780), this no longer removes code or resets nonce
        // !! unless called in the same tx as contract creation
        selfdestruct(payable(msg.sender));
    }
}
