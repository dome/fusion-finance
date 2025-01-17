//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./RewardToken.sol";

///@notice Main Jdai Finance contract responsible for lending, collateralizing and borrowing
///@author John Nguyen (jooohn.eth)
///@author Dome C. (jfin.eth)
contract JdaiStaking is Ownable, AccessControl {
    ///@notice events emitted after each action.
    event Lend(address indexed lender, uint amount);
    event WithdrawLend(address indexed lender, uint amount);
    event ClaimYield(address indexed lender, uint amount);
    event Collateralize(address indexed borrower, uint amount);
    event WithdrawCollateral(address indexed borrower, uint amount);
    event Borrow(address indexed borrower, uint amount);
    event Repay(address indexed borrower, uint amount);
    event Liquidate(address liquidator, uint reward, address indexed borrower);

    ///@notice mappings needed to keep track of lending
    mapping(address => uint) public lendingBalance;
    mapping(address => uint) public JdaiBalance;
    mapping(address => uint) public startTime;
    mapping(address => bool) public isLending;

    ///@notice mappings needed to keep track of collateral and borrowing
    mapping(address => uint) public collateralBalance;
    mapping(address => uint) public borrowBalance;
    mapping(address => bool) public isBorrowing;

    ///@notice declaring chainlink's price aggregator.
    AggregatorV3Interface internal priceFeed;
    address public constant baseAssetAddress =
        0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;

    ///@notice declaring token variables.
    IERC20 public immutable baseAsset;
    RewardToken public immutable JdaiToken;

    bytes32 public constant STAFF_ROLE = keccak256("STAFF_ROLE");
    uint public ethPrice;
    uint public Fee = 3;
    uint256 public totalStake = 0;

    ///@notice initiating tokens
    ///@param _baseAssetAddress address of base asset token
    ///@param _JdaiAddress address of $FUSN token
    constructor(IERC20 _baseAssetAddress, RewardToken _JdaiAddress) {
        baseAsset = _baseAssetAddress;
        JdaiToken = _JdaiAddress;
        priceFeed = AggregatorV3Interface(baseAssetAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(STAFF_ROLE, msg.sender);
    }

    modifier onlyStaff() {
        require(hasRole(STAFF_ROLE, msg.sender), "Caller is not a staff");
        _;
    }

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not a staff"
        );
        _;
    }

    function grantStaff(address staff) external onlyAdmin {
        grantRole(STAFF_ROLE, staff);
    }

    function revokeStaff(address staff) external onlyAdmin {
        revokeRole(STAFF_ROLE, staff);
    }

    function setEthPrice(uint _ethPrice) external onlyStaff {
        ethPrice = _ethPrice;
    }

    function setFee(uint _fee) external onlyStaff {
        require(_fee < 1000, "Can't set Fee > 1000!");
        Fee = _fee;
    }

    ///@notice checks if the borrow position has passed the liquidation point
    ///@dev added 'virtual' identifier for MockCore to override
    modifier passedLiquidation(address _borrower) virtual {
        uint _ethPrice = getEthPrice();
        require(
            (_ethPrice * collateralBalance[_borrower]) <=
                calculateLiquidationPoint(_borrower),
            "Position can't be liquidated!"
        );
        _;
    }

    ///@notice Function to get latest price of ETH in USD
    ///@return _ethPrice price of ETH in USD
    function getEthPrice() public view returns (uint _ethPrice) {
        _ethPrice = uint(ethPrice) / 10**8;
    }

    ///@notice calculates amount of time the lender has been lending since the last update.
    ///@param _lender address of lender
    ///@return lendingTime amount of time staked by lender
    function calculateYieldTime(address _lender)
        public
        view
        returns (uint lendingTime)
    {
        lendingTime = block.timestamp - startTime[_lender];
    }

    ///@notice calculates amount of $FUSN tokens the lender has earned since the last update.
    ///@dev rate = timeStaked / amount of time needed to earn 100% of $FUSN tokens. 31536000 = number of seconds in a year.
    ///@param _lender address of lender
    ///@return yield amount of $FUSN tokens earned by lender
    function calculateYieldTotal(address _lender)
        public
        view
        returns (uint yield)
    {
        uint timeStaked = calculateYieldTime(_lender) * 10**18;
        uint rate = timeStaked / 31536000;
        yield = (lendingBalance[_lender] * rate) / 10**18;
    }

    ///@notice calculates the borrow limit depending on the price of ETH and borrow limit rate.
    ///@return limit current borrow limit for user
    function calculateBorrowLimit(address _borrower)
        public
        view
        returns (uint limit)
    {
        uint _ethPrice = getEthPrice();
        limit =
            ((((_ethPrice * collateralBalance[_borrower]) / 100) * 70)) -
            borrowBalance[_borrower];
    }

    function calculateLiquidationPoint(address _borrower)
        public
        view
        returns (uint point)
    {
        point =
            borrowBalance[_borrower] +
            ((borrowBalance[_borrower] / 100) * 10);
    }

    ///@notice lends base asset.
    ///@param _amount amount of tokens to lend
    function lend(uint _amount) public {
        require(_amount > 0, "Can't lend amount: 0!");
        require(
            baseAsset.balanceOf(msg.sender) >= _amount,
            "Insufficient balance!"
        );

        if (isLending[msg.sender]) {
            uint yield = calculateYieldTotal(msg.sender);
            JdaiBalance[msg.sender] += yield;
        }

        lendingBalance[msg.sender] += _amount;
        startTime[msg.sender] = block.timestamp;
        isLending[msg.sender] = true;

        require(
            baseAsset.transferFrom(msg.sender, address(this), _amount),
            "Transaction failed!"
        );
        totalStake += _amount;
        emit Lend(msg.sender, _amount);
    }

    ///@notice withdraw base asset.
    ///@param _amount amount of tokens to withdraw
    function withdrawLend(uint _amount) public {
        require(isLending[msg.sender], "Can't withdraw before lending!");
        require(
            lendingBalance[msg.sender] >= _amount,
            "Insufficient lending balance!"
        );

        uint yield = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp;
        uint withdrawAmount = _amount;
        _amount = 0;
        lendingBalance[msg.sender] -= withdrawAmount;

        require(
            baseAsset.transfer(msg.sender, withdrawAmount),
            "Transaction failed!"
        );
        JdaiBalance[msg.sender] += yield;

        if (lendingBalance[msg.sender] == 0) {
            isLending[msg.sender] = false;
        }

        totalStake -= withdrawAmount;
        emit WithdrawLend(msg.sender, withdrawAmount);
    }

    ///@notice claims all yield earned by lender.
    function claimYield() public {
        uint yield = calculateYieldTotal(msg.sender);

        require(
            yield > 0 || JdaiBalance[msg.sender] > 0,
            "No, $ tokens earned!"
        );

        if (JdaiBalance[msg.sender] != 0) {
            uint oldYield = JdaiBalance[msg.sender];
            JdaiBalance[msg.sender] = 0;
            yield += oldYield;
        }

        startTime[msg.sender] = block.timestamp;
        JdaiToken.mint(msg.sender, yield);

        emit ClaimYield(msg.sender, yield);
    }

    ///@notice collateralizes user's ETH and sets borrow limit
    function collateralize() public payable {
        require(msg.value > 0, "Can't collaterlize ETH amount: 0!");

        collateralBalance[msg.sender] += msg.value;

        emit Collateralize(msg.sender, msg.value);
    }

    ///@notice withdraw user's collateral ETH and recalculates the borrow limit
    ///@param _amount amount of ETH the user wants to withdraw
    function withdrawCollateral(uint _amount) public {
        require(
            collateralBalance[msg.sender] >= _amount,
            "Not enough collateral to withdraw!"
        );
        require(
            !isBorrowing[msg.sender],
            "Can't withdraw collateral while borrowing!"
        );

        collateralBalance[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transaction Failed!");

        emit WithdrawCollateral(msg.sender, _amount);
    }

    ///@notice borrows base asset
    ///@param _amount amount of base asset to borrow
    ///@dev deducting 0.3% from msg.sender's ETH collateral as protocol's fees
    function borrow(uint _amount) public {
        collateralBalance[msg.sender] -=
            (collateralBalance[msg.sender] / 1000) *
            3;

        require(collateralBalance[msg.sender] > 0, "No ETH collateralized!");
        require(
            calculateBorrowLimit(msg.sender) >= _amount,
            "Borrow amount exceeds borrow limit!"
        );

        isBorrowing[msg.sender] = true;
        borrowBalance[msg.sender] += _amount;
        uint _amountTransfer = _amount - ((_amount / 1000) * Fee);
        require(
            baseAsset.transfer(msg.sender, _amountTransfer),
            "Transaction failed!"
        );

        emit Borrow(msg.sender, _amount);
    }

    ///@notice repays base asset debt
    ///@param _amount amount of base asset to repay
    function repay(uint _amount) public {
        require(isBorrowing[msg.sender], "Can't repay before borrowing!");
        require(
            baseAsset.balanceOf(msg.sender) >= _amount,
            "Insufficient funds!"
        );
        require(
            _amount > 0 && _amount <= borrowBalance[msg.sender],
            "Can't repay amount: 0 or more than amount borrowed!"
        );

        if (_amount == borrowBalance[msg.sender]) {
            isBorrowing[msg.sender] = false;
        }

        borrowBalance[msg.sender] -= _amount;

        require(
            baseAsset.transferFrom(msg.sender, address(this), _amount),
            "Transaction Failed!"
        );

        emit Repay(msg.sender, _amount);
    }

    ///@notice liquidates a borrow position
    ///@param _borrower address of borrower
    ///@dev passedLiquidation modifier checks if the borrow position has passed liquidation point
    ///@dev liquidationReward 1.25% of borrower's ETH collateral
    function liquidate(address _borrower) public passedLiquidation(_borrower) {
        require(isBorrowing[_borrower], "This address is not borrowing!");

        uint liquidationReward = (collateralBalance[_borrower] / 10000) * 125;

        collateralBalance[_borrower] = 0;
        borrowBalance[_borrower] = 0;
        isBorrowing[_borrower] = false;

        (bool success, ) = msg.sender.call{value: liquidationReward}("");
        require(success, "Transaction Failed!");

        emit Liquidate(msg.sender, liquidationReward, _borrower);
    }

    ///@notice returns lending status of lender
    function getLendingStatus(address _lender) external view returns (bool) {
        return isLending[_lender];
    }

    ///@notice retuns amount of $FUSN tokens earned
    function getEarnedJdaiTokens(address _lender) external view returns (uint) {
        return JdaiBalance[_lender] + calculateYieldTotal(_lender);
    }

    ///@notice returns amount of base asset lent
    function getLendingBalance(address _lender) external view returns (uint) {
        return lendingBalance[_lender];
    }

    ///@notice returns amount of collateralized asset
    function getCollateralBalance(address _borrower)
        external
        view
        returns (uint)
    {
        return collateralBalance[_borrower];
    }

    ///@notice returns borrowing status of borrower
    function getBorrowingStatus(address _borrower)
        external
        view
        returns (bool)
    {
        return isBorrowing[_borrower];
    }

    ///@notice returns amount of base asset borrowed
    function getBorrowBalance(address _borrower) external view returns (uint) {
        return borrowBalance[_borrower];
    }

    ///@notice returns amount of base asset available to borrow
    function getBorrowLimit(address _borrower) external view returns (uint) {
        return calculateBorrowLimit(_borrower);
    }

    ///@notice returns liquidation point
    function getLiquidationPoint(address _borrower)
        external
        view
        returns (uint)
    {
        return calculateLiquidationPoint(_borrower);
    }
}
