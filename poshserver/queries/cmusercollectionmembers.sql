SELECT DISTINCT 
	v_R_User.User_Name0 AS UserName, 
	v_FullCollectionMembership.Name AS UserFullName, 
	v_FullCollectionMembership.ResourceID, 
	v_FullCollectionMembership.Domain, 
	v_FullCollectionMembership.SiteCode, 
	case 
		when (IsDirect = 1) then 'Direct' 
		else 'Query' end as RuleType, 
	v_FullCollectionMembership.CollectionID, 
	v_Collection.Name AS CollectionName
FROM 
	v_FullCollectionMembership INNER JOIN v_Collection ON 
	v_FullCollectionMembership.CollectionID = v_Collection.CollectionID 
	INNER JOIN v_R_User ON 
	v_FullCollectionMembership.ResourceID = v_R_User.ResourceID
