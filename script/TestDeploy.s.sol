// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { ERC20Permit } from "@/core/ModERC20Permit.sol";
import { Test } from "forge-std/Test.sol";

/**
 *  $forge script script/TestDeploy.s.sol:TestDeployScript --fork-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
 */
contract TestDeployScript is Script, Test {

    string private _name = "Test Token";
    string private _symbol = 'T';
    uint constant _initialSupply = 1_000_000_000e18;

    /// TEST_TOKEN_OWNER
    /// this address is used to mint all tokens because this gives the address a balance of all tokens 
    address payable constant TEST_TOKEN_OWNER = payable(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

    ERC20Permit public _gasEfficientToken;

    function setUp() public {}

    function run() public {
        
        // broadcast using deployer wallet
        vm.startBroadcast(); 

        // Deploy Mock tokens and log token info
        _gasEfficientToken  = new ERC20Permit(_name, _symbol, _initialSupply);
        emit log_named_address('Token Address:::', address(_gasEfficientToken));
        emit log_named_string('Token Name:::', _gasEfficientToken.name());
        emit log_named_string('Token Symbol', _gasEfficientToken.symbol());
        emit log_named_uint('balance', _gasEfficientToken.balanceOf(TEST_TOKEN_OWNER));

        vm.stopBroadcast();
    }
}
