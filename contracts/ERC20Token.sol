// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.9;

/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;

import "./interfaces/IERC20Token.sol";

contract ERC20Token is IERC20Token {
    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    address public owner;

    uint256 internal _totalSupply;

    /// @dev send `value` token to `to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(balances[msg.sender] >= _value, "ERC20_INSUFFICIENT_BALANCE");
        require(balances[_to] + _value >= balances[_to], "UINT256_OVERFLOW");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev send `value` token to `to` from `from` on the condition it is approved by `from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(balances[_from] >= _value, "ERC20_INSUFFICIENT_BALANCE");
        require(allowed[_from][msg.sender] >= _value, "ERC20_INSUFFICIENT_ALLOWANCE");
        require(balances[_to] + _value >= balances[_to], "UINT256_OVERFLOW");

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    /// @dev `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Always true if the call has enough gas to complete execution
    function approve(address _spender, uint256 _value) external returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Query total supply of token
    /// @return Total supply of token
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @dev Query the balance of owner
    /// @param _owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    // @param _owner you need to set to the owner's address
    function setOwner(address _owner) public onlyOwner returns (bool) {
        owner = _owner;
        return true;
    }

    /// @dev Mint new tokens and increase total supply
    /// @param _spender The address to which new tokens are minted
    /// @param _value The amount of tokens to mint
    /// @return A boolean indicating the success of the mint operation
    function mint(address _spender, uint256 _value) public onlyOwner returns (bool) {
        balances[_spender] += _value;
        _totalSupply += _value;
        return true;
    }

    /// @dev Burn tokens and decrease total supply
    /// @param _spender The address from which tokens are burned
    /// @param _value The amount of tokens to burn
    /// @return A boolean indicating the success of the burn operation
    function burn(address _spender, uint256 _value) public onlyOwner returns (bool) {
        balances[_spender] -= _value;
        _totalSupply -= _value;
        return true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    string public name;
    string public symbol;
    uint256 public decimals;

    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint256 _totalSupplyAmount
    )
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _totalSupplyAmount;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }
}