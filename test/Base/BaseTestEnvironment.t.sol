// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Test } from  "forge-std/Test.sol";

/**
 * [ RUN TESTS ]
 *  $forge test --match-path test/Token/{suite}
 *  $forge test --match-path test/Vault/{suite}
 * 
 * this is the base contract used in all tests
 * the values within are public/internal to be accessible to all inheriting contracts
 */
contract BaseTestEnvironment is Test {
        
    /// Admin Wallets
    address internal MasterOwner; //Owner address for all contracts 

    /// all mock tokens are deployed to this account, only account with any initial Token balance
    address public TokenOwner; 
    uint internal TokenOwnerKey;
    
    ///
    /// [ USERS ]
    ///
    /// @notice 2^n users exist for initial subscription batch creation
    /// need method for creating padded batches if batchSize != 2^n
    /// MAKE SURE NEW USERS ARE ALSO INSERTED INTO USERS ARRAY IN SETUP BELOW
    address internal Alice;
    address internal Bob;

    function setUp() public virtual {    

        MasterOwner = makeAddr('MasterOwner');
        // emit log_named_address('MasterOwner', MasterOwner);
        
        ( TokenOwner, TokenOwnerKey ) = makeAddrAndKey("TokenOwner");
        emit log_named_address('TokenOwner', TokenOwner);

        Alice = makeAddr("Alice");
        emit log_named_address('Alice', Alice);

        Bob = makeAddr("Bob");
        emit log_named_address('Bob', Bob);
    }
}