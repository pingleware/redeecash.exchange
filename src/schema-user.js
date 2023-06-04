const mongoose = require('mongoose');

// Define the user schema
const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    wallet: {
        type: String,
        required: true
    },
    tokenBalance: {
        type: Number,
        default: 0,
    },
    kycData: {
        type: String,
        default: '',
    },
});

module.exports = userSchema;