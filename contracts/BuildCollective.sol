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

  struct Project {
	  string name;
	  address owner;
	  uint256 companyOwner;
    bool ownerType; //0 si c'est un utilisateur, 1 si c'est une Company
	  uint256 balance;
	  address[] contributors;
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
  Company[] private Companys;
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
  }

  function createCompany(string memory name, address owner) public returns (Company memory) {
    require(users[owner].registered);
    Companys.push(Company(name, 0, owner, new address[](0)));
    emit CompanyCreated(name, owner, new address[](0), Companys[Companys.length - 1]);
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
  }

  function viewCompany(address owner) public returns (Company[] memory) {
    require(users[msg.sender].registered);
    
    uint256 nbElem = 0;
    for (uint256 i = 0; i < Companys.length; i++) {
      if (Companys[i].owner == owner) {
        nbElem++;
      }
    }
    Company[] memory result = new Company[](nbElem);
    uint256 j = 0;
    for (uint256 i = 0; i < Companys.length; i++) {
      if (Companys[i].owner == owner) {
        result[j] = Companys[i];
        j++;
      }
    }
    return result;
  }
}
