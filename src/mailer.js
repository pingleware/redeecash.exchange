"use strict"

function SendEMail(sender,recipient,subject,message,callback) {
    try {
        var content = base64_encode(JSON.stringify(message.html));
        var location;
        var smtp_port = 25;

        const dns = require('dns');
        const domain = recipient.split('@')[1]; 
        smtp_port = 587;

        dns.resolve(domain, 'MX', function(err, addresses) {
            if (err) {
                err.date = new Date().toISOString();
                console.log('Error in DNS resolve %s',err);
                location = 'outbox';
                var info = {
                    sender: sender,
                    recipient: recipient,
                    subject: subject,
                    content: content,
                    date: new Date().toISOString()
                };

                var envelope = base64_encode(JSON.stringify(info));

                callback({status: false, message: err, location: location, domain: sender.split('@')[1], info: info, content: info.content, envelope: envelope});
            } else if (addresses && addresses.length > 0) {      
                const toExchange = addresses[0].exchange;
    
                const nodemailer = require('nodemailer');
                const transporter = nodemailer.createTransport({
                    port: smtp_port,
                    host: toExchange,
                });
    
                console.log('transporter sendMail [654]');
                transporter.sendMail(message, function(err, info){
                    console.log([err,info]);
                    //info.subject = subject;
                    var date = new Date().toISOString();
   
                    var envelope = base64_encode(JSON.stringify(info));
    
                    if (err) {
                        console.log('Error %s',err);
                        callback({status: false, message: err, location: location, domain: sender.split('@')[1], date:new Date().toISOString(), info: info, content: content, envelope: envelope});
                    } else {
                        //var msgId = info.messageId.split('@')[0].substring(1);
                        console.log([message.html,content]);
                        callback({status: true, location: location, subject: subject, domain: sender.split('@')[1], date: date, info: info, content:content, envelope: envelope});
                    }
                });
            }
        });        
    } catch(error) {
        callback({status: false, message: error, location: location, domain: domain, info: info, content:content, envelope: envelope})
    }
}

/**
 * 
 * @param {object} sender {from: email, fromName: full name}
 * @param {object} recipient {to: email, toName: full name}
 * @param {string} subject 
 * @param {string} message 
 */
async function send(sender, recipient, subject, message) {

    console.log("entering send...");
    try {
        var message = {
            from: sender.fromName + ' <' + sender.from + '>',
            to: recipient.toName + ' <' + recipient.to + '>',
            subject: subject,
            text: message,
            html: `<html>${message}</html>`,
            headers: {
                'Sent-By':'REDEECASH EXCHANGE (https://github.com/pingleware/redeecash.exchange)',
                'expires': new Date().toISOString()
            }
        };

 
        console.log(message);


        SendEMail(sender,recipient,subject,message,function(results){
            return {status: true, results: results};
        });
    } catch(error) {
        return {status: false, error: error};
    } 
}

module.exports = send