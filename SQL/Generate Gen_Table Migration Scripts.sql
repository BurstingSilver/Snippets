DECLARE @TableName varchar(60) = 'TABLE_NAME';

SELECT 
	'IF NOT EXISTS (SELECT 1 FROM Gen_Tables WHERE Gen_Tables.TABLE_NAME = ''' + Gen_Tables.TABLE_NAME + ''' AND Gen_Tables.CODE = ''' + Gen_Tables.CODE + ''')' + CHAR(13) + CHAR(10) + 
	'    INSERT INTO Gen_Tables (TABLE_NAME, CODE, SUBSTITUTE, UPPER_CODE, [DESCRIPTION], NCODE) VALUES (' + 
	'''' + TABLE_NAME + ''', ' + 
	'''' + REPLACE(CODE,'''','''''') + ''', ' + 
	'''' + REPLACE(SUBSTITUTE,'''','''''') + ''', ' + 
	'''' + REPLACE(UPPER_CODE,'''','''''') + ''', ' + 
	'''' + REPLACE([DESCRIPTION],'''','''''') + ''', ' + 
	'''' + NCODE + ''');' 
FROM 
	Gen_Tables 
WHERE 
	TABLE_NAME = @TableName;
