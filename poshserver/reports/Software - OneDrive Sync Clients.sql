SELECT DISTINCT 
	v_R_System.Name0 AS [ComputerName], 
	v_GS_INSTALLED_EXECUTABLE.ResourceID, 
	v_GS_INSTALLED_EXECUTABLE.ExecutableName0 AS [ExeName], 
	v_GS_INSTALLED_EXECUTABLE.FileSize0 AS [FileSize], 
	v_GS_INSTALLED_EXECUTABLE.FileVersion0 AS [FileVersion], 
	v_GS_INSTALLED_EXECUTABLE.InstalledFilePath0 AS [InstallPath], 
	v_GS_INSTALLED_EXECUTABLE.ProductCode0 AS [ProductCode], 
	v_GS_INSTALLED_EXECUTABLE.ProductVersion0 AS [ProductVersion], 
	v_GS_INSTALLED_EXECUTABLE.Publisher0 AS [Publisher]
FROM 
	v_GS_INSTALLED_EXECUTABLE INNER JOIN
	v_R_System ON v_GS_INSTALLED_EXECUTABLE.ResourceID = v_R_System.ResourceID
WHERE 
	(v_GS_INSTALLED_EXECUTABLE.ExecutableName0 IN ('OneDrive.exe', 'OneDriveSetup.exe','Groove.exe'))
ORDER BY 
	v_R_System.Name0