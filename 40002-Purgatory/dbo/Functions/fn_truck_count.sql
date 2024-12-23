
-- =============================================
-- Author:		Karl Daws
-- Create date: 27/6/2010
-- Description:	Returns the number of trucks that are assigned to a loading unit
-- =============================================

CREATE FUNCTION [dbo].[fn_truck_count]
(
@shift_date datetime,
@shift_ident varchar(1),
@LU varchar(4),
@load_loc varchar(24),
@dump_loc varchar(24),
@incr int
)

RETURNS decimal(6,3)
AS
BEGIN
DECLARE @start_hour as int
DECLARE @truck_count as decimal(6,3)
DECLARE @date as datetime
SET @truck_count = 0

/*** DAY SHIFT ***/
IF (@shift_ident = '1')
BEGIN
	SET @date = @shift_date
	SET @start_hour = 6
	WHILE (@start_hour < 18)
	BEGIN
		SELECT @truck_count = @truck_count + COUNT(HAULING_UNIT_IDENT) 
		FROM (SELECT LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT
			FROM WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT
			WHERE (HCT.LOADING_UNIT_IDENT LIKE @LU) AND (HCT.LOAD_LOCATION_SNAME LIKE @load_loc) AND (HCT.DUMP_LOCATION_SNAME LIKE @dump_loc) AND LOAD_START_TIMESTAMP BETWEEN dateadd(hh, cast(@start_hour as int), @date) AND dateadd(hh, cast((@start_hour + @incr) as int), @date) AND (DUMP_END_SHIFT_DATE = @shift_date) AND (DUMP_END_SHIFT_IDENT = @shift_ident)
			GROUP BY LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT) AS truck_tbl
		SET @start_hour = @start_hour + @incr
	END
END
ELSE --(@shift_ident = '2')
/*** NIGHT SHIFT ***/
BEGIN	
	/* 6pm-midnight */
	SET @date = @shift_date
	SET @start_hour = 18
	WHILE (@start_hour < 24)
	BEGIN
		SELECT @truck_count = @truck_count + COUNT(HAULING_UNIT_IDENT) 
		FROM (SELECT LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT
			FROM WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT
			WHERE (HCT.LOADING_UNIT_IDENT LIKE @LU) AND (HCT.LOAD_LOCATION_SNAME LIKE @load_loc) AND (HCT.DUMP_LOCATION_SNAME LIKE @dump_loc) AND LOAD_START_TIMESTAMP BETWEEN dateadd(hh, cast(@start_hour as int), @date) AND dateadd(hh, cast((@start_hour + @incr) as int), @date) AND (DUMP_END_SHIFT_DATE = @shift_date) AND (DUMP_END_SHIFT_IDENT = @shift_ident)
			GROUP BY LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT) AS truck_tbl
		SET @start_hour = @start_hour + @incr
	END
	
	/* midnight-6am */
	SET @date = dateadd(d,1,@shift_date)
	SET @start_hour = 0
	WHILE (@start_hour < 6)
	BEGIN
		SELECT @truck_count = @truck_count + COUNT(HAULING_UNIT_IDENT) 
		FROM (SELECT LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT
			FROM WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT
			WHERE (HCT.LOADING_UNIT_IDENT LIKE @LU) AND (HCT.LOAD_LOCATION_SNAME LIKE @load_loc) AND (HCT.DUMP_LOCATION_SNAME LIKE @dump_loc) AND LOAD_START_TIMESTAMP BETWEEN dateadd(hh, cast(@start_hour as int), @date) AND dateadd(hh, cast((@start_hour + @incr) as int), @date) AND (DUMP_END_SHIFT_DATE = @shift_date) AND (DUMP_END_SHIFT_IDENT = @shift_ident)
			GROUP BY LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, HAULING_UNIT_IDENT) AS truck_tbl
		SET @start_hour = @start_hour + @incr
	END
END

RETURN(@truck_count/12*@incr)
END