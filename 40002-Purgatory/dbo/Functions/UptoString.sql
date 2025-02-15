

CREATE function [dbo].[UptoString] 
(@expression VARCHAR(1000), 
@endchar VARCHAR(10))
returns VARCHAR(1000)
as
begin

DECLARE @returnString VARCHAR(1000)
DECLARE @end INT

IF @expression IS NULL OR LEN(@expression) < 2
RETURN NULL
ELSE
SET @end = CHARINDEX(@endchar,@expression);

IF @end = 1 OR @end = 0
RETURN NUll
ELSE
SET @returnString = SUBSTRING(@expression,1,@end - 1)

return @returnString
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UptoString] TO [MiningReportViewer]
    AS [dbo];

