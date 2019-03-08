-- Enable OLE Automation
--EXEC sp_configure 'Ole Automation Procedures', 1;
--GO

--RECONFIGURE;
--GO

DROP TABLE IF EXISTS NewUsers
GO

CREATE TABLE NewUsers ( ID uniqueidentifier, iMIS_ID varchar(10), FirstName varchar(100), LastName varchar(100) )
GO

SET NOCOUNT ON;

INSERT INTO NewUsers (ID, FirstName, LastName) VALUES (NEWID(), 'Mickey', 'Mouse') 
INSERT INTO NewUsers (ID, FirstName, LastName) VALUES (NEWID(), 'Minnie', 'Mouse') 
INSERT INTO NewUsers (ID, FirstName, LastName) VALUES (NEWID(), 'Donald', 'Duck') 
INSERT INTO NewUsers (ID, FirstName, LastName) VALUES (NEWID(), 'Daisy', 'Duck') 

SELECT * FROM NewUsers

-- Get around the 4000 character response limit by creating a temp table
CREATE TABLE #apiResponse ( jsonData text );

DECLARE @authHeader NVARCHAR(4000);
DECLARE @contentType NVARCHAR(64);
DECLARE @postData NVARCHAR(2000);
DECLARE @responseText NVARCHAR(4000);
DECLARE @responseXML NVARCHAR(2000);
DECLARE @ret INT;
DECLARE @status NVARCHAR(32);
DECLARE @statusText NVARCHAR(32);
DECLARE @token INT;
DECLARE @apiBase NVARCHAR(256);
DECLARE @url NVARCHAR(256);

SET @contentType = 'application/x-www-form-urlencoded';
SET @postData = 'username=[USERNAME]&grant_type=password&password=[PASSWORD]'
SET @apiBase = '[SCHEDULER_URL]'
SET @url = @apiBase + 'token'

EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- Send the request.
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;

EXEC @ret = sp_OAMethod @token, 'send', NULL, @postData;

-- Handle the response.
EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;

-- Show the response.
--PRINT 'Status: ' + @status + ' (' + @statusText + ')';
--PRINT 'Response text: ' + @responseText;

SET @authHeader = 'Bearer ' + JSON_VALUE(@responseText,'$.access_token')

-- Close the connection.
EXEC @ret = sp_OADestroy @token;
IF @ret <> 0 RAISERROR('Unable to close HTTP connection.', 10, 1);

DECLARE @Id uniqueidentifier, @FirstName varchar(100), @LastName varchar(100), @NewId varchar(10)

DECLARE newRecords CURSOR FOR 
SELECT 
    ID, FirstName, LastName 
FROM 
    NewUsers 

OPEN newRecords

FETCH NEXT FROM newRecords INTO @Id, @FirstName, @LastName

WHILE @@FETCH_STATUS = 0
BEGIN 

    SET @postData = 
'{
   "$type": "Asi.Soa.Membership.DataContracts.PersonData, Asi.Soa.Membership.Contracts",
   "PersonName": {
                "$type": "Asi.Soa.Membership.DataContracts.PersonNameData, Asi.Soa.Membership.Contracts",
                "FirstName": "' + @FirstName + '",
                "LastName": "' + @LastName + '"
            },
},'

    EXEC @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @token OUT;
    IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

    SET @url = @apiBase + '/api/Party'
    SET @contentType = 'application/json'
    SET @responseText = null;

    -- Send the request.
    EXEC @ret = sp_OAMethod @token, 'open', NULL, 'POST', @url, 'false';
    EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
    EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Authorization', @authHeader;

    EXEC @ret = sp_OAMethod @token, 'send', NULL, @postData;

    -- Handle the response.
    EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
    EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
    INSERT INTO #apiResponse EXEC @ret = sp_OAGetProperty @token, 'responseText';--, @responseText OUT;

    SELECT @NewId = JSON_VALUE(CAST(#apiResponse.jsonData AS VARCHAR(MAX)),'$.PartyId') FROM #apiResponse 

    DELETE FROM #apiResponse

    -- Show the response.
    PRINT 'Status: ' + @status + ' (' + @statusText + ')';
    PRINT 'New User ID: ' + @NewId

    UPDATE NewUsers SET IMIS_ID = @NewId WHERE ID = @Id

    FETCH NEXT FROM newRecords INTO @Id, @FirstName, @LastName 
END

CLOSE newRecords
DEALLOCATE newRecords

DROP TABLE #apiResponse

SELECT * FROM NewUsers

SET NOCOUNT OFF;