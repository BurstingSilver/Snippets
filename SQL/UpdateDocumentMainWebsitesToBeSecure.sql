DECLARE 
	@documentKey [uniqueidentifier],
	@xml [xml],
	@WebsiteRootUrl [varchar](max);

DECLARE @documentMainTemp table 
		([DocumentKey] [uniqueidentifier] NOT NULL,
		 [XML] [xml] NOT NULL);

-- Insert all WEB documents into temp table
INSERT INTO
	@documentMainTemp 
SELECT
	dm.[DocumentKey],
	CAST(CAST(dm.[Blob] AS VARBINARY(MAX)) AS XML) as [XML]
FROM 
	[dbo].[DocumentMain] dm
WHERE 
	dm.[DocumentTypeCode] = 'WEB'
	AND DocumentName NOT IN ('CS2', 'CS', 'Temporary');

-- Loop through each document and update XML WebsiteRootUrl to use https
DECLARE 
	db_cursor 
CURSOR FOR SELECT 
	*
FROM
	@documentMainTemp;
	
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @documentKey, @xml;

WHILE @@FETCH_STATUS = 0  
BEGIN  
      -- Get value of WebsiteRootUrl
	  SET @WebsiteRootUrl = @xml.value('declare namespace ns="http://schemas.imis.com/2008/01/DataContracts/Website";(/ns:Website/ns:WebsiteRootUrl/text())[1]', 'VARCHAR(max)');

	  -- If the value is http we will change it to be https
	  IF (@WebsiteRootUrl LIKE 'http://%') 
	  BEGIN
			PRINT CONCAT('Before: ', @WebsiteRootUrl);
			SET @WebsiteRootUrl = REPLACE(@WebsiteRootUrl, 'http://', 'https://');
			PRINT CONCAT('After: ', @WebsiteRootUrl);

			-- Replace WebsiteRootUrl with updated string 
			SET @xml.modify('declare namespace ns="http://schemas.imis.com/2008/01/DataContracts/Website";replace value of (/ns:Website/ns:WebsiteRootUrl/text())[1] with sql:variable("@WebsiteRootUrl")');
			PRINT CONCAT('Updated XML: ', CONVERT(varchar(max), @xml));
      END;

	  UPDATE
		@documentMainTemp
	  SET
		[XML] = @xml
	  WHERE
		DocumentKey = @documentKey

      FETCH NEXT FROM db_cursor INTO @documentKey, @xml  
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

-- Bulk update all documents from temp table
UPDATE
	dm
SET
	dm.[Blob] = CONVERT(varchar(MAX), dmt.[XML])
FROM
	dbo.[DocumentMain] dm
	INNER JOIN @documentMainTemp dmt on dm.[DocumentKey] = dmt.[DocumentKey]
