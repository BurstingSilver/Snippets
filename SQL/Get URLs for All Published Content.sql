SELECT 
    DocumentMain.DocumentKey, 
    DocumentMain.DocumentName, 
    dbo.fn_BSi_GetPathForHierarchyKey(Hierarchy.HierarchyKey,1,'https://justin.burstingsilver.com') 
FROM 
    DocumentMain INNER JOIN 
    Hierarchy ON Hierarchy.UniformKey = DocumentMain.DocumentVersionKey 
WHERE 
    DocumentTypeCode = 'CON' AND 
    DocumentStatusCode = '40'
