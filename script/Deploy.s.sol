// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console } from "forge-std/Script.sol";
import { ERC20Permit } from "@/core/ModERC20Permit.sol";
import { Test } from "forge-std/Test.sol";

contract DeployScript is Script, Test {

    string private _name = "Live Token";
    string private _symbol = 'Live';
    uint constant _initialSupply = 1_000_000_000e18;

    ERC20Permit public _gasEfficientToken;

    function setUp() public {}

    function run() public {

        // vv Read Key from env var
        uint deployerKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        
        // broadcast using deployer wallet
        vm.startBroadcast(deployerKey); 

            /// Deploy token and Log important token info
            _gasEfficientToken  = new ERC20Permit(_name, _symbol, _initialSupply);
            emit log_named_address('Token Address:::', address(_gasEfficientToken));
            emit log_named_string('Token Name:::', _gasEfficientToken.name());
            emit log_named_string('Token Symbol', _gasEfficientToken.symbol());
            emit log_named_uint('balance', _gasEfficientToken.balanceOf(deployer));

        vm.stopBroadcast();
    }
}
