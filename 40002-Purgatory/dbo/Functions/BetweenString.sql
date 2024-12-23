

CREATE function [dbo].[BetweenString] 
(@expression VARCHAR(1000), 
@startchar VARCHAR(10),
@endchar VARCHAR(10))
returns VARCHAR(1000)
as
begin

DECLARE @returnString VARCHAR(1000)
DECLARE @start INT
DECLARE @end INT

IF @expression IS NULL OR LEN(@expression) < 3
RETURN NULL
ELSE
SET @start = CHARINDEX(@startchar,@expression,1);
SET @end = CHARINDEX(@endchar,@expression,@start + 1);

IF @end = @start + 1
RETURN NUll
ELSE
SET @returnString = SUBSTRING(@expression,@start + 1,@end - (@start + 1))

return @returnString
end