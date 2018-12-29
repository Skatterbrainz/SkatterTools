SELECT DISTINCT
    ItemType,
    Sitenumber,
    SourceTable 
FROM SC_Properties
WHERE (ItemType LIKE '%Discover%')