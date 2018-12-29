SELECT 
    ForestID,
    SMSSiteCode,
    SMSSiteName,
    LastDiscoveryTime,
    LastDiscoveryStatus,
    LastPublishingTime,
    case 
        when (PublishingStatus = 1) then 'Published'
        else '' end as PublishingStatus,
    case 
        when (DiscoveryEnabled = 1) then 'Yes'
        else 'No' end as DiscoveryEnabled,
    case 
        when (PublishingEnabled = 1) then 'Yes'
        else 'No' end as PublishingEnabled 
FROM 
    vActiveDirectoryForestDiscoveryStatus
