
-- =============================================
-- Author:		Tim Smith
-- Create date: 17/10/2009
-- Description:	returns dry tonnes based on rock domains or material type
-- =============================================
CREATE FUNCTION [dbo].[send_offroute_test] 
(
)
RETURNS int
AS
BEGIN 

EXEC msdb.dbo.sp_send_dbmail @recipients='61408928569@sms.tim.telstra.com', --Wenco Pit Controllers Mobile #
			@subject = 'OFF ROUTE TEST',
			@body = 'OFF ROUTE TEST'

RETURN 1

END