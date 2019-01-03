SELECT 
	CASE
		when (DefaultIPGateway0 IS NULL) then 'None'
		else DefaultIPGateway0 end as Gateway,
	COUNT(*) AS Clients
FROM
	v_GS_NETWORK_ADAPTER_CONFIGURATION
WHERE
	v_GS_NETWORK_ADAPTER_CONFIGURATION.IPEnabled0 = 1
GROUP BY
	DefaultIPGateway0
ORDER BY 
	DefaultIPGateway0