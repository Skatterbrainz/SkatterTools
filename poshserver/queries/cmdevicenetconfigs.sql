SELECT DISTINCT 
	v_R_System.Name0 as Name,
	v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID,
	case 
		when (DHCPEnabled0=1) then 'Yes' else 'No' end as DHCPEnabled,
	DHCPServer0 as DHCPServer,
	IPAddress0 as IPAddress,
	IPSubnet0 as IPSubnect,
	MACAddress0 as MAC,
	DefaultIPGateway0 as IPGateway,
	case 
		when (IPEnabled0 = 1) then 'Yes' else 'No' end as Enabled
FROM 
	v_GS_NETWORK_ADAPTER_CONFIGURATION LEFT JOIN
	v_R_SYSTEM ON v_GS_NETWORK_ADAPTER_CONFIGURATION.ResourceID = v_R_System.ResourceID 
ORDER BY
	v_R_System.Name0