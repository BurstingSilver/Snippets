DROP FUNCTION IF EXISTS fn_BSi_GetPathForHierarchyKey;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Justin Trout, Bursting Silver
-- Create date: 2019-04-16
-- Description:	Given a hierarchy key and a URL prefix, returns a complete URL path to the document
-- =============================================
CREATE FUNCTION fn_BSi_GetPathForHierarchyKey
(
	@hierarchyKey uniqueidentifier, 
    @publishedOnly bit, 
    @urlPrefix varchar(255) 
)
RETURNS varchar(max)
AS
BEGIN
    DECLARE 
        @path varchar(max), 
        @rootHierarchyKey uniqueidentifier,
        @documentFound bit,
        @continue int

   SET @path = ''
   SET @continue = 1

   SELECT @rootHierarchyKey = RootHierarchyKey
     FROM Hierarchy
    WHERE HierarchyKey = @hierarchyKey

   WHILE @hierarchyKey is not null AND @hierarchyKey <> @rootHierarchyKey AND @continue > 0
   BEGIN
      SELECT TOP 1
             @path = DocumentMain.DocumentName + CASE WHEN LEN(@path) > 0 THEN '/' + @path ELSE '' END,
             @hierarchyKey = Hierarchy.ParentHierarchyKey,
             @rootHierarchyKey = Hierarchy.RootHierarchyKey
        FROM Hierarchy INNER JOIN DocumentMain on Hierarchy.UniformKey = DocumentMain.DocumentVersionKey
       WHERE Hierarchy.HierarchyKey = @hierarchyKey
         AND (DocumentMain.DocumentStatusCode IN (40,60) OR @publishedOnly = 0)
       ORDER BY DocumentMain.DocumentStatusCode ASC, DocumentMain.UpdatedOn DESC

      SET @continue = @@ROWCOUNT
   END

    IF (LTRIM(ISNULL(@urlPrefix,'')) <> '')
        SET @path = @urlPrefix + '/' + @path;

    SET @path = @path + '.aspx';

	-- Return the result of the function
	RETURN @path;
END
GO

