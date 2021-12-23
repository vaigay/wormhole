// contracts/Implementation.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;


import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../libraries/external/BytesLib.sol";
import "../../interfaces/IWormhole.sol";

interface ITokenBridge {
    function completeTransfer(bytes memory encodedVm) external returns (IWormhole.VM memory) ;
}

contract MockTokenBridgeIntegration {
    using BytesLib for bytes;
    using SafeERC20 for IERC20;
    IWormhole wormhole = IWormhole(address(0xC89Ce4735882C9F0f0FE26686c53074E09B0D550));
    ITokenBridge tokenBridge = ITokenBridge(address(0x0290FB167208Af455bB137780163b7B7a9a10C16));
    function completeTransferAndSwap(bytes memory encodedVm) public {
        IWormhole.VM memory vm = tokenBridge.completeTransfer(encodedVm);
        // token bridge transfers are 131 bytes
        // TODO: check type = 3
        uint256 amount = vm.payload.toUint256(1);
        bytes32 tokenAddress = vm.payload.toBytes32(33);
        // TODO: fee?
        // additional fields
        bytes32 receiver = vm.payload.toBytes32(131);
        IERC20 transferToken = IERC20(address(uint160(uint256(tokenAddress))));
        transferToken.safeTransfer(address(uint160(uint256(receiver))), amount);
    }
}
