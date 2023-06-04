const mongoose = require('mongoose');

// Consolidated Audit Trail schema
const catSchema = new mongoose.Schema({
    senderIMID: {
      type: String,
      required: true,
    },
    routedOrderID: {
      type: String,
      required: true,
    },
    symbol: {
      type: String,
      required: true,
    },
    eventTimestamp: {
      type: String,
      required: true,
    },
    session: {
      type: String,
      required: true,
    },
  });

module.exports = catSchema;