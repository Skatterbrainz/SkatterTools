SELECT DISTINCT 
    [Name],
    ResourceID,
    case 
	    when (ResourceType=5) then 'Device'
	    when (ResourceType=2) then 'User'
	    end as [ResourceType],
    Domain,
    SiteCode,
    case
      when (IsDirect=1) then 'Direct'
      else 'Query' end as RuleType,
    CollectionID
FROM 
    v_FullCollectionMembership
