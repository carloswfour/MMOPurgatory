
-- =============================================
-- Author:		Scott Maynard
-- Create date: 17/08/2008
-- Description:	Generates a series of rows for a shift date broken down into hour portions for linking against transactions.
-- =============================================
CREATE FUNCTION [dbo].[create_shift_hour_ranges_inline] 
(
	-- Add the parameters for the function here
	@datefrom datetime, 
	@shift_ident int 
	 
)
RETURNS @shift_hour_ranges_inline
 TABLE
(
	-- Add the column definitions for the TABLE variable here
	shift_date datetime,
	shift_ident int,
	hour0 datetime,
	hour1 datetime, 
	hour2 datetime,
	hour3 datetime,
	hour4 datetime,
	hour5 datetime,
	hour6 datetime,
	hour7 datetime,
	hour8 datetime,
	hour9 datetime,
	hour10 datetime,
	hour11 datetime,
	hour12 datetime 

)
AS
BEGIN

insert into @shift_hour_ranges_inline
( 
	shift_date,
	shift_ident,
	hour0,
	hour1, 
	hour2,
	hour3,
	hour4,
	hour5,
	hour6,
	hour7,
	hour8,
	hour9,
	hour10,
	hour11,
	hour12 
)	

(
select top 1
@datefrom as shift_date,
@shift_ident as shift_ident,
CASE 
WHEN @shift_ident = 1 THEN dateadd(hh, 6, @datefrom)
ELSE dateadd(hh, 18, @datefrom) END AS hour0,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 7, @datefrom)
ELSE dateadd(hh, 19, @datefrom) END AS hour1
from WencoReport.dbo.haul_cycle_trans ) as hour1,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 8, @datefrom)
ELSE dateadd(hh, 20, @datefrom) END AS hour2
from WencoReport.dbo.haul_cycle_trans ) as hour2,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 9, @datefrom)
ELSE dateadd(hh, 21, @datefrom) END AS hour3
from WencoReport.dbo.haul_cycle_trans ) as hour3,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 10, @datefrom)
ELSE dateadd(hh, 22, @datefrom) END AS hour4
from WencoReport.dbo.haul_cycle_trans ) as hour4,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 11, @datefrom)
ELSE dateadd(hh, 23, @datefrom) END AS hour5
from WencoReport.dbo.haul_cycle_trans ) as hour5,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 12, @datefrom)
ELSE dateadd(hh, 24, @datefrom) END AS hour6
from WencoReport.dbo.haul_cycle_trans ) as hour6,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 13, @datefrom)
ELSE dateadd(hh, 25, @datefrom) END AS hour7
from WencoReport.dbo.haul_cycle_trans ) as hour7,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 14, @datefrom)
ELSE dateadd(hh, 26, @datefrom) END AS hour8
from WencoReport.dbo. haul_cycle_trans ) as hour8,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 15, @datefrom)
ELSE dateadd(hh, 27, @datefrom) END AS hour9
from WencoReport.dbo.haul_cycle_trans ) as hour9,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 16, @datefrom)
ELSE dateadd(hh, 28, @datefrom) END AS hour10
from WencoReport.dbo.haul_cycle_trans ) as hour10,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 17, @datefrom)
ELSE dateadd(hh, 29, @datefrom) END AS hour11
from WencoReport.dbo.haul_cycle_trans ) as hour11,

(select top 1
CASE 
WHEN @shift_ident = 1 
THEN dateadd(hh, 18, @datefrom)
ELSE dateadd(hh, 30, @datefrom) END AS hour12
from WencoReport.dbo.haul_cycle_trans ) as hour12

from WencoReport.dbo.haul_cycle_trans

)
	RETURN 

END