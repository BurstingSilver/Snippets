DECLARE @TableName varchar(60) = 'TABLE_NAME';

SELECT 
	'INSERT INTO Gen_Tables (TABLE_NAME, CODE, SUBSTITUTE, UPPER_CODE, [DESCRIPTION], NCODE) VALUES ' + 
	'(''' + TABLE_NAME + ''', ' + 
	'''' + REPLACE(CODE,'''','''''') + ''', ' + 
	'''' + REPLACE(SUBSTITUTE,'''','''''') + ''', ' + 
	'''' + REPLACE(UPPER_CODE,'''','''''') + ''', ' + 
	'''' + REPLACE([DESCRIPTION],'''','''''') + ''', ' + 
	'''' + NCODE + ''');' 
FROM 
	Gen_Tables 
WHERE 
	TABLE_NAME = @TableName;
