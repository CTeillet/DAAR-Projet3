pragma solidity >=0.5.8 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
	  string username;
	  uint256 balance;
	  bool registered;
  }

  struct Enterprise {
	  string name;
	  uint256 balance;
	  address owner;
	  adress[] users;
  }

  struct Project {
	  string name;
	  address owner;
	  uint32 companyOwner;
    bool ownerType;
	  uint256 balance;
	  adress[] contributors;
  }

  struct Bounty {
    string title;
    string description;
    address owner;
    uint32 project;
    uint256 reward;
    uint256 deadline;
    uint256 status;
  }

  mapping(address => User) private users;
  Enterprise[] private enterprises;
  Project[] private projects;

  event UserSignedUp(address indexed userAddress, User indexed user);
  event EnterpriseCreated( string name,	address owner, address[] users,	Enterprise indexed enterprise);
  event ProjectCreated( string name, address owner, string companyOwner, address[] contributors, Project indexed project);
  event BountyCreated( string title, string description, address owner, uint32 project, uint256 reward, uint256 deadline, uint256 status, Bounty indexed bounty);

  function user(address userAddress) public view returns (User memory) {
	  return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0);
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
  }

  function createEnterprise(string memory name, address owner) public returns (Enterprise memory) {
    require(users[owner].registered);
    enterprises.push(Enterprise(name, 0, owner, []));
    emit EnterpriseCreated(name, owner, [], enterprises[enterprises.length - 1]);
  }

  function addBalanceUser(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered);
    users[msg.sender].balance += amount;
    return true;
  }

  function createProject(string memory name, address owner, string memory companyOwner) public returns (Project memory) {
    require(users[msg.sender].registered);
    require(users[msg.sender].username == companyOwner);
    projects.push(Project(name, owner, companyOwner, 0, []));
    emit ProjectCreated(name, owner, companyOwner, [], projects[projects.length - 1]);
  }
}
