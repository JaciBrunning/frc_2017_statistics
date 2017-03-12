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

Please note that the SQLite3 Engine Version must be >= 3.8.3 to work with Miscellaneous Data.

## Example (mid week-2):
```
=======================
      ALL MATCHES      
=======================
        Match Points:
                     total: 1451637 (182.60)
                      auto: 269245 ( 33.87)
                    teleop: 1117227 (140.53)
                      foul:  65360 (  8.22)
                    adjust:   -195 ( -0.02)

     Mobility Points:
                      auto:  97145 ( 12.22)

        Rotor Points:
                      auto: 165720 ( 20.85)
                    teleop: 599400 ( 75.40)

      Takeoff Points:
                    teleop: 507000 ( 63.77)

    Fuel High Points:
                      auto:   6226 (  0.78)
                    teleop:   7144 (  0.90)

     Fuel Low Points:
                      auto:   6226 (  0.78)
                    teleop:   7144 (  0.90)

          Foul Count:
                      foul:   1872 (  0.24)
                 tech_foul:   2240 (  0.28)

=======================
 QUALIFICATION MATCHES 
=======================
   Bonus Rank Points:
                     rotor:     22 (  0.00)
                  pressure:     17 (  0.00)

=======================
    PLAYOFF MATCHES    
=======================
        Bonus Points:
                     rotor:   2600 (  0.33)
                  pressure:    320 (  0.04)

=======================
    SCORE BREAKDOWN    
=======================
        Total Points:
               Match (auto)    :     18.5%
               Match (teleop)  :     77.0%
               Match (foul)    :      4.5%
               Bonus (rotor)   :      0.2%
               Bonus (pressure):      0.0%

         Auto Points:
                       Mobility:     36.1%
                          Rotor:     61.5%
                      Fuel High:      2.3%
                       Fuel Low:      2.3%

       Teleop Points:
                          Rotor:     53.7%
                        Takeoff:     45.4%
                      Fuel High:      0.6%
                       Fuel Low:      0.6%

=======================
   MISCELLANEOUS DATA  
=======================
    Wins due to Fuel:      110 (2.8%)
   Wins due to Fouls:      309 (7.8%)

 L Climbs > W Climbs:      222 (5.6%)
```