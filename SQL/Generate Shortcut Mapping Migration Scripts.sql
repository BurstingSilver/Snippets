/* 
    USAGE: 
    Set the @websiteRiSEName to the name of the RiSE site to pull all shortcuts for that site.
    If you're unsure of the site name, check the Perspective table.
    You can also set @websiteRiSEName to null to pull shortcuts for "All Sites"
*/

DECLARE @websiteRiSEName nvarchar(100) = 'Staff';

SELECT 
    URLMapping.DirectoryName,
    ISNULL(p.PerspectiveName, 'allsites') AS WebSiteName,
    'IF NOT EXISTS (SELECT 1 FROM URLMapping WHERE URLMappingKey = ''' + CAST(URLMapping.URLMappingKey AS nvarchar(38)) + ''')' + CHAR(13) + CHAR(10) + 
    '    INSERT INTO URLMapping(URLMappingKey,DirectoryName,URL,WebsiteDocumentVersionKey,TargetDocumentVersionKey,URLMappingDesc,URLParameters,URLMappingTypeCode) VALUES (' + 
    '''' + CAST(URLMapping.URLMappingKey AS nvarchar(38)) + ''',' + 
    '''' + URLMapping.DirectoryName + ''',' + 
    '''' + URLMapping.[URL] + ''',' + 
    IIF(URLMapping.WebsiteDocumentVersionKey IS NULL,'NULL','''' + CAST(URLMapping.WebsiteDocumentVersionKey AS nvarchar(38)) + '''') + ',' + 
    IIF(URLMapping.TargetDocumentVersionKey IS NULL,'NULL','''' + CAST(URLMapping.TargetDocumentVersionKey AS nvarchar(38)) + '''') + ',' + 
    IIF(URLMapping.URLMappingDesc IS NULL,'NULL','''' + URLMapping.URLMappingDesc + '''') + ',' + 
    IIF(URLMapping.URLParameters IS NULL,'NULL','''' + URLMapping.URLParameters + '''') + ',' + 
    + CAST(URLMapping.URLMappingTypeCode AS nvarchar(2)) + ');' 
FROM 
    URLMapping 
    LEFT OUTER JOIN Perspective p ON URLMapping.WebsiteDocumentVersionKey = p.WebsiteKey
WHERE 
     @websiteRiSEName IS NULL 
     OR p.PerspectiveName = @websiteRiSEName
ORDER BY
    UrlMapping.DirectoryName;
