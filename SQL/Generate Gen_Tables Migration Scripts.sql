SELECT 
	'IF NOT EXISTS (SELECT 1 FROM Gen_Tables WHERE Gen_Tables.TABLE_NAME = ''' + Gen_Tables.TABLE_NAME + ''' AND Gen_Tables.CODE = ''' + Gen_Tables.CODE + ''')' + CHAR(13) + CHAR(10) + 
	'    INSERT INTO Gen_Tables (TABLE_NAME, CODE, SUBSTITUTE, UPPER_CODE, [DESCRIPTION], NCODE) VALUES (' + 
	'''' + Gen_Tables.TABLE_NAME + ''',' + 
	'''' + Gen_Tables.CODE + ''',' + 
	'''' + Gen_Tables.SUBSTITUTE + ''',' + 
	'''' + Gen_Tables.UPPER_CODE + ''',' + 
	'''' + Gen_Tables.[DESCRIPTION] + ''',' + 
	'N''' + Gen_Tables.NCODE + ''');' 
FROM 
	Gen_Tables;
