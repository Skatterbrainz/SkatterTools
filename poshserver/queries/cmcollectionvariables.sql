SELECT  
	v_CollectionVariable.Name, 
	v_CollectionVariable.Value, 
	case
		when (v_CollectionVariable.IsMasked = 1) then 'Yes' else 'No' end as IsMasked, 
	v_CollectionVariable.CollectionID, 
	v_Collection.Name AS CollectionName
FROM 
	v_CollectionVariable INNER JOIN
    v_Collection ON v_CollectionVariable.CollectionID = v_Collection.CollectionID