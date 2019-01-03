SELECT DISTINCT 
	v_FullCollectionMembership.Name AS [ComputerName], 
	v_FullCollectionMembership.ResourceID, 
	CASE 
		WHEN (ResourceType = 5) THEN 'Device' 
		WHEN (ResourceType = 2) THEN 'User' END AS ResourceType, 
	v_FullCollectionMembership.Domain, 
	v_FullCollectionMembership.SiteCode, 
	CASE 
		WHEN (IsDirect = 1) THEN 'Direct' 
		ELSE 'Query' END AS RuleType, 
	v_FullCollectionMembership.CollectionID, 
	v_Collection.Name as [CollectionName]
FROM 
	v_FullCollectionMembership INNER JOIN
	v_Collection ON v_FullCollectionMembership.CollectionID = v_Collection.CollectionID