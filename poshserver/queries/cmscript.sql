select distinct
    ScriptName,
    ScriptVersion,
    ScriptGuid,
    Author,
    ScriptType,
    Feature,
    ApprovalState,
    CASE 
        when (ApprovalState = 0) then 'Pending'
        when (ApprovalState = 1) then 'Denied'
        when (ApprovalState = 3) then 'Approved'
        else 'Unknown'
        end as Approval,
    Approver,
    '(It looks like Chinese writing, so I cant display it yet)' as [Script],
    ScriptHashAlgorithm,
    ScriptHash,
    LastUpdateTime,
    Comment 
FROM vSMS_Scripts 