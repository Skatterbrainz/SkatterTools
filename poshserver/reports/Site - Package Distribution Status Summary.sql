SELECT 
	dbo.v_ContDistStatSummary.PkgID, 
	dbo.v_Package.Name AS PackageName, 
	dbo.v_ContDistStatSummary.LastStatusTime as [LastStatus], 
	dbo.v_ContDistStatSummary.TargeteddDPCount as [DPCount], 
	dbo.v_ContDistStatSummary.NumberInstalled as [Installed], 
	dbo.v_ContDistStatSummary.NumberInProgress as [InProgress], 
	dbo.v_ContDistStatSummary.NumberErrors as [Errors] 
FROM 
	dbo.v_ContDistStatSummary INNER JOIN 
	dbo.v_Package ON dbo.v_ContDistStatSummary.PkgID = dbo.v_Package.PackageID