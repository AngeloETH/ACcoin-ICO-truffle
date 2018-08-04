pragma solidity ^0.4.24;

import "./safemath.sol";

contract Erc20 {
    
    uint256 public totalSupply = 0;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
     
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() public{

    }
    
    
    using SafeMath for uint256;
    
    function totalSupply() public view returns (uint256){
        return totalSupply;
    }
    function balanceOf(address who) public view returns (uint256) {
        return balanceOf[who];
    }
    
    function _transfer(address from, address to, uint256 value) internal {
        require ( to != 0x0);
        //uint256 value = _value * 10 ** uint256(decimals);
        require (balanceOf[from] >= value);
        uint256 Balance = balanceOf[from].add(balanceOf[to]);
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        assert(balanceOf[from].add(balanceOf[to]) == Balance);
        emit Transfer(from,to,value);
        
    }
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender,to,value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require (allowance[msg.sender][from] >= value);
        allowance[msg.sender][from] = allowance[msg.sender][from].sub(value);
        _transfer(from,to,value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        require(value > 0);
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(value);
        emit Approval(msg.sender,spender,value);
        return true;
    }
    
    function allowance(address owner, address spender)
    public view returns (uint256) {
        return allowance[owner][spender];
    }
}