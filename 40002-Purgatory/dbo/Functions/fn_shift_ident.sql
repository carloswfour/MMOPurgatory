
-- =============================================
-- Author:		KDaws
-- Create date: 19/Oct/10
-- Description:	Function to convert shift_date and start_hour {6-29} into shift_ident
-- =============================================
CREATE FUNCTION [dbo].[fn_shift_ident]
(	
	@shift_date datetime,
	@start_hour int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	@shift_date AS shift_date,
	CASE WHEN @start_hour BETWEEN 6 AND 17 --DAYSHIFT
	THEN 1
	WHEN @start_hour BETWEEN 18 AND 29 --NIGHTSHIFT
	THEN 2
	ELSE 0 --Scenario where start_hour is invalid number
	END AS shift_ident,
	@start_hour AS start_hour
)