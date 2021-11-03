SELECT 
	'IF NOT EXISTS (SELECT 1 FROM ObjectMetaData WHERE ObjectName = ''' + ObjectMetaData.ObjectName + ''')' + CHAR(13) + CHAR(10) + 
	'    INSERT INTO ObjectMetaData (ObjectName, RelatedToEntity, IsUserDefined, IsMultiInstance) VALUES (' + 
	'''' + ObjectMetaData.ObjectName + ''',' + 
	'''' + ObjectMetaData.RelatedToEntity + ''',' + 
	+ CAST(ObjectMetaData.IsUserDefined AS varchar(1)) + ',' + 
	+ CAST(ObjectMetaData.IsMultiInstance AS varchar(1)) + ');' 
FROM 
	ObjectMetaData;
