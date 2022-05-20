-- This can be used to drop all view diagrams that have been created, these are unnecessarly generated when someone uses the ui editor
DECLARE 
	@level1name NVARCHAR(128);

-- Drop all MS_DiagramPaneCount
SELECT 
	objname 
INTO 
	#diagramPanelCount
FROM 
	sys.fn_listextendedproperty(N'MS_DiagramPaneCount' , N'SCHEMA',N'dbo', N'VIEW', NULL, NULL,NULL);
	
DECLARE 
	diagramPanelCount_cursor 
CURSOR FOR SELECT
       *
FROM 
	#diagramPanelCount;
   
OPEN 
	diagramPanelCount_cursor;
   
FETCH NEXT FROM 
	diagramPanelCount_cursor 
INTO 
	@level1name;

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPaneCount' , @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'VIEW', @level1name= @level1name
    
    FETCH NEXT FROM diagramPanelCount_cursor INTO @level1name;
END

CLOSE 
	diagramPanelCount_cursor;

DEALLOCATE 
	diagramPanelCount_cursor;
	
DROP TABLE 
	#diagramPanelCount;
	
-- Drop all MS_DiagramPane1
SELECT 
	objname
INTO 
	#diagramPanel
FROM 
	sys.fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW', NULL, NULL,NULL);
	
DECLARE 
	diagramPanel_cursor 
CURSOR FOR SELECT
       *
FROM 
	#diagramPanel;
   
OPEN 
	diagramPanel_cursor;
   
FETCH NEXT FROM 
	diagramPanel_cursor 
INTO 
	@level1name;

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPane1' , @level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'VIEW', @level1name= @level1name
    
    FETCH NEXT FROM diagramPanel_cursor INTO @level1name;
END

CLOSE 
	diagramPanel_cursor;

DEALLOCATE 
	diagramPanel_cursor;
	
DROP TABLE 
	#diagramPanel;
	
	
	









