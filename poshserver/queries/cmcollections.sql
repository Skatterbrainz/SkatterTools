SELECT DISTINCT 
	dbo.v_Collection.Name as CollectionName, 
	dbo.v_Collection.CollectionID, dbo.v_Collection.Comment, 
	dbo.v_Collection.MemberCount as Members, 
	dbo.v_Collection.CollectionType as [Type], 
	dbo.v_Collections.CollectionVariablesCount as Variables, 
	dbo.v_Collections.LimitToCollectionID as LimitedTo,
	dbo.v_Collections. 
FROM 
	dbo.v_FullCollectionMembership RIGHT OUTER JOIN dbo.v_Collection ON 
	dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
	INNER JOIN dbo.v_Collections ON 
	dbo.v_Collection.Name = dbo.v_Collections.CollectionName 
