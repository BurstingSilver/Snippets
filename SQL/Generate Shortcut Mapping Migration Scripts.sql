DECLARE @websiteRiSEName nvarchar(100) = 'Staff';

SELECT 
	'INSERT INTO URLMapping(URLMappingKey,DirectoryName,URL,WebsiteDocumentVersionKey,TargetDocumentVersionKey,URLMappingDesc,URLParameters,URLMappingTypeCode) VALUES (' + 
	'''' + CAST(URLMapping.URLMappingKey AS nvarchar(38)) + ''',' + 
	'''' + URLMapping.DirectoryName + ''',' + 
	'''' + URLMapping.[URL] + ''',' + 
	'''' + CAST(URLMapping.WebsiteDocumentVersionKey AS nvarchar(38)) + ''',' + 
	IIF(URLMapping.TargetDocumentVersionKey IS NULL,'NULL','''' + CAST(URLMapping.TargetDocumentVersionKey AS nvarchar(38)) + '''') + ',' + 
	IIF(URLMapping.URLMappingDesc IS NULL,'NULL','''' + URLMapping.URLMappingDesc + '''') + ',' + 
	IIF(URLMapping.URLParameters IS NULL,'NULL','''' + URLMapping.URLParameters + '''') + ',' + 
	+ CAST(URLMapping.URLMappingTypeCode AS nvarchar(2)) + ');' 
FROM 
	URLMapping 
WHERE 
	(@websiteRiSEName IS NULL AND 
	URLMapping.WebsiteDocumentVersionKey IS NULL) OR  
	EXISTS (
		SELECT 
			1 
		FROM 
			Perspective 
		WHERE 
			Perspective.WebsiteKey = URLMapping.WebsiteDocumentVersionKey AND 
			Perspective.PerspectiveName = @websiteRiSEName);