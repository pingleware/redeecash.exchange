const mongoose = require('mongoose');

const botSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'BotProvider',
        required: true,
    },
    name: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: true,
    },
    website: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        default: 0,
        required: true,
    },
});

module.exports = botSchema;