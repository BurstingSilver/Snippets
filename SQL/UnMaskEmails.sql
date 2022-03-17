BEGIN TRANSACTION 
BEGIN TRY
	DECLARE @afterNameUpdate table 
		([ID] [varchar](10) NOT NULL,
		 [EMAIL] [varchar](100) NOT NULL);

	DECLARE @afterNameAddressUpdate table 
		([ID] [varchar](10) NOT NULL,
		 [ADDRESS_NUM] [int] NOT NULL,
		 [EMAIL] [varchar](100) NOT NULL);

	DECLARE @domain varchar(20) = '@CLIENT.ORG'

	-- Unmask name table
	SELECT 
		'Before Name Update' AS [STATE],
		ID,
		EMAIL
	FROM 
		[Name]
	WHERE
		EMAIL = ID + @domain
	ORDER BY
		CAST(ID as varchar);

	UPDATE
		n
	SET
		n.EMAIL = lastEmailChanged.[BEFORE]
	OUTPUT
		inserted.ID,
		inserted.EMAIL
	INTO 
		@afterNameUpdate
	FROM 
		[Name] n
		LEFT OUTER JOIN (SELECT 
						 	p.ID,
						 	p.BEFORE,
						 	p.AFTER
						 FROM 
						 	(SELECT	
						    		ID,
						    		TRIM(CAST('<t>' + REPLACE(REPLACE(LOG_TEXT, 'Name.EMAIL:', ''), '->','</t><t>') + '</t>' AS XML).value('/t[1]','varchar(50)')) AS [BEFORE],
						    		TRIM(CAST('<t>' + REPLACE(REPLACE(LOG_TEXT, 'Name.EMAIL:', ''), '->','</t><t>') + '</t>' AS XML).value('/t[2]','varchar(50)')) AS [AFTER],
						    		ROW_NUMBER() OVER(Partition by ID ORDER BY DATE_TIME DESC) AS ROW_NUM
						      FROM 
						    		Name_Log
						      WHERE 
						    		LOG_TEXT LIKE 'Name.EMAIL:%'
						    		AND LOG_TYPE = 'CHANGE'
						     ) as p
						 WHERE
							p.ROW_NUM = 1) lastEmailChanged on n.ID = lastEmailChanged.ID
	WHERE
		n.EMAIL = n.ID + @domain
		AND n.EMAIL = lastEmailChanged.[AFTER];

	SELECT
		'After Name Update' AS [STATE],
		*
	FROM 
		@afterNameUpdate
	ORDER BY
		CAST(ID as int)

	-- Unmask name address table
	SELECT 
		'Before Name_Address Update' AS [STATE],
		ID,
		ADDRESS_NUM,
		EMAIL
	FROM 
		Name_Address
	WHERE
		EMAIL = ID + @domain
	ORDER BY
		CAST(ID as varchar);

	UPDATE
		na
	SET
		na.EMAIL = lastEmailChanged.[BEFORE]
	OUTPUT
		inserted.ID,
		inserted.ADDRESS_NUM,
		inserted.EMAIL
	INTO 
		@afterNameAddressUpdate
	FROM 
		Name_Address na
		LEFT OUTER JOIN (SELECT 
						 	p.ID,
						 	p.BEFORE,
						 	p.AFTER
						 FROM 
						 	(SELECT	
						    		ID,
						    		TRIM(CAST('<t>' + REPLACE(REPLACE(LOG_TEXT, 'Name.EMAIL:', ''), '->','</t><t>') + '</t>' AS XML).value('/t[1]','varchar(50)')) AS [BEFORE],
						    		TRIM(CAST('<t>' + REPLACE(REPLACE(LOG_TEXT, 'Name.EMAIL:', ''), '->','</t><t>') + '</t>' AS XML).value('/t[2]','varchar(50)')) AS [AFTER],
						    		ROW_NUMBER() OVER(Partition by ID ORDER BY DATE_TIME DESC) AS ROW_NUM
						      FROM 
						    		Name_Log
						      WHERE 
						    		LOG_TEXT LIKE 'Name.EMAIL:%'
						    		AND LOG_TYPE = 'CHANGE'
						     ) as p
						 WHERE
							p.ROW_NUM = 1) lastEmailChanged on na.ID = lastEmailChanged.ID
	WHERE
		na.EMAIL = na.ID + @domain
		AND na.EMAIL = lastEmailChanged.[AFTER];

	SELECT
		'After Name_Address Update' AS [STATE],
		*
	FROM 
		@afterNameAddressUpdate
	ORDER BY
		CAST(ID as int)
			
	-- COMMIT TRANSACTION
	-- PRINT 'TRANSACTION COMMITTED';
END TRY
BEGIN CATCH	   
	PRINT ERROR_MESSAGE();
	ROLLBACK TRANSACTION
END CATCH




