/************************
* Get Unused Contacts
* ================
* This is the same query that returns a count in 
* DB Maintenance utility when you click the 
* Purge Unused Contacts button
*/
SELECT cm.*
FROM [dbo].[ContactMain] cm        
INNER JOIN [dbo].[ContactStatusRef] cs ON cm.[ContactStatusCode] = cs.[ContactStatusCode]        
LEFT OUTER JOIN [dbo].[Name] n ON cm.[SyncContactID] = n.[ID]       
LEFT OUTER JOIN [dbo].[UserMain] um ON cm.[ContactKey] = um.[UserKey] WHERE n.[ID] IS NULL AND um.[UserKey] IS NULL       
AND (cs.[ContactStatusDesc] = 'Delete' AND cs.[IsSystem] = 1)  

/************************
* Get Unused Users
* ================
* This is the same query that returns a count in 
* DB Maintenance utility when you click the 
* Purge Unused Users button
*/
SELECT u.*
FROM [dbo].[UserMain] u 
LEFT OUTER JOIN [Name] n ON u.[ContactMaster] = n.[ID] WHERE u.[UserId] NOT IN ('MANAGER', 'SYSTEM', 'ADMINISTRATOR', 'GUEST', 'DEMOSETUP', 'NUNIT1', 'IMISLOG')       
AND ((u.[ContactMaster] = '' AND u.[IsDisabled] = 1)              OR (n.[ID] IS NULL AND u.[IsDisabled] = 1))
