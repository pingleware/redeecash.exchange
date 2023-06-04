const mongoose = require('mongoose');

// Define the order schema
const orderSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    tokenSymbol: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['Buy', 'Sell'],
      required: true,
    },
    volume: {
      type: Number,
      required: true,
    },
    price: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ['Pending', 'Completed', 'Cancelled'],
      default: 'Pending',
    },
});

module.exports = orderSchema;