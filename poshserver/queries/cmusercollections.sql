SELECT DISTINCT 
    dbo.v_Collection.CollectionID, 
    dbo.v_Collection.Name as CollectionName, 
    dbo.v_Collection.Comment, 
    dbo.v_Collection.MemberCount as Members, 
    case 
        when (v_Collection.CollectionType = 2) then 'Device'
        when (v_Collection.CollectionType = 5) then 'User'
        end as [Type], 
    case
        when (v_Collections.CollectionVariablesCount = 1) then 'Yes'
        else 'No' end as Variables, 
    dbo.v_Collections.LimitToCollectionID as LimitedTo 
FROM 
    dbo.v_FullCollectionMembership RIGHT OUTER JOIN dbo.v_Collection ON 
    dbo.v_FullCollectionMembership.CollectionID = dbo.v_Collection.CollectionID 
    INNER JOIN dbo.v_Collections ON 
    dbo.v_Collection.Name = dbo.v_Collections.CollectionName 
WHERE 
    (dbo.v_Collections.CollectionType = 1)