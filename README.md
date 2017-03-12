# frc_2017_statistics
FRC 2017 "Steamworks" season statistics tracker

First, install the following ruby gems using `gem install <gem>`

```
sqlite3
json
```

Run `ruby fetch.rb` to generate the database. 
You may use `ruby --purge-db --purge-cache` in order to completely clean the database and grab new data. See `fetch.rb` for more options.

Run `ruby analyse.rb` to analyse the results present in the database.