SELECT DISTINCT 
    dbo.v_Collection.Name AS CollectionName, 
    dbo.v_Collection.CollectionID, 
    dbo.v_Collection.Comment, 
    dbo.v_Collection.MemberCount AS Members, 
    case
        when (dbo.v_Collection.CollectionType = 1) then 'User'
        when (dbo.v_Collection.CollectionType = 2) then 'Device'
        end AS Type, 
    dbo.v_Collections.CollectionVariablesCount AS Variables, 
    dbo.v_Collections.LimitToCollectionID AS LimitedTo 
FROM 
    dbo.v_Collections INNER JOIN 
    dbo.v_Collection ON 
    dbo.v_Collections.CollectionName = dbo.v_Collection.Name 
