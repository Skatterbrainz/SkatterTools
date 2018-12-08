# SkatterTools
Skattered tools from Skatterbrainz

## Latest: 1812.08.04 (12/8/2018)

### Updates

* NOTE: Save your config.ps1 file first! You may want to use it for...
* Moved functions out of config.ps1 to sktools.ps1
* Moved skattertools variables out of config.ps1 to config.txt
* Updates to CM collections, CM users, AD users, added missing license page

## Overview

* Rewritten for PoSHServer (micro web server based on PowerShell)
* Download PoSHServer from: http://www.poshserver.net/ 
* Run the full installation (haven't tested with portable version yet)
* Download the SkatterTools "PoshServer" folder only / Extract somewhere
* Edit the "config.ps1" file to specify your ConfigMgr site DB server and site code
* Open PowerShell console using Run as Administrator
* Type: Start-PoshServer -HomeDirectory "<path to skattertools>"
* Open SkatterTools at http://localhost:8080/index.htm
* THIS IS STILL IN DEVELOPMENT - Enjoy!
  
## Test Notes

* Tested with IE 11, Chrome 70
* SQL Server 2017
* ConfigMgr 1810

## Disclaimers

* This is BETA BETA BETA so do NOT use this in a production environment
* This project is not affiliated with PoSH Server in any way
* This project is FREE and open source.  Do not pay anyone for using this
