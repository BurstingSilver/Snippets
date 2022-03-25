-- Extends manager password by n months
DECLARE @extendByMonths [int] = 6;
	
UPDATE 
	aspnet_Membership 
SET 
	LastPasswordChangedDate = DATEADD(month, @extendByMonths, GETDATE()) 
WHERE 
	UserId = (SELECT ProviderKey AS UserId FROM USERMAIN WHERE USERID = 'MANAGER');
