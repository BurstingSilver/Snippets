-- Extends manager password by n months
DECLARE @extendByMonths [int] = 6;
	
UPDATE 
	aspnet_Membership 
SET 
	LastPasswordChangedDate = DATEADD(month, 6, GETDATE()) 
WHERE 
	UserId = (SELECT ProviderKey AS UserId FROM USERMAIN WHERE USERID = 'MANAGER');
