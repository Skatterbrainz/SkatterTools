select distinct 
    case 
      when (Status = 0) then '#1ED66B'
      when (Status = 1) then '#CBD61E'
      when (Status = 2) then '#D61E37'
      end as SiteStatus,
    Role,
    SiteCode,
    case 
      when (AvailabilityState = 0) then 'Online'
      when (AvailabilityState = 1) then '1'
      when (AvailabilityState = 2) then '2'
      when (AvailabilityState = 3) then 'Offline'
      when (AvailabilityState = 4) then '4'
      end as Availability, 
    SiteSystem, 
    TimeReported  
FROM v_SiteSystemSummarizer