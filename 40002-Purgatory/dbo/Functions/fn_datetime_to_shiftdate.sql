
-- =============================================
-- Author:		Karl Daws	
-- Create date: 21/10/10
-- Description:	Calculate shift_date and shift_ident from datetime
--				
-- =============================================
CREATE FUNCTION [dbo].[fn_datetime_to_shiftdate]
(	
	@timestamp datetime
)

RETURNS TABLE
AS
RETURN(

	SELECT
	@timestamp AS timestamp,	
	CASE
	--Before 06:00	
	WHEN datediff(hh,CONVERT(datetime,FLOOR(CONVERT(NUMERIC(18,9),@timestamp))),@timestamp) < 6
	THEN dateadd(d, -1, CONVERT(datetime,FLOOR(CONVERT(NUMERIC(18,9),@timestamp))))
	ELSE CONVERT(datetime,FLOOR(CONVERT(NUMERIC(18,9),@timestamp)))
	END AS shift_date,

	--Before 06:00 - NIGHTSHIFT
	CASE WHEN datediff(hh,CONVERT(datetime,FLOOR(CONVERT(NUMERIC(18,9),@timestamp))),@timestamp) < 6
	OR datediff(hh,CONVERT(datetime,FLOOR(CONVERT(NUMERIC(18,9),@timestamp))),@timestamp) >= 18
	THEN 2
	--06:00 to 18:00
	ELSE 1
	END AS shift_ident	

)