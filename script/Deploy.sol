// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";
import "src/TransferLogistics.sol";

contract Deploy is Script {

    uint256 gnosis;
    string RPC_GNOSIS = vm.envString("RPC_GNOSIS");

    function run() external {
        /*//////////////////////////////////////////////////////////////
                                KEY MANAGEMENT
        //////////////////////////////////////////////////////////////*/

        uint256 deployerPrivateKey = 0;
        string memory mnemonic = vm.envString("MNEMONIC");
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        if (bytes(mnemonic).length > 30) {
            deployerPrivateKey = vm.deriveKey(mnemonic, 0);
        } else if (privKey > 1 ether) {
            deployerPrivateKey = privKey;
        }

        /*//////////////////////////////////////////////////////////////
                                NETWORK MANAGEMENT
        //////////////////////////////////////////////////////////////*/

        gnosis = vm.createFork(RPC_GNOSIS);
        vm.selectFork(gnosis);

        /*//////////////////////////////////////////////////////////////
                                OPERATIONS
        //////////////////////////////////////////////////////////////*/

        vm.startBroadcast(deployerPrivateKey);

        // Deploy TransferLogistics
         TransferLogistics tl = new TransferLogistics();
         console2.log("Deployed TransferLogistics: %s", address(tl));

        vm.stopBroadcast();
    }
}
