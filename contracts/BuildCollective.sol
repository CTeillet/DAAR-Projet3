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

  struct ResUser{
    User user;
    address addr;
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

  struct Commit{
    string link;
    address person;
    uint256 projectId;
  }

  struct ResCommit{
    Commit commit;
    uint256 index;
  }

  struct Project {
	  string name;
	  address owner;
	  uint256 companyOwner;
    bool ownerType;
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
    uint256 reward; //in eth
    bool status; //true = open, false = closed
    uint256 project;
  }

  struct ResBounty{
    Bounty bounty;
    uint256 index;
  }

  mapping(address => User) private users;
  address[] private addresses;
  Company[] private companies;
  Project[] private projects;
  Bounty[] private bounties;
  Commit[] private commits;

  event UserSignedUp(address indexed userAddress, User indexed user);
  event CompanyCreated( string name,	address owner, address[] users,	Company indexed company);
  event ProjectCreated( string name, address owner, uint256 companyOwner, address[] contributors, Project indexed project);
  event BountyCreated( string title, string description, address owner, uint256 project, uint256 reward, bool status, Bounty indexed bounty);

  function user(address userAddress) public view returns (User memory) {
	  require(users[userAddress].registered, "You must be registered");
    return users[userAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0, "Username must not be empty");
    users[msg.sender] = User(username, 0, true);
    addresses.push(msg.sender);
    emit UserSignedUp(msg.sender, users[msg.sender]);
    return  users[msg.sender];
  }

  function createCompany(string memory name, address owner) public returns (Company memory) {
    require(users[owner].registered, "You must be registered");
    companies.push(Company(name, 0, owner, new address[](0)));
    emit CompanyCreated(name, owner, new address[](0), companies[companies.length - 1]);
    return companies[companies.length - 1];
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered, "You must be registered");
    users[msg.sender].balance += amount;
    return true;
  }

  function createProject(string memory name, uint256 companyOwner, bool ownerType) public returns (Project memory) {
    require(users[msg.sender].registered, "You must be registered");
    Project memory project = Project(name, msg.sender, companyOwner, ownerType, 0, new address[](0));
    projects.push(project);
    emit ProjectCreated(name, msg.sender, companyOwner, new address[](0), projects[projects.length - 1]);
    return project;
  }

  function viewCompanies() public view returns (ResCompany[] memory) {
    require(users[msg.sender].registered, "Not connected");
    uint256 nbElem = 0;
    for (uint256 i = 0; i < companies.length; i++) {
      if (companies[i].owner == msg.sender || contains(companies[i].users) == true) {
        nbElem++;
      }
    }
    ResCompany[] memory result = new ResCompany[](nbElem);
    uint256 j = 0;
    for (uint256 i = 0; i < companies.length; i++) {
      if (companies[i].owner == msg.sender || contains(companies[i].users) == true) {
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

  function getUsers() public view returns (ResUser[] memory) {
    ResUser[] memory result = new ResUser[](addresses.length);
    for (uint256 i = 0; i < addresses.length; i++) {
      result[i] = ResUser(users[addresses[i]], addresses[i]);
    }
    return result;
  }
  
  function contains(address[] memory adds) public view returns (bool) {
    for (uint256 i = 0; i < adds.length; i++) {
      if (adds[i] == msg.sender) {
        return true;
      }
    }
    return false;
  }
  function viewProjects() public view returns (ResProject[] memory) {
    ResProject[] memory result = new ResProject[](projects.length);
    for (uint256 i = 0; i < projects.length; i++) {
      result[i] = ResProject(projects[i], i);
    }
    return result;
  }

  function getCompany(uint256 companyIndex) public view returns (Company memory) {
    require(users[msg.sender].registered, "Not user");
    require(companyIndex>=0 && companyIndex<companies.length, "Company index out of bounds");
    return companies[companyIndex];
  }

  function createBounty(string memory title, string memory description, uint256 project, uint256 reward) public returns (Bounty memory) {
    require(users[msg.sender].registered, "Not user");
    require(project>=0 && project<projects.length, "Project index out of bounds");
    require(projects[project].owner == msg.sender, "Not owner");
    require(reward > 0, "Reward must be positive");
    Bounty memory b = Bounty(title, description, msg.sender, reward, true, project);
    bounties.push(b);
    emit BountyCreated(title, description, msg.sender, project, reward, true, bounties[bounties.length - 1]);
    return b;
  }

  function getBounties(uint256 project) public view returns (ResBounty[] memory) {
    require(users[msg.sender].registered, "Not user");
    require(project>=0 && project<projects.length, "Project index out of bounds");
    uint256 nbElem = 0;
    for (uint256 i = 0; i < bounties.length; i++) {
      if (bounties[i].project == project) {
        nbElem++;
      }
    }
    ResBounty[] memory result = new ResBounty[](nbElem);
    uint256 j = 0;
    for (uint256 i = 0; i < bounties.length; i++) {
      if (bounties[i].project == project) {
        result[j] = ResBounty(bounties[i], i);
        j++;
      }
    }
    return result;
  }

  function addTokenProject(uint256 amount, uint256 projectIndex) public returns (bool) {
    require(users[msg.sender].registered, "Not user");
    require(amount > 0, "Amount must be positive");
    require(users[msg.sender].balance >= amount, "Not enough money");
    projects[projectIndex].balance += amount;
    users[msg.sender].balance -= amount;
    return true;
  } 

  function addCommit(uint256 projectIndex, string memory link) public returns(Commit memory){
    require(users[msg.sender].registered, "Not user");
    require(projectIndex>=0 && projectIndex<projects.length, "Project index out of bounds");
    require(projects[projectIndex].owner == msg.sender, "Not owner");
    Commit memory c = Commit(link, msg.sender, projectIndex);
    commits.push(c);
    if(contains(projects[projectIndex].contributors) == false){
      projects[projectIndex].contributors.push(msg.sender);
    }
    //emit CommitCreated(msg.sender, link, projectIndex, commits[commits.length - 1]);
    return c;
  }

  function getCommits(uint256 projectIndex) public view returns (ResCommit[] memory) {
    require(users[msg.sender].registered, "Not user");
    require(projectIndex>=0 && projectIndex<projects.length, "Project index out of bounds");
    uint256 nbElem = 0;
    for (uint256 i = 0; i < commits.length; i++) {
      if (commits[i].projectId == projectIndex) {
        nbElem++;
      }
    }
    ResCommit[] memory result = new ResCommit[](nbElem);
    uint256 j = 0;
    for (uint256 i = 0; i < commits.length; i++) {
      if (commits[i].projectId == projectIndex) {
        result[j] = ResCommit(commits[i], i);
        j++;
      }
    }
    return result;
  }

  function checkBounty(uint256 bountyIndex, uint256 commitIndex) public returns (bool) {
    require(users[msg.sender].registered, "Not user");
    require(bountyIndex>=0 && bountyIndex<bounties.length, "Bounty index out of bounds");
    require(bounties[bountyIndex].reward<projects[bounties[bountyIndex].project].balance, "Not enough money");
    bounties[bountyIndex].status = false;
    projects[bounties[bountyIndex].project].balance -= bounties[bountyIndex].reward;
    users[commits[commitIndex].person].balance += bounties[bountyIndex].reward;
    return true;
  }
}
