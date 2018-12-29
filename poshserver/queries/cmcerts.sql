SELECT distinct
    IssuedTo,
    ServerName,
    case 
        when ([Type]=2) then 'BootMedia'
        when ([Type]=4) then 'DistributionPoint'
        when ([Type]=5) then 'ISVProxy'
        end as CertType,
    case 
        when (KeyType = 1) then 'SelfSigned'
        when (KeyType = 2) then 'Issued'
        end as KeyType,
    ValidFrom,
    ValidUntil,
    case 
        when (IsApproved = 1) then 'Yes'
        else 'No' end as Approved,
    case 
        when (IsBlocked = 1) then 'Yes'
        else 'No' end as Blocked
FROM vSMS_Certificate