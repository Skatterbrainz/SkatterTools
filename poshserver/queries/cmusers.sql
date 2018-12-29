select distinct 
    ResourceID, 
    User_Name0 as UserName, 
    AADUserID, 
    Windows_NT_Domain0 as Domain, 
    User_Principal_Name0 as UPN,
    Department, 
    Title  
from v_R_User
