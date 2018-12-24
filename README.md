# SkatterTools
Skattered tools from Skatterbrainz



## Latest: 1812.23.01


## Overview


* A portable web console for viewing and managing AD and CM features
* Built from PowerShell to run on PoSH Server (http://www.poshserver.net)
  * (similar capability to how Microsoft Windows Admin Center works / local web app)
* Open-source, Fully-Customizable
* THIS IS STILL IN DEVELOPMENT - Enjoy!
* IMPORTANT: "master" is currently "development" channel until all base features are done
* Check back frequently, or click "watch" above to be notified of updates

## Installation / Configuration
  * Download PoSHServer from: http://www.poshserver.net/ 
  * Run the full installation (haven't tested with portable version yet)
  * Download the SkatterTools "PoshServer" folder only / Extract somewhere (e.g. x:\sktools)
  * Edit the "config.txt" file (specify your SCCM site server, etc.)
  * Open a PowerShell console using Run as Administrator
  * Type: Start-PoshServer -HomeDirectory "<path to skattertools>"
  * e.g. "Start-PoSHServer -HomeDirectory "x:\sktools"
  * Open SkatterTools at http://localhost:8080/


## Test Notes
   
   * Tested with IE 11, Chrome 70
   * SQL Server 2016, 2017
   * ConfigMgr 1806, 1810, 1811

## Release History
   ### 1812.23.01
   * added site component status report
   * fixed a bug with device collections
   * fixed a but with add device to collection
   * still need to work on the add user to user collection code
   * started testing WMI vs SQL as an alt means for fetching data
   
   ### 1812.22.01
   * I forgot what happened with that one
   
   ### 1812.17.01
   * AD domain and AD forest pages
   * Search results bugfix (ad users)
   * AD OU explorer object links added
   
   ### 1812.15.01
   * Where was I?  Oh yeah.
   * Just fire it up and see.
   * AD user/group add/remove tools are done
   * AD explorer seems to be working
   * CM AD forest discovery
   * Search seems to be working
   * My brain seems to be working
   
   ### 1812.14.01
   * Shit man, my brain is melting, I need a vacation
   * AD sidebar is done, CM Software sidebar is done, so is CM Assets
   * my brain is about done
   * Site boundary groups and boundaries
   * Site Certificates
   * Site Status
   * AD OU Explorer updated (still working on it)
   
   ### 1812.12.02 (12/12/2018)
   * Installed Software
   * Software Files
   * Packages / Programs
   * Improved page cross-links (ongoing work)
   * Universal Search has been rewritten entirely
   * About page shows more detail

   ### 1812.09.15 (12/9/2018)
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

   ### 1812.09.06 (12/9/2018)
   * CM Device (detail) - filtering and sorting fully done
   * CM Device (detail) - collections tab --> add to Collections!!! (direct rules only)
   * CM Device Collection (detail) - Direct Rules tab full search linking per device
   * Updated downloads and learning pages
   * Updated help page
   * NOTE: Save your config.ps1 file first! You may want to use it for...

   ### 1812.08.04 (12/8/2018)
   * NOTE: Save your config.ps1 file first! You may want to use it for...
   * Moved functions out of config.ps1 to sktools.ps1
   * Moved skattertools variables out of config.ps1 to config.txt
   * Updates to CM collections, CM users, AD users, added missing license page

## Disclaimers
   * This is BETA BETA BETA so do NOT use this in a production environment
   * This project is not affiliated with PoSH Server in any way
   * This project is FREE and open source.  Do not pay anyone for using this
