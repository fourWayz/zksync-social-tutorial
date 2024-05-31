// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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
