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
    address: {
        type: String,
        required: true
    },
    city: {
        type: String,
        required: true
    },
    state: {
        type: String,
        required: true
    },
    zipcode: {
        type: String,
        required: true
    },
    country: {
        type: String,
        required: true
    },
    dob: {
        type: String,
        required: true
    },
    ssn: {
        type: String,
        required: true
    }
});

module.exports = userSchema;