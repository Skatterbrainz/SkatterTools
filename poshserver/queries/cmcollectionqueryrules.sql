SELECT  
	v_CollectionRuleQuery.RuleName, 
	v_CollectionRuleQuery.QueryID, 
	v_CollectionRuleQuery.QueryExpression, 
    v_CollectionRuleQuery.LimitToCollectionID, 
	v_CollectionRuleQuery.CollectionID, 
	v_Collection.Name as [CollectionName] 
FROM 
	v_CollectionRuleQuery INNER JOIN
    v_Collection ON v_CollectionRuleQuery.CollectionID = v_Collection.CollectionID
ORDER BY 
	v_CollectionRuleQuery.RuleName