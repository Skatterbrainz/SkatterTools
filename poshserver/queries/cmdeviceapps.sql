SELECT DISTINCT 
	dbo.v_R_System.Name0, 
    dbo.v_GS_ADD_REMOVE_PROGRAMS.DisplayName0 AS ProductName, 
    dbo.v_GS_ADD_REMOVE_PROGRAMS.Publisher0 AS Publisher, 
    dbo.v_GS_ADD_REMOVE_PROGRAMS.Version0 AS Version 
FROM 
    dbo.v_GS_ADD_REMOVE_PROGRAMS INNER JOIN dbo.v_R_System ON 
	dbo.v_GS_ADD_REMOVE_PROGRAMS.ResourceID = dbo.v_R_System.ResourceID
