A Comprehensive Guide to Creating a Decentralized Social Media Platform on zkSync 

## Table of Contents:

1. [Introduction](#introduction)
2. [Project Setup](#project-setup)
3. [Smart Contract Design](#smart-contract-design)
4. [User Registration](#user-registration)
5. [Creating Posts](#creating-posts)
6. [Interacting with Posts](#interacting-with-posts)
7. [Viewing Posts and Comments](#viewing-posts-and-comments)
8. [Complete Code](#complete-code)
9. [Writing Tests](#writing-tests)
10. [Compiling and deploying](#compiling-and-deploying)

## Prerequisites
- Basic understanding of Solidity programming language
- zkSync testnet faucet [faucet](https://docs.zksync.io/build/tooling/network-faucets.html)
- WSL2 (for Windows user to run zkSync nodes)


## Introduction
In this article, you will learn how to develop a decentralized social media platform. Leveraging the power of the most powerful smart contracts language, Solidity, we will explore the process of developing and deploying this blockchain-based social media ecosystem. 

Throughout this guide, we will give a deep dive into the fundamental aspects of writing smart contracts. We will handle user registration, post creation, interaction mechanisms such as liking and commenting, and finally, setting up for deployment on the zkSync sepolia testnet network.

## Project Setup

This project will be scaffolded with [zkSync cli](https://docs.zksync.io/build/tooling/zksync-cli/commands/create.html#contracts) for easy set up.

Head over to your command prompt or terminal and run the code below:

`npx zksync-cli create`

You will be prompted to enter your project's name. You can enter your desired project's name, in our case `sociaDapp`.

Next, you will be prompted to select the type of project. Select `Contracts` and proceed. 

After that, select `Ethers V6` as ethereum framework and select `Hardhat + Solidity` as Template.

You will be prompted to enter `private key` or set it later. For this tutorial,leave it blank and continue.

Finally, select your desired package manage to begin installations.

This will create a new zkSync era project named `socialDapp`. Some examples contracts,tests and deployment will be generated by default. However, for the purposes of this tutorial, we don't need the example contracts related files. So, proceed by removing all the files inside the /contracts , /test folders manually or by running the following commands:

`cd socialDapp `
`rm -rf ./contracts/*`
`rm -rf ./test/*`

Finally, create a file named `SocialMedia.sol` inside your `contracts` folder.

## Smart Contract Design

 ### Data structures (User, Post, Comment)

 ```solidity
    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.0;

     contract SocialMedia {

      address public owner;
      struct User {
          string username;
          address userAddress;
          bool isRegistered;
      }
  
      mapping(address => User) public users;
  
      struct Post {
          address author;
          string content;
          uint256 timestamp;
          uint256 likes;
          uint256 commentsCount;
      }
  
      struct Comment {
          address commenter;
          string content;
          uint256 timestamp;
      }
  
      mapping(uint256 => mapping(uint256 => Comment)) public postComments;
      mapping(uint256 => uint256) public postCommentsCount;
  
      Post[] public posts;
}
```
  The `SocialMedia` contract facilitates interactions on the decentralized social media platform. It defines the structure for a social media platform where users can register, make posts, and comment on posts.
  It provides functionality to store user information, posts, and comments, and retrieve them as needed. Additionally, it includes variables and mappings to keep track of post comments and their counts.
  
  The `owner` : An address variable to store the address of the owner of the contract.
  
  The `User` struct represents registered users on the platform, containing fields for username, address, and registration status.
  
  The `Post` struct stores information about each post, including the author's address, content, timestamp, number of likes, and an array of comments.
  It contains fields such as author (address of the author), content (the actual content of the post), timestamp (time when the post was made), likes (number of likes on the post), and commentsCount (number of comments on the post).
  
  The `Comment` struct represents individual comments, containing fields for the commenter's address, content, and timestamp. It contains fields like commenter (address of the commenter), content (the actual content of the comment), and timestamp (time when the comment was made).
  
  The `postComments` mapping is used to store comments for each post where the first key is the post's index, and the second key is the comment's index.
  
  The `postCommentsCount` mapping keeps track of the number of comments for each post.
  
  The `posts` array stores instances of the Post struct, representing individual posts on the decentralized social media platform.


  ### Events and modifiers

```solidity
    event UserRegistered(address indexed userAddress, string username);
```
This event is emitted when a new user is successfully registered on the platform. It returns the registered user's address (`userAddress`) and the chosen username (`username`).

```solidity
    event PostCreated(address indexed author, string content, uint256 timestamp);
```
This event is emitted when a new post is created by a user on the platform. It returns the address of the post's author (`author`), the content of the post (`content`), and the timestamp of creation (`timestamp`).

```solidity
    event PostLiked(address indexed liker, uint256 indexed postId);
```
This event is emitted when a user likes a post on the platform. It provides visibility into user engagement and returns
the address of the user who liked the post (`liker`) and the index of the liked post (`postId`).

```solidity
    event CommentAdded(address indexed commenter, uint256 indexed postId, string content, uint256 timestamp);
```
This event is emitted when a user adds a comment to a post on the platform and returns the address of the commenter (commenter), the index of the post being commented on (postId), the content of the comment (content), and the timestamp of comment creation (`timestamp`).

```solidity
    modifier onlyRegisteredUser() {
        require(users[msg.sender].isRegistered, "User is not registered");
        _;
    }
```
This modifier restricts access to functions to only registered users on the platform and ensures that only users who have completed the registration process can perform certain actions, such as creating posts or adding comments.
If an unregistered user attempts to call a function with this modifier, the transaction will be reverted with an error message indicating that the user is not registered.

```solidity
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
```
This modifier restricts access to functions to the contract owner. It grants special privileges to the contract owner, such as administrative functions or contract upgrades.
If a caller who is not the contract owner attempts to call a function with this modifier, the transaction will be reverted with an error message indicating that only the owner can call the function.

```solidity
    constructor() {
        owner = msg.sender;
    }
```
Constructor is a special function that is executed only once during contract deployment. In this contract, the constructor initializes the contract owner to the address of the deployer (`msg.sender`).

## User Registration
   ### Implementation of user registration functionality

   ```solidity
      function registerUser(string memory _username) external {
        require(!users[msg.sender].isRegistered, "User is already registered");
        require(bytes(_username).length > 0, "Username should not be empty");

        users[msg.sender] = User({
            username: _username,
            userAddress: msg.sender,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _username);
    }
   ```

   This function is declared with the `registerUser` name, taking a single argument `_username` of type string which represents the username of the user registering. It is declared as `external`, meaning it can be called from outside the contract. It ensures that users can register on the platform with a unique username and provides transparency by emitting an event upon successful registration. 
   Additionally, it enforces security by verifying that the user is not already registered and that the provided username is not empty.
   
   - `require(!users[msg.sender].isRegistered, "User is already registered")` : This line ensures that the user calling the function (msg.sender) is not already 
    registered. It checks if the `isRegistered` flag in the users mapping for the caller's address is false. If it's true, meaning the user is already registered, 
    it will revert the transaction with the error message "User is already registered".

   - `require(bytes(_username).length > 0, "Username should not be empty")` : This line ensures that the `_username` parameter passed to the function is not empty. It checks if the length of the byte representation of the username is greater than 0. If it's not, it will revert the transaction with the error message "Username should not be empty".

   - `users[msg.sender] = User({username: _username, userAddress: msg.sender, isRegistered: true})` : If the input validation passes, a new User struct is created and stored in the users mapping with the caller's address (msg.sender) as the key. The username field of the struct is set to the `_username` parameter passed to the function, the `userAddress` is set to `msg.sender`, and the `isRegistered` flag is set to true, indicating that the user is now registered. 

  - `emit UserRegistered(msg.sender, _username)` : After successfully registering the user, an event `UserRegistered` is emitted. This allows external parties to listen for this event and take appropriate actions, such as updating UIs or performing additional logic.

## Creating Posts
   ### Implementations of creating posts

   ```solidity
        function createPost(string memory _content) external onlyRegisteredUser {
        require(bytes(_content).length > 0, "Content should not be empty");

        posts.push(Post({
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0,
            commentsCount: 0
        }));

        emit PostCreated(msg.sender, _content, block.timestamp);
    }
   ```
   ### Description of the `createPost` function
   This function ensures that registered users can create posts with non-empty content and provides transparency by emitting an event upon successful post creation. Additionally, it enforces security by restricting access to registered users only.

  - `onlyRegisteredUser`: This modifier ensures that only registered users can create posts. It's assumed to be defined elsewhere in the contract.
  - `require(bytes(_content).length > 0, "Content should not be empty")`: Ensures that the content of the post is not empty. It checks the length of the 
  - `_content` string and requires it to be greater than 0 bytes. 
  - `posts.push(...)`: Adds a new post  to the `posts` array. It creates a new `Post` struct with the following parameters:
    - `author`: The address of the user creating the post (`msg.sender`).
    - `content`: The content of the post, provided as input to the function (`_content`).
    - `timestamp`: The current block timestamp, indicating when the post was created (`block.timestamp`).
    - `likes`: Initialized to 0, indicating the number of likes on the post.
    - `commentsCount`: Initialized to 0, indicating the number of comments on the post.
  - `emit PostCreated(msg.sender, _content, block.timestamp)`: Emits an event `PostCreated`, indicating that a new post has been created. It includes the address of the author (`msg.sender`), the content of the post (`_content`), and the timestamp when the post was created (`block.timestamp`).

## Interacting with Posts
  ### Liking posts
  ```solidity
 function likePost(uint256 _postId) external onlyRegisteredUser {
        require(_postId < posts.length, "Post does not exist");

        Post storage post = posts[_postId];
        post.likes++;

        emit PostLiked(msg.sender, _postId);
    }
  ```
  ### Explanation of `likePost`
  This function ensures that registered users can like posts and emit an event upon successful post like. Also, 
  it enforces security by restricting access to registered users only and ensuring that the specified post exists before allowing a like action.

  - `onlyRegisteredUser`: This modifier ensures that only registered users can like posts. It's assumed to be defined elsewhere in the contract.  
  - `require(_postId < posts.length, "Post does not exist")`: Checks if the provided `_postId` is within the range of existing posts. If the post does not exist  
  (i.e., the `_postId` is out of range), it reverts the transaction with an error message.
  - `Post storage post = posts[_postId];`: Retrieves the post from the `posts` array based on the provided `_postId` and stores it in a `Post` storage variable named `post`.
  - `post.likes++;`: Increments the `likes` counter of the liked post by one.
  - `emit PostLiked(msg.sender, _postId)`: Emits an event `PostLiked`, indicating that the user (`msg.sender`) has liked the post specified by `_postId`.
  
  ### Adding comments to posts
  ```solidity
     function addComment(uint256 _postId, string memory _content) external onlyRegisteredUser {
        require(_postId < posts.length, "Post does not exist");
        require(bytes(_content).length > 0, "Comment should not be empty");

        uint256 commentId = postCommentsCount[_postId];
        postComments[_postId][commentId] = Comment({
            commenter: msg.sender,
            content: _content,
            timestamp: block.timestamp
        });

        postCommentsCount[_postId]++;
        posts[_postId].commentsCount++;

        emit CommentAdded(msg.sender, _postId, _content, block.timestamp);
    }
  ```
### Explanation of `addComment` functions
  This function ensures that registered users can add comments to posts and emit an event upon successful comment addition. 
  Also, it enforces security by restricting access to registered users only and ensuring that the specified post exists before allowing a comment action.

- `onlyRegisteredUser`: This modifier ensures that only registered users can add comments. It's assumed to be defined elsewhere in the contract.
- `require(_postId < posts.length, "Post does not exist")`: Ensures that the provided `_postId` corresponds to an existing post in the `posts` array.
- `require(bytes(_content).length > 0, "Comment should not be empty")`: Ensures that the content of the comment is not empty.
- `uint256 commentId = postCommentsCount[_postId];`: Retrieves the next available comment ID for the given post.
- `postComments[_postId][commentId] = Comment({ ... });`: Adds a new comment to the `postComments` mapping for the specified post ID and comment ID. It creates a new `Comment` struct with the following parameters:
  - `commenter`: The address of the user adding the comment (`msg.sender`).
  - `content`: The content of the comment, provided as input to the function (`_content`).
  - `timestamp`: The current block timestamp, indicating when the comment was added (`block.timestamp`).
- `postCommentsCount[_postId]++;`: Increments the count of comments for the specified post ID.
- `posts[_postId].commentsCount++;`: Increments the comments count in the corresponding post struct.
- `emit CommentAdded(msg.sender, _postId, _content, block.timestamp)`: Emits an event `CommentAdded`, indicating that a new comment has been added to a post. It includes the address of the commenter (`msg.sender`), the post ID (`_postId`), the content of the comment (`_content`), and the timestamp when the comment was added (`block.timestamp`).


## Viewing Posts and Comments
  ### Retrieving post
  ```solidity
   function getPost(uint256 _postId) external view returns (
        address author,
        string memory content,
        uint256 timestamp,
        uint256 likes,
        uint256 commentsCount
    ) {
        require(_postId < posts.length, "Post does not exist");
        Post memory post = posts[_postId];
        return (post.author, post.content, post.timestamp, post.likes, post.commentsCount);
    }
  ```
### Explanation of the `getPost` function
This function provides a convenient way for users to retrieve essential information about posts on the platform. It verifies that the specified post exists before returning its information.

- `_postId`: The index of the post to retrieve from the `posts` array.
- `author`: The address of the author of the post.
- `content`: The content of the post.
- `timestamp`: The timestamp when the post was created.
- `likes`: The number of likes on the post.
- `commentsCount`: The number of comments on the post.
- `require(_postId < posts.length, "Post does not exist")`: Ensures that the provided `_postId` corresponds to an existing post in the `posts` array.
- `Post memory post = posts[_postId];`: Retrieves the post struct from the `posts` array at the specified index `_postId`.
- `return (post.author, post.content, post.timestamp, post.likes, post.commentsCount);`: Returns the attributes of the post as a tuple containing the author's address, the content of the post, the timestamp, the number of likes, and the number of comments.


### Retrieving comments
```solidity
function getComment(uint256 _postId, uint256 _commentId) external view returns (
        address commenter,
        string memory content,
        uint256 timestamp
    ) {
        require(_postId < posts.length, "Post does not exist");
        require(_commentId < postCommentsCount[_postId], "Comment does not exist");

        Comment memory comment = postComments[_postId][_commentId];
        return (comment.commenter, comment.content, comment.timestamp);
    }
```



### Explanation of the `getComment` function
This function provides an easy way for users to retrieve essential information about comments on posts. It enforces security by verifying that both the specified post and comment exist before returning the comment's information.

- `_postId`: The index of the post to which the comment belongs.
- `_commentId`: The index of the comment within the specified post.
- `commenter`: The address of the commenter.
- `content`: The content of the comment.
- `timestamp`: The timestamp when the comment was created.
- `require(_postId < posts.length, "Post does not exist")`: Ensures that the provided `_postId` corresponds to an existing post in the `posts` array.
- `require(_commentId < postCommentsCount[_postId], "Comment does not exist")`: Ensures that the provided `_commentId` corresponds to an existing comment for the given post.
- `Comment memory comment = postComments[_postId][_commentId];`: Retrieves the comment struct from the `postComments` mapping for the specified post ID and comment ID.
- `return (comment.commenter, comment.content, comment.timestamp);`: Returns the attributes of the comment as a tuple containing the commenter's address, the content of the comment, and the timestamp when it was created.


### Retrieving total posts count
```solidity
 function getPostsCount() external view returns (uint256) {
        return posts.length;
    }
```
### Explanation of `getPostsCount()` function
This function provides a simple and efficient way for users to query the total number of posts on the platform. It is useful for displaying statistics about the platform's activity and engagement.

## Complete Code

This is the complete code for this decentralized social contract.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract SocialMedia {
    address public owner;

    struct User {
        string username;
        address userAddress;
        bool isRegistered;
    }

    mapping(address => User) public users;

    struct Post {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
        uint256 commentsCount;
    }

    struct Comment {
        address commenter;
        string content;
        uint256 timestamp;
    }

    mapping(uint256 => mapping(uint256 => Comment)) public postComments;
    mapping(uint256 => uint256) public postCommentsCount;

    Post[] public posts;

    event UserRegistered(address indexed userAddress, string username);
    event PostCreated(address indexed author, string content, uint256 timestamp);
    event PostLiked(address indexed liker, uint256 indexed postId);
    event CommentAdded(address indexed commenter, uint256 indexed postId, string content, uint256 timestamp);

    modifier onlyRegisteredUser() {
        require(users[msg.sender].isRegistered, "User is not registered");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(string memory _username) external {
        require(!users[msg.sender].isRegistered, "User is already registered");
        require(bytes(_username).length > 0, "Username should not be empty");

        users[msg.sender] = User({
            username: _username,
            userAddress: msg.sender,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _username);
    }

    function createPost(string memory _content) external onlyRegisteredUser {
        require(bytes(_content).length > 0, "Content should not be empty");

        posts.push(Post({
            author: msg.sender,
            content: _content,
            timestamp: block.timestamp,
            likes: 0,
            commentsCount: 0
        }));

        emit PostCreated(msg.sender, _content, block.timestamp);
    }

    function likePost(uint256 _postId) external onlyRegisteredUser {
        require(_postId < posts.length, "Post does not exist");

        Post storage post = posts[_postId];
        post.likes++;

        emit PostLiked(msg.sender, _postId);
    }

    function addComment(uint256 _postId, string memory _content) external onlyRegisteredUser {
        require(_postId < posts.length, "Post does not exist");
        require(bytes(_content).length > 0, "Comment should not be empty");

        uint256 commentId = postCommentsCount[_postId];
        postComments[_postId][commentId] = Comment({
            commenter: msg.sender,
            content: _content,
            timestamp: block.timestamp
        });

        postCommentsCount[_postId]++;
        posts[_postId].commentsCount++;

        emit CommentAdded(msg.sender, _postId, _content, block.timestamp);
    }

    function getPostsCount() external view returns (uint256) {
        return posts.length;
    }

    function getPost(uint256 _postId) external view returns (
        address author,
        string memory content,
        uint256 timestamp,
        uint256 likes,
        uint256 commentsCount
    ) {
        require(_postId < posts.length, "Post does not exist");
        Post memory post = posts[_postId];
        return (post.author, post.content, post.timestamp, post.likes, post.commentsCount);
    }

    function getComment(uint256 _postId, uint256 _commentId) external view returns (
        address commenter,
        string memory content,
        uint256 timestamp
    ) {
        require(_postId < posts.length, "Post does not exist");
        require(_commentId < postCommentsCount[_postId], "Comment does not exist");

        Comment memory comment = postComments[_postId][_commentId];
        return (comment.commenter, comment.content, comment.timestamp);
    }
}

```
## Writing Tests

Now, let's go ahead and write tests for the smart contract.

### Setting Up

Before we dive into the individual tests, let's set up the context for our `SocialDapp` contract testing.

1. **Imports and Declarations:**
   - `expect` from `chai` is used for assertions.
   - `getWallet`, `deployContract`, and `LOCAL_RICH_WALLETS` are utility functions and data for deploying contracts and managing wallets.
   - `Contract` and `EventLog` from `ethers` for interacting with Ethereum smart contracts.
   - `Wallet` from `zksync-ethers` for wallet management.

2. **Test Suite Initialization:**
   ```javascript
   describe('SocialDapp', function () {
     let socialMedia : Contract;
     let user1 : Wallet;
     let user2 : Wallet;
     let deployer : Wallet

     before(async function() {
       user1 = getWallet(LOCAL_RICH_WALLETS[1].privateKey);
       user2 = getWallet(LOCAL_RICH_WALLETS[2].privateKey);

       socialMedia = await deployContract("SocialDapp", [], { wallet: deployer , silent: true });
     });
   });
   ```
   Here, we initialize our `SocialDapp` contract and set up `user1`, `user2`, and the `deployer` wallets.

### Test: Register a User

```javascript
it('should register a user', async function () {
  const username = 'user1';

  await (socialMedia.connect(user1) as Contract).registerUser(username);
  const user = await socialMedia.users(user1.address);

  expect(user.username).to.equal(username);
  expect(user.userAddress).to.equal(user1.address);
  expect(user.isRegistered).to.be.true;

  const events = await socialMedia.queryFilter('UserRegistered');
  expect(events.length).to.equal(1);
});
```
**Explanation:**
- **Action:** User `user1` registers with the username 'user1'.
- **Assertions:** 
  - The registered user's username, address, and registration status are correctly recorded.
  - The `UserRegistered` event is emitted once.

### Test: Create a Post

```javascript
it('should create a post', async function () {
  const content = 'This is a test post';
  await (socialMedia.connect(user1) as Contract).createPost(content);
  const postsCount = await socialMedia.getPostsCount();
  expect(postsCount.toString()).to.equal('1');

  const post = await socialMedia.getPost(0);
  expect(post.author).to.equal(user1.address);
  expect(post.content).to.equal(content);
  expect(post.likes.toString()).to.equal('0');
  expect(post.commentsCount.toString()).to.equal('0');
});
```
**Explanation:**
- **Action:** `user1` creates a post with the content 'This is a test post'.
- **Assertions:**
  - The total number of posts is incremented.
  - The post's details (author, content, likes, comments count) are correctly recorded.

### Test: Like a Post

```javascript
it('should like a post', async function () {
  await (socialMedia.connect(user2) as Contract).registerUser('user2');
  await (socialMedia.connect(user2) as Contract).likePost(0);
  const post = await socialMedia.getPost(0);
  expect(post.likes.toString()).to.equal('1');
  expect(post.author).to.equal(user1.address);
});
```
**Explanation:**
- **Action:** `user2` registers and likes the first post (post ID 0).
- **Assertions:**
  - The number of likes on the post is incremented.
  - The post's author remains correct.

### Test: Add a Comment to a Post

```javascript
it('should add a comment to a post', async function () {
  const content = 'This is a test post';
  const commentContent = 'This is a test comment';

  await (socialMedia.connect(user2) as Contract).addComment(0, commentContent);

  const comment = await socialMedia.getComment(0, 0);
  expect(comment.commenter).to.equal(user2.address);
  expect(comment.content).to.equal(commentContent);

  const post = await socialMedia.getPost(0);
  expect(post.commentsCount.toString()).to.equal('1');

  const eventsQuery = await socialMedia.queryFilter('CommentAdded');    
  const eventData = eventsQuery[0] as EventLog;
  const events = eventData.args;

  expect(events[0]).to.equal(user2.address); // commenter
  expect(events[1].toString()).to.equal('0'); // post ID
  expect(events[2]).to.equal(commentContent); // comment
});
```
**Explanation:**
- **Action:** `user2` adds a comment to the first post (post ID 0).
- **Assertions:**
  - The comment's details (commenter, content) are correctly recorded.
  - The post's comment count is incremented.
  - The `CommentAdded` event is emitted with correct details.

### Test: Return Correct User Details by Address

```javascript
it('should return correct user details by address', async function () {
  const userDetails = await socialMedia.getUserByAddress(user1.address);
  expect(userDetails.userAddress).to.equal(user1.address);
  expect(userDetails.isRegistered).to.equal(true);
});
```
**Explanation:**
- **Action:** Retrieve the user details for `user1`.
- **Assertions:**
  - The returned user details (address, registration status) are correct.
 
  Finally, run `npm run test` or `yarn test` if you are using yarn.

These tests ensure that our `SocialDapp` contract functions as expected for user registration, post creation, liking, commenting, and retrieving user details.

## Compiling and deploying

To begin compiling our smart contract using `zkSync cli`, run the below command:

`npm run compile` if you are using Yarn, run `yarn compile`.

After successful compilation of your smart contracts, go ahead to deploy your contract to zkSync sepolia testnet by running the code below:

NOTE: don't forget to enter private key in the `.env` file after obtaining faucet.

Next, update `deploy.ts` inside `deploy` folder with the following code :

```typescript

import { deployContract } from "./utils";

// An example of a basic deploy script
// It will deploy a Greeter contract to selected network
// as well as verify it on Block Explorer if possible for the network
export default async function () {
  const contractArtifactName = "SocialMedia";
  const constructorArguments = [];
  await deployContract(contractArtifactName, constructorArguments);
}

```

Finally, run `npm run deploy` to deploy your smart contract to zkSync sepolia testnet which will output a result like the one below :
![4w-deploy](https://github.com/fourWayz/zksync-social-tutorial/assets/157867069/6331276d-19b8-494e-bdeb-b1345756632b)
