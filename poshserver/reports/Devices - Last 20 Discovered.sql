SELECT TOP 20 
	dbo.v_R_System.ResourceID, 
	dbo.v_R_System.Name0 AS ComputerName, 
	dbo.v_R_System.AD_Site_Name0 AS ADSiteName, 
	dbo.v_R_System.Client_Version0 AS ClientVer, 
	dbo.v_R_System.User_Name0 AS UserName, 
	dbo.v_GS_OPERATING_SYSTEM.Caption0 AS Windows, 
	dbo.v_GS_COMPUTER_SYSTEM.Model0 AS Model 
FROM 
	dbo.v_R_System LEFT OUTER JOIN 
	dbo.v_GS_COMPUTER_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID 
	LEFT OUTER JOIN 
	dbo.v_GS_OPERATING_SYSTEM ON dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
ORDER BY
    ResourceID DESC