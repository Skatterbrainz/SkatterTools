SELECT
	ResourceID,
	[Name],
	Manufacturer,
	Model,
	SerialNumber,
	OperatingSystem,
	OSBuild,
	ClientVersion,
	LastHwScan,
	LastDDR,
	LastPolicyRequest,
	ADSiteName 
FROM (
	SELECT 
		dbo.v_R_System.ResourceID, 
		dbo.v_R_System.Name0 as [Name], 
		dbo.v_GS_COMPUTER_SYSTEM.Manufacturer0 as Manufacturer, 
		dbo.v_GS_COMPUTER_SYSTEM.Model0 as Model, 
		dbo.v_GS_SYSTEM_ENCLOSURE.SerialNumber0 as SerialNumber, 
		dbo.vWorkstationStatus.ClientVersion, 
		dbo.vWorkstationStatus.LastHardwareScan as LastHwScan, 
		dbo.vWorkstationStatus.LastPolicyRequest, 
		dbo.vWorkstationStatus.LastDDR,
		dbo.v_R_System.AD_Site_Name0 as ADSiteName, 
		dbo.v_GS_OPERATING_SYSTEM.Caption0 as OperatingSystem, 
		dbo.v_GS_OPERATING_SYSTEM.BuildNumber0 as OSBuild
	FROM 
		dbo.v_R_System INNER JOIN
		dbo.v_GS_COMPUTER_SYSTEM ON 
		dbo.v_R_System.ResourceID = dbo.v_GS_COMPUTER_SYSTEM.ResourceID INNER JOIN
		dbo.v_GS_SYSTEM_ENCLOSURE ON 
		dbo.v_R_System.ResourceID = dbo.v_GS_SYSTEM_ENCLOSURE.ResourceID INNER JOIN
		dbo.vWorkstationStatus ON 
		dbo.v_R_System.ResourceID = dbo.vWorkstationStatus.ResourceID INNER JOIN
		dbo.v_GS_OPERATING_SYSTEM ON 
		dbo.v_R_System.ResourceID = dbo.v_GS_OPERATING_SYSTEM.ResourceID
	) AS T1 