DECLARE 
  @str as varchar(38),
  @name as varchar(max) = 'PANEL_NAME'

SELECT @str = '%'+CONVERT(varchar(36), paneldefinitionid)+'%' FROM PanelDefinition WHERE name = @name
SELECT @str

SELECT DISTINCT 
  dbo.asi_PublishedDocumentPath(DocumentVersionKey) docPath
FROM 
  DocumentMain
WHERE 
  Convert(varchar(max), CONVERT(varbinary(max), Blob)) LIKE @str
