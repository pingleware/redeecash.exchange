const mongoose = require('mongoose');

// Define the transferAgent schema
const transferAgentSchema = mongoose.Schema({
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
    address1: {
        type: String,
        required: false
    },
    address1: {
      type: String,
      required: false
    },
    address2: {
      type: String,
      required: false
    },
    city: {
      type: String,
      required: false
    },
    state: {
      type: String,
      required: false
    },
    zipcode: {
      type: String,
      required: false
    },
    phoneNumber: {
      type: String,
      required: false
    },
  });
  
  module.exports = transferAgentSchema;
