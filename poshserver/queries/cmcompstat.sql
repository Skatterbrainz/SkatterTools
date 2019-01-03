/*  https://docs.microsoft.com/en-us/sccm/develop/reference/core/servers/manage/sms_statusmessage-server-wmi-class */
select distinct 
    RecordID,
    Component,
    MessageID,
    case 
        when (MessageType = 256) then 'Milestone'
        when (MessageType = 512) then 'Detail'
        when (MessageType = 768) then 'Audit'
        when (MessageType = 1024) then 'NTEvent'
        end as MessageType,
    case 
        when (ABS(Severity) = 1073741824) then 'Info'
        when (ABS(Severity) = 2147483648) then 'Warning'
        else 'Error' end as Severity,
    MachineName,
    ModuleName,
    Win32Error,
    Time,
    SiteCode,
    TopLevelSiteCode,
    ProcessID,
    ThreadID,
    case 
        when (ReportFunction = 0) then 'Report'
        when (ReportFunction = 16) then 'BeginTransaction'
        when (ReportFunction = 32) then 'CommitSuccessfulTransaction'
        when (ReportFunction = 48) then 'CommitFailedTransaction'
        when (ReportFunction = 64) then 'RollbackTransaction'
        when (ReportFunction = 80) then 'ReportEX'
        end as ReportFunction,
    SuccessfulTransaction,
    case 
        when (PartOfTransaction = 0) then 'False'
        else 'True' end as [Transaction],
    case 
        when (PerClient = 0) then 'False'
        else 'True' end as PerClient 
from 
    vStatusMessages
where 
    (DATEDIFF(HH,vStatusMessages.Time, GETDATE()) < 24)
