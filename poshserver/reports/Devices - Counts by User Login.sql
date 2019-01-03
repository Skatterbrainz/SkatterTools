SELECT DISTINCT
	TOP 50 
	UserName0 as [UserName],
	COUNT(*) as [Clients]
FROM
	v_GS_COMPUTER_SYSTEM
GROUP BY
	UserName0
ORDER BY 
	Clients DESC