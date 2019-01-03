SELECT 
	TaskName,
	--TaskType,
	case 
		when (IsEnabled=1) then 'Yes' else 'No' end as [Enabled],
	NumRefreshDays,
	DaysOfWeek,
	BeginTime,
	LatestBeginTime,
	BackupLocation,
	DeleteOlderThan 
FROM 
	vSMS_SC_SQL_Task