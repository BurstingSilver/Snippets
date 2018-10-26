DECLARE @MeetingCode varchar(20) = '2018BAR';
DECLARE @DisplayOption bit = 0;
DECLARE @IsAutoEnroll bit = 0;

SELECT 
	Product_Function.PRODUCT_CODE, 
	RegOptions.PRODUCT_CODE AS REG_OPTION_PRODUCT_CODE, 
	'INSERT INTO EventRelatedFunction (EventRelatedFunctionKey, EventFunctionKey, EventRegistrationOptionKey, DisplayOption, IsAutoEnroll) VALUES (NEWID(), ''' + Product_Function.PRODUCT_CODE + ''', ''' + RegOptions.PRODUCT_CODE + ''', ' + CONVERT(varchar,@DisplayOption) + ', ' + CONVERT(varchar,@IsAutoEnroll) + ')' AS INSERT_STATEMENT 
FROM 
	Product_Function, 
	(SELECT DISTINCT 
		Product.PRODUCT_CODE 
	FROM 
		Product INNER JOIN 
		Product_Function AS EventRegOptions ON EventRegOptions.PRODUCT_CODE = Product.PRODUCT_CODE 
	WHERE 
		Product.PRODUCT_MAJOR = @MeetingCode AND 
		EventRegOptions.IS_EVENT_REGISTRATION_OPTION = 1) AS RegOptions 
WHERE 
	Product_Function.IS_EVENT_REGISTRATION_OPTION = 0 AND 
	Product_Function.PRODUCT_CODE LIKE @MeetingCode + '/%' AND 
	Product_Function.PRODUCT_CODE + '|' + RegOptions.PRODUCT_CODE NOT IN (SELECT EventRelatedFunction.EventFunctionKey + '|' + EventRelatedFunction.EventRegistrationOptionKey FROM EventRelatedFunction) 
ORDER BY 
	Product_Function.PRODUCT_CODE, 
	REG_OPTION_PRODUCT_CODE
