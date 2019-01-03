SELECT DISTINCT
	Version0 AS [Version],
	COUNT(*) AS Clients
FROM 
	dbo.v_GS_WINDOWSUPDATEAGENTVERSION
GROUP BY 
	Version0
ORDER BY
	[Version]