const mongoose = require('mongoose');

// Define the token schema
const tokenSchema = new mongoose.Schema({
    firmId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    symbol: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    abi: {
      type: String,
      required: true,
    },
    contractAddress: {
      type: String,
      required: true,
      unique: true,
    },
    orderBookAddress: {
      type: String,
      required: true,
      unique: true,
    },
    secFileNumber: {
      type: String,
      required: true
    },
    securityType: {
      type: String,
      required: true
    }
});

module.exports = tokenSchema;
