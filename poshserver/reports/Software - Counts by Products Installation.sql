SELECT DISTINCT 
	dbo.v_GS_ADD_REMOVE_PROGRAMS.DisplayName0 as ProductName, 
	dbo.v_GS_ADD_REMOVE_PROGRAMS.Publisher0 as Publisher, 
	dbo.v_GS_ADD_REMOVE_PROGRAMS.Version0 as [Version],
	COUNT(*) AS Installs 
FROM 
	dbo.v_R_System INNER JOIN 
	dbo.v_GS_ADD_REMOVE_PROGRAMS ON 
	dbo.v_R_System.ResourceID = dbo.v_GS_ADD_REMOVE_PROGRAMS.ResourceID 
GROUP BY 
	DisplayName0,
	Publisher0,
	Version0
ORDER BY Installs DESC