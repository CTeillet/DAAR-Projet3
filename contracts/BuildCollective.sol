// SPDX-License-Identifier: MIT
pragma solidity >=0.5.8 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
	  string username;
	  uint256 balance;
	  bool registered;
  }

  struct Company {
	  string name;
	  uint256 balance;
	  address owner;
	  address[] users;
  }

  struct ResCompany{
    Company company;
    uint256 index;
  }

  struct Project {
	  string name;
	  address owner;
	  uint256 companyOwner;
    bool ownerType; //0 si c'est un utilisateur, 1 si c'est une Company
	  uint256 balance;
	  address[] contributors;
  }

  struct ResProject{
    Project project;
    uint256 index;
  }

  struct Bounty {
    string title;
    string description;
    address owner;
    uint256 project;
    uint256 reward;
    bool status; //ouvert fermé
  }

  mapping(address => User) private users;
  Company[] private companies;
  Project[] private projects;

  event UserSignedUp(address indexed userAddress, User indexed user);
  event CompanyCreated( string name,	address owner, address[] users,	Company indexed company);
  event ProjectCreated( string name, address owner, uint256 companyOwner, address[] contributors, Project indexed project);
  event BountyCreated( string title, string description, address owner, uint32 project, uint256 reward, uint256 deadline, uint256 status, Bounty indexed bounty);

  function user(address userAddress) public view returns (User memory) {
	  return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return  users[msg.sender];
  }

  function createCompany(string memory name, address owner) public returns (Company memory) {
    require(users[owner].registered);
    companies.push(Company(name, 0, owner, new address[](0)));
    emit CompanyCreated(name, owner, new address[](0), companies[companies.length - 1]);
    return companies[companies.length - 1];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  function createProject(string memory name, address owner, uint32 companyOwner, bool ownerType) public returns (Project memory) {
    require(users[msg.sender].registered);
    //require(users[msg.sender].username == companyOwner);
    projects.push(Project(name, owner, companyOwner, ownerType, 0, new address[](0)));
    emit ProjectCreated(name, owner, companyOwner, new address[](0), projects[projects.length - 1]);
    return projects[projects.length - 1];
  }

  function viewCompanies(address owner) public view returns (ResCompany[] memory) {
    require(users[msg.sender].registered);
    uint256 nbElem = 0;
    for (uint256 i = 0; i < companies.length; i++) {
      if (companies[i].owner == owner) {
        nbElem++;
      }
    }
    ResCompany[] memory result = new ResCompany[](nbElem);
    uint256 j = 0;
    for (uint256 i = 0; i < companies.length; i++) {
      if (companies[i].owner == owner) {
        result[j] = ResCompany(companies[i], i);
        j++;
      }
    }
    return result;
  }

  function addUserCompany(address userAddress, uint256 companyIndex) public returns (bool) {
    require(users[msg.sender].registered, "Not registered");
    require(msg.sender == companies[companyIndex].owner, "Not owner");
    require(users[userAddress].registered, "User not registered");
    companies[companyIndex].users.push(userAddress);
    return true;
  }

  function addTokenCompany(uint256 amount, uint256 companyIndex) public returns (bool) {
    require(users[msg.sender].registered, "Not user");
    require(msg.sender == companies[companyIndex].owner, "Not owner");
    require(amount > 0, "Amount must be positive");
    require(users[msg.sender].balance >= amount, "Not enough money");
    companies[companyIndex].balance += amount;
    users[msg.sender].balance -= amount;
    return true;
  }
  

}
