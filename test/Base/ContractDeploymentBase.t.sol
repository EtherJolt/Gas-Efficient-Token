// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

/// HELPERS
import { BaseTestEnvironment } from 'test/Base/BaseTestEnvironment.t.sol';
import { ERC20Permit } from "@/core/ModERC20Permit.sol";
import { OpenZepERC20Permit } from '@/core/OpenZeppelinERC20Permit.sol';

/// CONTRACTS TO DEPLOY IN TEST ENVIRONMENT
contract ContractDeploymentBase is BaseTestEnvironment {

    /// TOKENS
    uint constant _initialSupply = 1_000_000_000_000e18; // 1 tillion token supply

    uint TEST_TOKEN_COUNT = 3;
    address[] internal test_tokens;
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // 1
    OpenZepERC20Permit public openZepToken; // 2
    ERC20Permit public gasEfficientToken; // 3

    function setUp() public virtual override {
        // setup inherited base environment
        BaseTestEnvironment.setUp();

        /// all Token contracts deployed && owned by Token Owner
        vm.startPrank(TokenOwner);

            openZepToken = new OpenZepERC20Permit('USD Coin', 'USDC', _initialSupply);
            gasEfficientToken = new ERC20Permit("Dollar", "D", _initialSupply);
    
            /// deposit 10 Eth, giving TokenOwner ETH Balance
            vm.deal(TokenOwner, _initialSupply);

        vm.stopPrank();

        /// all Other contracts deployed && owned by Master Owner
        vm.startPrank(MasterOwner);

        vm.stopPrank();

        emit log_named_address('openZepToken', address(openZepToken));
        emit log_named_address('gasEfficientToken', address(gasEfficientToken));


        test_tokens.push(NATIVE_TOKEN); // 1
        test_tokens.push(address(openZepToken)); // 2
        test_tokens.push(address(gasEfficientToken)); // 3
    }
}