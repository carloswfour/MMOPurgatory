
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[create_daterange] 
(	
	-- Add the parameters for the function here
	@date_from datetime, 
	@date_to datetime
)

RETURNS TABLE 
AS
RETURN 

(

WITH cte AS
(
SELECT 1 as day_count, @date_from AS date
	UNION ALL
		SELECT day_count + 1, DATEADD(day, day_count, @date_from )
	FROM cte
	WHERE DATEADD( day, day_count, @date_from ) <= @date_to
)

select * from cte
)