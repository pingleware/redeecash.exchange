# Mongoose Database

This project uses the mongoose database. Full documentation here: [https://docs.mongodb.com](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/)

## Token Data Storage

The registered token offerings are sve in the mongoose data collection as,

```
_id: 64761fd73d0cda8cffe29ce1
name: "PRESSPAGE ENTERTAINMENT INC REG A TIER 1"
symbol: "PEIKX-A1"
description: "Regulation A Tier 1 offering"
contractAddress: "0xf07fAf1FB22eB7Ee88B701293d6C41DD951954fb"
abi: "WwoJewoJCSJpbnB1dHMiOiBbCgkJCXsKCQkJCSJpbnRlcm5hbFR5cGUiOiAic3RyaW5nIi…"
secFileNumber: "024-00000"
securityType: "REGAT1"
```

### Key Features of MongoDB

MongoDB, in recent years, has grown to become one of the most popular NoSQL databases that are used by thousands of companies worldwide. The database provides numerous features that have fueled its rapid adoption. Below listed are a few key features of MongoDB:

- **Load Balancing** : For developing corporate systems, proper load balancing remains one of the significant tasks of large-scale database management. Companies can drastically improve performance by efficiently distributing innumerable client requests among multiple servers. A key feature of MongoDB is that it supports large-scale load balancing to help its customers churn out the best possible performance. Users can enjoy the benefits of the best available concurrency control and locking mechanisms that maintain data consistency. MongoDB can handle several concurrent read and write requests for the same data.
- **Ad Hoc Queries**: An ad hoc query is a one-time command that relies on the value of a variable. Depending on the variables in question, the outcome of an ad hoc query may alter each time it is run. MongoDB comes with out-of-the-box support for field queries, range queries, and regular expression searches. The platform uses MongoDB Query Language and also indexes BSON files to cater to ad hoc queries
- **Better Data Availability**: MongoDB provides unmatched data availability as it provides multiple servers for disaster recovery and backup. All write actions are accepted by a primary server or node, replicating the data among secondary servers in MongoDB. It is a very effective feature that exponentially increases the reliability of MongoDB.
- **Better Performance**: MongoDB is an open-source database that offers unmatched scalability and performance to its users. MongoDB’s replication and indexing capabilities play a vital role in providing the best possible performance to its users. MongoDB also provides a database profiler, which can be used to collect data from every task that helps users analyze queries and operations.

## Installing on a Mac M1

See https://stackoverflow.com/questions/65357744/how-to-install-mongodb-on-apple-m1-chip

1. Install homebrew from [https://brew.sh/](https://brew.sh/)
2. Install xcode command line using
   *`xcode-select --install`*
3. Now to install mongodb use
   *`brew tap mongodb/brew`*
   *`brew install mongodb-community@6.0`*
4. To check if mongodb has been installed use
   *`mongod --version`*
5. to start mongoDB as macOS service use
   *`brew services start mongodb-community@6.0`*
   and to stop mongoDB to run as a background service use
   *`brew services stop mongodb-community@6.0`*
   Or, if you don't want/need a background service you can just run:
   *`mongod --config /opt/homebrew/etc/mongod.conf`*
6. To run mongodb commands, open a new table and run
   *`mongosh`*
7. To check your databases run
   *`show dbs`*

## Installing on Linux

Full documentation at https://www.mongodb.com/docs/manual/administration/install-on-linux/

1. sudo apt-get install gnupg
2. curl -fsSL https://pgp.mongodb.com/server-6.0.asc |
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg
   --dearmor
3. for 20.04, echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
4. sudo apt-get update
5. sudo apt-get install -y mongodb-org

## Installing on Windows

Full documentation at https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-windows/

# GUI for Mongoose

Recommended is Compass at https://www.mongodb.com/try/download/shell

# Additional Topics

- CMS for Mongoose (https://www.mongodb.com/scale/mongodb-cms)
- Clusters (aka replication in MySQL, apparent;y better?) (https://www.mongodb.com/basics/clusters)
- Mongoose for Wordpress (https://hevodata.com/learn/wordpress-mongodb/)
