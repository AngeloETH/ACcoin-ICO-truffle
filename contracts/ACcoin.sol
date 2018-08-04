pragma solidity ^0.4.24;

import "./safemath.sol";
import "./Erc20.sol";
import "./Ownable.sol";

contract ACcoin is Erc20, Ownable {
    

    string public constant name = "Angelo coin";
    string public constant symbol = "AC";
    uint public constant decimals = (1 ether/1 wei); 
    uint256 public uintOfEth = 300;
    uint256 public totalsupply=200000;    //total supply equals 200*1000AC
    uint256 public price_1 = 1000; //1eth can buy 1000AC, in this tier received 100 ether
    uint256 public price_2 = 500;  //1eth can buy 500AC, in this tier received 100 ether
    uint256 public price_3 = 300;  //1eth can buy 300AC, in this tier received 100 ether
    uint256 public teamAC = 200;   //ACcoin team can get 200*100 ACcoin

    
    uint256 public tokensold = 0;  //record the token sold 
    using SafeMath for uint256;
    
    address public constant  teamACcoin =     0xd0f1bbd349e06cb64e24ffef6702dd124dbdf596;
    enum State{
       Init,
       Paused,

       ICORunning,
       ICOFinished
    }

    State public currentState = State.Init;
    bool enableTransfer = false;
    
    modifier onlyInState(State state){
        require(state == currentState);
        _;
    }

    event buy(address owner, uint256 value);
    
    
    constructor() public {
        totalsupply = totalsupply.mul(decimals);
        balanceOf[teamACcoin] = teamAC.mul(100).mul(decimals);//Team ACcoin can get 200*1000 ACcoin

    }

    function buytoken() public payable onlyInState(State.ICORunning){
        uint256 price = getprice();
        if (price == 0){
            setState(State.ICOFinished);
        }
        require (price != 0);  //token are totally sold, ICO are finished
        require(msg.value >= 0.01 ether);
        uint256 newtoken = (msg.value).mul(price);
        require(tokensold.add(newtoken) <= totalsupply);
        tokensold = tokensold.add(newtoken);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(newtoken);
        emit buy(msg.sender,newtoken);
    }

    function getprice() public view onlyInState(State.ICORunning) returns (uint256)  {
        uint256 threshold_1 = price_1.mul(100).mul(decimals);
        uint256 threshold_2 = threshold_1.add(price_2.mul(100).mul(decimals));
        uint256 threshold_3 = threshold_2.add(price_3.mul(100).mul(decimals));
        
        if (tokensold < threshold_1)
            return price_1;
        if (tokensold < threshold_2)
            return price_2;
        if (tokensold < threshold_3)
            return price_3;
        else
            return 0;
        
            

    }


    function setState(State _nextState) public onlyOwner() {
        require (currentState != State.ICOFinished);
        currentState = _nextState;

        if (currentState == State.ICOFinished ){
            uint256 allocatedToken = (teamAC.mul(100).mul(decimals)).add(tokensold);
            uint256 tokenRemain = totalsupply.sub(allocatedToken); // tokenRemain = token_not_sold + teamAC can get = totalsupply - tokensold
            balanceOf[teamACcoin] = balanceOf[teamACcoin].add(tokenRemain);
            enableTransfer = true;
        }
        
    }


    function withdrawEther() public onlyOwner() {
        if (this.balance > 0){
            teamACcoin.transfer(this.balance);
        }
    }

    function totalsupply() public view returns (uint256) {
        return (totalsupply);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(enableTransfer == true);
        return super.transfer(to,value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require (enableTransfer == true);
        return super.transferFrom(from,to,value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(enableTransfer == true);
        return super.approve(spender,value);
    }

    function() external payable {
        buytoken();
    }
}