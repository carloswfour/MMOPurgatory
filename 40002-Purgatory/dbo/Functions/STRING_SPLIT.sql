
CREATE FUNCTION [dbo].[STRING_SPLIT]
(
      @expression                               NVARCHAR(4000)
    , @delimiter                                NCHAR(1)
)
RETURNS 
    @list TABLE
    (
		sequence                                INT 
      ,  item                                    NVARCHAR(4000)
      
    )
AS
BEGIN
    
    DECLARE
          @index                                INT
        , @last_start                           INT
        , @slice                                NVARCHAR(4000)
        , @sequence                             INT 
    ;

    IF ((@expression IS NOT NULL) AND (@delimiter IS NOT NULL))
    BEGIN
        SET @sequence = 0;
        SET @last_start = 1;
        SET @index = CHARINDEX(@delimiter, @expression);

        WHILE (@index > 0)
        BEGIN
            SET @slice = SUBSTRING(@expression, @last_start, @index - @last_start);
            INSERT INTO @list(item, sequence) VALUES (@slice, @sequence);
            SET @last_start = @index + 1;
            SET @sequence = @sequence + 1;
            SET @index = CHARINDEX(@delimiter, @expression, @last_start);            
        END;    -- end while      

        -- add last one in (i.e. text after last delimiter)
        SET @slice = RIGHT(@expression, LEN(@expression) - @last_start + 1);
        INSERT INTO @list(sequence, item ) VALUES (@sequence, @slice );
        
    END; 
    
    RETURN;
END;