pragma solidity ^0.4.24;


import "./TokenFrontend.sol";
import "./TokenStorage.sol";
import "./ERC20Lib.sol";
// import "zeppelin-solidity/contracts/token/EternalTokenStorage.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */

contract StandardController is Ownable {
    using ERC20Lib for TokenStorage;

    TokenStorage token;
    TokenFrontend frontend;

    string public name;
    string public symbol;
    uint public decimals = 18;

    // MODIFIERS
    modifier onlyFrontend() {
        if (msg.sender == address(frontend))
            _;
    }

    // either frontend or calling directly
    modifier isFront(address _caller) {
        if (msg.sender == address(frontend) || _caller == msg.sender)
            _;
    }

    // TODO: better solution?
    modifier ownerOrFrontend() {
        if (msg.sender == address(frontend) || tx.origin == owner)
            _;
    }

    // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // CONSTRUCTOR
    constructor(address _storage, uint initialSupply) internal {
        assert(_storage == 0x0 || initialSupply == 0);
        if (_storage == 0x0) {
            token = new TokenStorage();
            token.addBalance(msg.sender, initialSupply);
        } else {
            token = TokenStorage(_storage);
        }
    }

    // EXTERNAL CONSTANT
    function getFrontend() external view returns (address) {
        return address(frontend);
    }

    function getStorage() external view returns (address) {
        return address(token);
    }

    // EXTERNAL
    function setFrontend(address _address) external ownerOrFrontend { 
        frontend = TokenFrontend(_address);
        transferOwnership(_address);
    }

    // EXTERNAL ERC20
    function transfer(address to, uint value) external returns (bool ok) {
        return _transfer(msg.sender, to, value);
    }

    function transferFrom(address from, address to, uint value) 
        external
        returns (bool ok) 
    {
        return _transferFrom(msg.sender, from, to, value);
    }

    function approve(address spender, uint value) 
        external
        returns (bool ok) 
    {
        return _approve(msg.sender, spender, value);
    }

    function approveAndCall(address spender, uint value, bytes extraData) 
        external
        returns (bool ok) 
    {
        return _approveAndCall(msg.sender, spender, value, extraData);
    }

    // PUBLIC ERC20 FRONT
    function _transfer(address _caller, address _to, uint _value) 
        public
        isFront(_caller)
        returns (bool ok) 
    {
        return token.transfer(_caller, _to, _value);
    }

    function _transferFrom(address _caller, address _from, address _to, uint _value) 
        public
        isFront(_caller)
        returns (bool ok) 
    {
        return token.transferFrom(_caller, _from, _to, _value);
    }

    function _approve(address _caller, address _spender, uint _value) 
        public
        isFront(_caller)
        returns (bool ok) 
    {
        return token.approve(_caller, _spender, _value);
    }

    function _approveAndCall(address _caller, address _spender, uint _value, bytes _extraData) 
        public
        returns (bool ok) 
    {
        return token.approveAndCall(_caller, _spender, _value, _extraData);
    }

    // EXTERNAL ERC20 CONSTANT
    function totalSupply() external view returns (uint) {
        return token.getSupply();
    }

    function balanceOf(address who) external view returns (uint) {
        return token.getBalance(who);
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return token.allowance(owner, spender);
    }

}
