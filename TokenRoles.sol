//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

abstract contract TokenRoles is ERC20, Ownable{
    
    address[] public minters;
    address[] public admins;
    address[] public jail;

    modifier isMinter(){
        require(isInArray(minters, msg.sender), "Caller is not a Minter");
        _;
    }

    modifier isAdmin(){
        require(isInArray(admins, msg.sender), "Caller is not an Admin");
        _;
    }

    constructor() public {
        minters.push(owner());
        admins.push(owner());
    }

    function isInArray(address[] memory array, address item) private pure returns (bool){
        bool isIn = false;
        for(uint256 i=0; i < array.length; i++){
            if(item == array[i]) isIn = true;
        }
        return isIn;
    }

    function getIndexOf(address item) private view returns (uint256){
        for(uint256 i=0; i < minters.length; i++){
            if(minters[i] == item) return i;
        }
    }

    // MINTERS

    function addMinter(address minter) public onlyOwner {
        require(!isInArray(minters, minter));
        minters.push(minter);
    }

    function removeMinter(address minter) public onlyOwner {
        require(isInArray(minters, minter));
        delete minters[getIndexOf(minter)];
    }

    function getMinters() public view returns (address[] memory){
        return minters;
    }

    function mint(address to, uint256 amount) public isMinter {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public isMinter {
        _burn(from, amount);
    }

    // ADMINS

    function addAdmin(address admin) public onlyOwner {
        require(!isInArray(admins, admin));
        admins.push(admin);
    }

    function removeAdmin(address admin) public onlyOwner {
        require(isInArray(admins, admin));
        delete admins[getIndexOf(admin)];
    }

    function getAdmins() public view returns (address[] memory){
        return admins;
    }

    function lockTokens(address target) public isAdmin {
        require(!isInArray(admins, target) && !isInArray(minters, target) && !(target == owner()));
        jail.push(target);
    }

    function unlockTokens(address target) public isAdmin {
        require(isInArray(jail, target));
        delete jail[getIndexOf(target)];
    }

    function getJailedAccounts() public view returns (address[] memory){
        return jail;
    }

    function tokenIsInJail(address user) internal view returns (bool) {
        bool isIn = false;
        for(uint256 i=0; i < jail.length; i++){
            if(user == jail[i]) isIn = true;
        }
        return isIn;
    }
}