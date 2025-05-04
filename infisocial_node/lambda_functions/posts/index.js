const mongoose = require("mongoose");
const connectDB = require("/opt/utils/db/mongoConnection.js");

const AWS = require("aws-sdk");

const User = require("/opt/utils/models/user.model.js");
const Post = require("/opt/utils/models/post.model.js");
const Comment = require("/opt/utils/models/comment.model.js");

const { buildResponse } = require("/opt/utils/config/buildResponse.js");

exports.handler = async (event) => {
    await connectDB();

    try {
        const httpMethod = event.httpMethod;
        const path = event.path;

        console.log(httpMethod);
        console.log(path);

        if (httpMethod === "GET" && path === "/posts/test") {
            return {
                statusCode: 200,
                body: JSON.stringify({ message: "Post function" }),
            };
        }
        else if (httpMethod === "POST" && path === "/posts/add-post") {
            const body = JSON.parse(event.body);
            return await addPost(body);
        }
        else if (httpMethod === "GET" && path === "/posts/get-posts") {
            // const queryParams = event.queryStringParameters;
            return await getAllPosts();
        }
        else if (httpMethod === "GET" && path === "/posts/get-user-posts") {
            const queryParams = event.queryStringParameters;
            return await getUserPosts(queryParams);
        }
        else if (httpMethod === "POST" && path === "/posts/toggle-like") {
            const body = JSON.parse(event.body);
            return await togglePostLike(body);
        }
        else if (httpMethod === "POST" && path === "/posts/add-comment") {
            const body = JSON.parse(event.body);
            return await addComment(body);
        }
        else if (httpMethod === "GET" && path === "/posts") {
            const tag = event.queryStringParameters.tag;
            return await getPostsByTag(tag);
        }
        else if (httpMethod === "GET" && path === "/posts/get-comments") {
            const queryParams = event.queryStringParameters;
            return await getCommentsByPostId(queryParams);
        }
        return {
            statusCode: 404,
            body: JSON.stringify({ error: "Route not found" }),
        };
    }
    catch (error) {
        console.error("Error handling request:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: "Internal Server Error" }),
        };
    }
};

const extractHashtags = (content) => {
    if (!content) return [];
    const hashtagRegex = /#[a-zA-Z0-9_]+/g;
    const hashtags = content.match(hashtagRegex) || [];
    return [...new Set(hashtags.map(tag => tag.replace('#', '').toLowerCase()))];
};

const extractTaggedUsers = async (content) => {
    if (!content) return [];
    const tagRegex = /@[a-zA-Z0-9_]+/g;
    const tags = content.match(tagRegex) || [];
    const usernames = tags.map(tag => tag.replace('@', '').toLowerCase());

    // Find users by usernames
    const users = await User.find({ username: { $in: usernames } }).select('_id');
    return users.map(user => user._id);
};

const addPost = async (body) => {
    const { userId, content, mediaUrl, mediaType } = body;

    if (!content && !mediaUrl) {
        return buildResponse(400, { message: "Content or media is required" });
    }

    const tags = extractHashtags(content);
    console.log("Tags extracted: ", tags);
    const taggedUsers = await extractTaggedUsers(content);
    console.log("Tagged Users: ", taggedUsers);

    const newPost = new Post({
        postedBy: userId,
        content,
        mediaUrl,
        mediaType,
        tags,
        taggedUsers,
    });

    await newPost.save();

    return buildResponse(200, { message: "Post added successfully" });
};

const getAllPosts = async () => {
    try {
        const posts = await Post.find({ isActive: true })
            .populate('postedBy', 'username avatarUrl')
            .sort({ createdAt: -1 });

        if (!posts || posts.length === 0) {
            return buildResponse(404, { message: 'No posts found' });
        }

        return buildResponse(200, { posts });
    } catch (error) {
        console.error('Error fetching posts:', error);
        return buildResponse(500, { error: error.message });
    }
};

const getUserPosts = async (queryParams) => {
    const { userId } = queryParams;

    const posts = await Post.find({ postedBy: userId, isActive: true })
        .populate("postedBy", "username avatarUrl")
        .sort({ createdAt: -1 });

    if (!posts) {
        return buildResponse(404, { message: "No posts found" });
    }

    return buildResponse(200, { posts });
};

const togglePostLike = async (body) => {
    const { postId, userId } = body;

    const post = await Post.findOne({ _id: postId, isActive: true });

    if (!post) {
        return buildResponse(404, { message: "Post not found" });
    }

    const isLiked = post.likes.includes(userId);

    if (isLiked) {
        post.likes.pull(userId);
        await post.save();

        return buildResponse(200, { message: "Removed like from post successfully" });
    } else {
        post.likes.push(userId);
        await post.save();

        return buildResponse(200, { message: "Post liked successfully" });
    }
};

const addComment = async (body) => {
    try {
        const { postId, userId, content } = body;

        const post = await Post.findOne({ _id: postId, isActive: true });

        if (!post) {
            return buildResponse(404, { message: "Post not found" });
        }

        const taggedUsers = await extractTaggedUsers(content);

        const comment = new Comment({
            userId,
            postId,
            content,
            taggedUsers
        });

        const savedComment = await comment.save();

        post.comments.push(savedComment._id);
        await post.save();

        return buildResponse(200, { message: "Comment added successfully" });
    } catch (error) {
        console.log(error.message);
        return buildResponse(500, { error: error.message });
    }
};

const getCommentsByPostId = async (queryParams) => {
    try {
        const { postId } = queryParams;

        const post = await Post.findOne({ _id: postId, isActive: true });

        if (!post) {
            return buildResponse(404, { message: "Post not found" });
        }

        const comments = await Comment.find({ postId, isActive: true }).populate("userId");

        return buildResponse(200, { comments });
    } catch (error) {
        return buildResponse(500, { error: error.message });
    }
};

const getPostsByTag = async (tag) => {
    try {
        if (!tag) {
            return buildResponse(400, { message: "Tag is required" });
        }

        const posts = await Post.find({ tags: tag, isActive: true })
            .populate("postedBy", "username avatarUrl")
            .sort({ createdAt: -1 });

        if (!posts || posts.length === 0) {
            return buildResponse(404, { message: "No posts found" });
        }

        return buildResponse(200, posts);
    } catch (error) {
        return buildResponse(500, { error: error.message });
    }
};
