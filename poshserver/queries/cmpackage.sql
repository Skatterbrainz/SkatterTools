select 
    PackageID,
    Name, 
    Version, 
    Manufacturer,
    PackageType,
    Case 
	    When PackageType = 0   Then 'Software Distribution Package'
	    When PackageType = 3   Then 'Driver Package'
	    When PackageType = 4   Then 'Task Sequence Package'
	    When PackageType = 5   Then 'Software Update Package'
	    When PackageType = 6   Then 'Device Settings Package'
	    When PackageType = 7   Then 'Virtual Package'
	    When PackageType = 8   Then 'Application'
	    When PackageType = 257 Then 'OS Image Package'
	    When PackageType = 258 Then 'Boot Image Package'
	    When PackageType = 259 Then 'OS Upgrade Package'
	    WHEN PackageType = 260 Then 'VHD Package'
	    End as PkgType,
    Description, 
    PkgSourcePath, 
    SourceVersion, 
    SourceDate, 
    SourceSite, 
    LastRefreshTime 
from dbo.v_Package 
