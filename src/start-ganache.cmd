rem # 1. clone https://github.com/pingleware/redeecash.exchange.data.git to a drive, e.g. to exteernal USB drive, /Volumes/My Book/projects/
rem # 2. specifiy --datavbase.dbPath=f:/project/redeecash.exchange.data/private-network
rem # 3. run this command script
ganache --wallet.defaultBalance=1000 --database.dbPath=f:/project/redeecash.exchange.data/private-network --wallet.accounts='0x5be1b3c4bbbfefc377b2df9855a4c794a88a922a672dd0b4c3b9d42a9b52a882','1000' --wallet.accounts='0x2c6583a8c7c85d1adb8edd8c6724dde66fd3de4fbe4dcab2a61d8b645fea82a2','1000'  --wallet.accounts='0x8199ecf0af7f89fd113cd4a796396179f93799d8fd6700c5c3b694061b3ff2b7','1000'  --wallet.accounts='0xce911ea3777f1bc87cbcdbad2b4415cca8dd082880240b5db749c1182e81f9a3','1000'  --wallet.accounts='0x92671a9acad83fe339c493a8ddb4aea253bf6588c29d868e6f47992891df6819','1000'  --wallet.accounts='0x3f90950da708837c5c51bd37c82284aa435e8097a1bea276a9a98b003639007d','1000'  --wallet.accounts='0x306dcb87fea6b234cfbf2b2abd6402f7417d958332f4befe77a46795dd1585db','1000'  --wallet.accounts='0xbfbf95bb7be96d1a63a47f0f5427b6912c1e37dd6ad2f01269b65b9b42123d89','1000'  --wallet.accounts='0xe38c3c5e534d1fdd99578273e8c87632751e31cf697b18958699c0fe6accf966','1000'  --wallet.accounts='0xe3842bbb108f91968ff4e2debb98f4a17ce3bdbcfaf443a68c149833d0b676bb','1000'