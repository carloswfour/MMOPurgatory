
-- =============================================
-- Author:		Scott Maynard
-- Create date: 17/08/2008
-- Description:	Generates a series of rows for a shift date broken down into hour portions for linking against transactions.
-- =============================================
CREATE FUNCTION [dbo].[create_shift_hour_ranges] 
(
	-- Add the parameters for the function here
	@datefrom datetime,
	@shift_ident int
	 
)
RETURNS @shift_hour_ranges
 TABLE
(
	-- Add the column definitions for the TABLE variable here
	shift_date datetime,
	shift_ident int,
	start_hour datetime, 
	end_hour datetime
)
AS
BEGIN

insert into @shift_hour_ranges
( 
	shift_date,
	shift_ident,
	start_hour,
	end_hour
)	

(
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 6, @datefrom)
ELSE dateadd(hh, 18, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 7, @datefrom)
ELSE dateadd(hh, 19, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,
CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 7, @datefrom)
ELSE dateadd(hh, 19, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 8, @datefrom)
ELSE dateadd(hh, 20, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 8, @datefrom)
ELSE dateadd(hh, 20, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 9, @datefrom)
ELSE dateadd(hh, 21, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 9, @datefrom)
ELSE dateadd(hh, 21, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 10, @datefrom)
ELSE dateadd(hh, 22, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 10, @datefrom)
ELSE dateadd(hh, 22, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 11, @datefrom)
ELSE dateadd(hh, 23, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 11, @datefrom)
ELSE dateadd(hh, 23, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 12, @datefrom)
ELSE dateadd(hh, 24, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 13, @datefrom)
ELSE dateadd(hh, 25, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 14, @datefrom)
ELSE dateadd(hh, 26, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 14, @datefrom)
ELSE dateadd(hh, 26, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 15, @datefrom)
ELSE dateadd(hh, 27, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 15, @datefrom)
ELSE dateadd(hh, 27, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 16, @datefrom)
ELSE dateadd(hh, 28, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 16, @datefrom)
ELSE dateadd(hh, 28, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 17, @datefrom)
ELSE dateadd(hh, 29, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans

union
select
@datefrom as shift_date,
@shift_ident as shift_ident,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 17, @datefrom)
ELSE dateadd(hh, 29, @datefrom) 
END AS start_hour,

CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 18, @datefrom)
ELSE dateadd(hh, 30, @datefrom) 
END AS end_hour

from WencoReport.dbo.haul_cycle_trans
)
	RETURN 

END