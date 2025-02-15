
-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	Searches for a string within a string and returns the last starting position
--
-- Example: @char = '-', @expression = '18.3-432-157', returns 9
-- 
-- Modified: 
-- v1.1 22/Aug/2015 KDaws - @expression and @char are the wrong way around, won't handle strings longer than 10
-- =============================================

CREATE FUNCTION [dbo].[LastPosition] (
	@char varchar(10),	--Expression to find
	@expression varchar(1000) --Expression being searched
)
RETURNS varchar(1000)
AS
BEGIN

	DECLARE @pos int
	DECLARE @lastpos int
	SET @pos=0

	--CHARINDEX ( expressionToFind ,expressionToSearch [ , start_location ] ) 
	SET @pos=CHARINDEX(@char,@expression,@pos)

	WHILE(@pos)>0
	BEGIN
	SET @lastpos=@pos
	SET @pos=CHARINDEX(@char,@expression,@pos+1)
	END

	RETURN @lastpos

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LastPosition] TO [MiningReportViewer]
    AS [dbo];

