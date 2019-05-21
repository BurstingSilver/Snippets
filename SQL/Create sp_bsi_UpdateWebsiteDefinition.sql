SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Justin Trout, BSI
-- Create date: 2019-04-04
-- Description:	Given a Website's DocumentVersionKey from DocumentMain, a node name to update, and a new value, updates the blob with the provided value
-- =============================================
DROP PROCEDURE IF EXISTS sp_bsi_UpdateWebsiteDefinition
GO

CREATE PROCEDURE sp_bsi_UpdateWebsiteDefinition 
    @documentVersionKey uniqueidentifier, 
    @nodeValueToUpdate varchar(255), 
    @newNodeValue varchar(max) 
AS 
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @string XML;

    SET @string = (
        SELECT 
            CAST(CAST(DocumentMain.Blob AS varbinary(MAX)) AS varchar(MAX)) 
        FROM 
            DocumentMain 
        WHERE 
            DocumentMain.DocumentVersionKey = @DocumentVersionKey AND 
            DocumentMain.DocumentStatusCode = 40) 

    SET @string.modify('
        declare namespace ns="http://schemas.imis.com/2008/01/DataContracts/Website";
        replace value of (/ns:Website/ns:*[local-name()=sql:variable("@nodeValueToUpdate")]/text())[1] with sql:variable("@newNodeValue")');

    --PRINT CAST(@string AS varchar(MAX));

    UPDATE 
        DocumentMain 
    SET 
        Blob = CONVERT(varchar(MAX), @string) 
    WHERE 
        DocumentMain.DocumentVersionKey = @documentVersionKey AND 
        DocumentMain.DocumentStatusCode = 40 
END
GO
