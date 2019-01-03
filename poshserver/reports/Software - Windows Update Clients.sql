SELECT DISTINCT 
	v_R_System.Name0 as [ComputerName], 
	v_R_System.ResourceID, 
	v_GS_WINDOWSUPDATEAGENTVERSION.Version0 AS Version
FROM 
	v_GS_WINDOWSUPDATEAGENTVERSION INNER JOIN
    v_R_System ON v_GS_WINDOWSUPDATEAGENTVERSION.ResourceID = v_R_System.ResourceID
GROUP BY 
	v_GS_WINDOWSUPDATEAGENTVERSION.Version0, 
	v_R_System.ResourceID, dbo.v_R_System.Name0
ORDER BY 
	v_R_System.Name0
