
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.2;

import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./ERC20.sol";
import "./Address.sol";
import "./TokenRoles.sol";

contract CyberLink is Context, ERC20, Ownable, TokenRoles{
    
    using SafeMath for uint256;
    using Address for address;
 
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
 
    mapping (address => bool) private _isExcludedFromFees;
 
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
 
    event ExcludeFromFees(address indexed account, bool isExcluded);
 
    constructor() public ERC20("CyberLink", "CBL") {
 
    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
 
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
 
        _mint(owner(), 1e8 * (10**18));
    }
 
    receive() external payable {
 
  	}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(_isExcludedFromFees[account] != excluded);
        _isExcludedFromFees[account] = excluded;
 
        emit ExcludeFromFees(account, excluded);
    } 
 
    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0));
        require(to != address(0));
        require(!tokenIsInJail(from));
        
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool takeFee = true;
 
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
 
        if(takeFee) {

            uint256 fees = amount.div(1000);

        	amount = amount.sub(fees);
 
            _burn(from, fees);
        }

        super._transfer(from, to, amount);
    }

}