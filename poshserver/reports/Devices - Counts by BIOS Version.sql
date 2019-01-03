SELECT DISTINCT
	BIOSVersion0 AS [BIOSVersion],
	Version0 AS [Version],
	InstallDate0 AS [InstallDate],
	COUNT(*) AS Clients
FROM 
	v_GS_PC_BIOS
GROUP BY
	BIOSVersion0,
	InstallDate0,
	Version0