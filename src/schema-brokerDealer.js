const mongoose = require('mongoose');

const brokerDealerSchema = new mongoose.Schema({
    crd: {
      type: String,
      required: true,
    },
    sec: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    dba:{
      type: String,
      required: false,
    },
    address1: {
      type: String,
      required: true,
    },
    address2: {
      type: String,
      required: false,
    },
    city: {
      type: String,
      required: true,
    },
    state: {
      type: String,
      required: true,
    },
    zipcode: {
      type: String,
      required: true,
    },
    country: {
      type: String,
      required: true,
    },
    contact: {
      type: String,
      required: true,
    },
    phone: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
    },
    website: {
      type: String,
      required: true,
    },
    wallet: {
      type: String,
      required: false,
    },
    active: {
      type: Boolean,
      require: true,
      default: true,
    }
  });

module.exports = brokerDealerSchema;