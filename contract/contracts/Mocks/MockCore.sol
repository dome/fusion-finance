//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../JdaiCore.sol";

///@notice Mock of JdaiCore contract for testing liquidate function
contract MockCore is JdaiCore {

    constructor(IERC20 _baseAssetAddress, RewardToken _fusionAddress) JdaiCore(_baseAssetAddress, _fusionAddress){}

    ///@notice overriding the passedLiquidation modifier to mock the price of ETH. Let's anyone liquidate any borrow position.
    ///@dev ethPrice set to 1 to be able to get liquidated
    modifier passedLiquidation(address _borrower) override {
        uint ethPrice = 1;
        require((ethPrice * collateralBalance[_borrower]) <= calculateLiquidationPoint(_borrower), "Position can't be liquidated!");
        _;
    }

}