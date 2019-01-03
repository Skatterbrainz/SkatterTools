SELECT DISTINCT 
	v_R_System.Name0 AS Name, 
	v_GS_LOGICAL_DISK.DeviceID0 as [Drive], 
	v_GS_LOGICAL_DISK.DriveType0 as [DiskType], 
	v_GS_LOGICAL_DISK.Description0 as [Description], 
    v_GS_LOGICAL_DISK.Size0 as [DiskSize], 
	v_GS_LOGICAL_DISK.FreeSpace0 as [FreeSpace],
	case
	   when (DriveType0 = 3) then (Size0 - FreeSpace0)
	   else 0 end as Used,
	case 
		when (DriveType0 = 3) then CONVERT(int,(((CAST(Size0 as DECIMAL(9,2)) - FreeSpace0) / Size0)*100))
		else NULL end as PCT 
FROM 
	v_R_System INNER JOIN
    v_GS_LOGICAL_DISK ON v_R_System.ResourceID = v_GS_LOGICAL_DISK.ResourceID
ORDER BY 
	v_GS_LOGICAL_DISK.DeviceID0