const userSchema = require('./schema-user');
const transferAgentSchema  = require('./schema-transferAgent');
const tokenSchema = require('./schema-token');
const supportTicketSchema = require('./schema-supportTicket');
const orderSchema = require('./schema-order');
const catSchema = require('./schema-cat');
const firmSchema = require('./schema-firm');
const brokerDealerSchema = require('./schema-brokerDealer');


module.exports = {
    userSchema,
    transferAgentSchema,
    tokenSchema,
    supportTicketSchema,
    orderSchema,
    catSchema,
    firmSchema,
    brokerDealerSchema  
}