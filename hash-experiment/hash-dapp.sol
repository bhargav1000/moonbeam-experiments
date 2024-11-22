// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

interface JProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (UserProfile memory);
}

contract Jobby is Ownable {
    uint16 constant MAX_POST_LENGTH = 100;

    struct Post {
        uint256 id;
        address author;
        string post;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Post[] ) public posts;
    JProfile profileContract;

    event PostCreated(uint256 id, address author, string post, uint256 timestamp);
    event PostLiked(address liker, address postAuthor, uint256 postId, uint256 newLikeCount);
    event PostUnliked(address unliker, address postAuthor, uint256 postId, uint256 newLikeCount);

    modifier onlyRegistered() {
        JProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0, "USER NOT REGISTERED");
        _;
    }

    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = JProfile(_profileContract);
    }

    
    function createPost(string memory _post) public onlyRegistered {
        require(bytes(_post).length <= MAX_POST_LENGTH, "Post is too long!");

        Post memory newPost = Post({
            id: posts[msg.sender].length,
            author: msg.sender,
            post: _post,
            timestamp: block.timestamp,
            likes: 0
        });

        posts[msg.sender].push(newPost);

        emit PostCreated(newPost.id, newPost.author, newPost.post, newPost.timestamp);
    }

    mapping(address => uint256) public totalLikes;
    
    function likePost(address author, uint256 id) external onlyRegistered {
        posts[author][id].likes++;
        totalLikes[author]++;
        emit PostLiked(msg.sender, author, id, posts[author][id].likes);
    }

    function unlikePost(address author, uint256 id) external onlyRegistered {
        require(posts[author][id].likes > 0, "POST HAS NO LIKES");
        posts[author][id].likes--;
        totalLikes[author]--;
        emit PostUnliked(msg.sender, author, id, posts[author][id].likes);
    }

    
    function getTotalLikes(address _author) external view returns(uint) {
        return totalLikes[_author];
    }

    function getPost(uint _i) public view returns(Post memory) {
        return posts[msg.sender][_i];
    }

    function getAllPosts(address _owner) public view returns(Post[] memory) {
        return posts[_owner];
    }






    


}