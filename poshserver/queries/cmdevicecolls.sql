-- collections for which a device belongs to
SELECT DISTINCT 
	v_FullCollectionMembership.Name as [Name],
	v_FullCollectionMembership.CollectionID, 
	v_Collection.Name as [CollectionName] 
FROM 
	v_FullCollectionMembership INNER JOIN v_Collection ON 
	v_FullCollectionMembership.CollectionID = v_Collection.CollectionID 
ORDER BY 
	CollectionName