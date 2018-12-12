# SkatterTools
Skattered tools from Skatterbrainz



## Latest: 1812.12.02


## Overview


* A portable web console for viewing and managing AD and CM features
* Built from PowerShell to run on PoSH Server (http://www.poshserver.net)
* Open-source, Fully-Customizable
* THIS IS STILL IN DEVELOPMENT - Enjoy!
* IMPORTANT: "master" is currently "development" channel until all base features are done
  
* Check back frequently, or click the Star above to be notified of updates


## Installation / Configuration




* Download PoSHServer from: http://www.poshserver.net/ 

* Run the full installation (haven't tested with portable version yet)

* Download the SkatterTools "PoshServer" folder only / Extract somewhere
 (e.g. x:\sktools)
* Edit the "config.txt" file (specify your SCCM site server, etc.)
* Open a PowerShell console using Run as Administrator

* Type: Start-PoshServer -HomeDirectory "<path to skattertools>"

  * e.g. "Start-PoSHServer -HomeDirectory "x:\sktools"
* Open SkatterTools at http://localhost:8080/


## Test Notes



* Tested with IE 11, Chrome 70

* SQL Server 2017

* ConfigMgr 1810




## Release History


### Updates 1812.12.02 (12/12/2018)

* Installed Software
* Software Files
* Packages / Programs
* Improved page cross-links (ongoing work)
* Universal Search has been rewritten entirely
* About page shows more detail





### Updates 1812.09.15 (12/9/2018)



* AD OU Explorer
  
* (just started on it) barely there

* AD Computers / Computer:
	
* Storage (Disks)
	
* Software (Installed)
	
* Ping Computer

* AD Reports:
	
  * User last logons
	
  * Workstation last logons
	
  * Users with no-expire passwords

* AD Forest:
	
  * (just started on it) shows Forest Schema version so far

* Search:
  
  * Moved to top of sidebar (removed duplicate links)
  
  * Fixed CM search (device, user, collections (both), but not yet products)
  
  * Still a bug in the AD search items (working on it)

* API changes:
  
  * Moved code out of sktools.ps1 to /lib/sktools-xxx.ps1 files (dot-source on first load)
  
  * This is to prepare for performance tuning later, more to come

* Bug Fixes:
  
  * Collections were not showing all results correctly if the collection has no members (fixed)

* Notes:
  
  * I am aware that my code is rough and inconsistent across files.
  
  * I want to get the car driving first, then refactor the shit out of it later.
  


### Updates 1812.09.06 (12/9/2018)



* CM Device (detail) - filtering and sorting fully done

* CM Device (detail) - collections tab --> add to Collections!!! (direct rules only)

* CM Device Collection (detail) - Direct Rules tab full search linking per device

* Updated downloads and learning pages

* Updated help page

* NOTE: Save your config.ps1 file first! You may want to use it for...



## Updates 1812.08.04 (12/8/2018)



* NOTE: Save your config.ps1 file first! You may want to use it for...

* Moved functions out of config.ps1 to sktools.ps1

* Moved skattertools variables out of config.ps1 to config.txt

* Updates to CM collections, CM users, AD users, added missing license page



## Disclaimers



* This is BETA BETA BETA so do NOT use this in a production environment

* This project is not affiliated with PoSH Server in any way

* This project is FREE and open source.  Do not pay anyone for using this
