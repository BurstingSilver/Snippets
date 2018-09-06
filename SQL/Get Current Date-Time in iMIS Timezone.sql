DECLARE @CurrentDateTime DateTime;
SET @CurrentDateTime = DATEADD(MINUTE, (
  SELECT 
    CONVERT(numeric,ParameterValue) 
  FROM 
    SystemConfig 
  WHERE 
    ParameterName = 'System.Database.TimeZoneOffset'),GetUTCDate());
