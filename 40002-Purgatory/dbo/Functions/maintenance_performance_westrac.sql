
-- =============================================
-- Author:		Karl Daws
-- Create date: 21/Jul/2012
-- Description:	Function to return the availability, MTD availability, 
--				daily downtime for CAT equipment fleets.
--				Based off function [maintenance_performance_ex1900_2]
--
-- Modifications:
-- 26/Oct/2015 KDaws - Added 10T and 16M fleets
-- 02/Apr/2016 KDaws - Added 92K fleet
-- 24/Apr/2017 KDaws - Added 854 fleet
-- 16/May/2020 KDaws - Added 18M fleet
-- =============================================
CREATE FUNCTION [dbo].[maintenance_performance_westrac] 
(
	-- Add the parameters for the function here
	@date_from datetime, 
	@date_to datetime,
	@equip varchar(max)
)
RETURNS TABLE 
AS
RETURN 
(
with maintenance_table (day_count, shift_date, mtd_hours, down_hrs, contract_avail) AS
(
SELECT
day_count,
datetable.shift_date,
--fleet_count,
mtd_hours,
coalesce(down_hrs,0) AS down_hrs,
coalesce((24*fleet_count - down_hrs)/(24*fleet_count),0) as contract_avail
FROM (
	--Lists all days, fleets and number of equipment in each fleet
	SELECT
	day_count,
	COUNT(*) AS fleet_count,
	date AS shift_date,
	day_count * COUNT(*) * 24 AS mtd_hours
	FROM
	create_daterange(@date_from,@date_to) AS datetable,
	wencoreport.dbo.equip
	WHERE active = 'Y'
	AND test = 'N'
	AND fleet_ident IN ('85C','85D','992','92K','10R','10T','16G','16M','18M','WD','WC','854')
	AND equip_ident IN (SELECT item FROM dbo.String_split(@equip,','))
	GROUP BY day_count, date
) AS datetable

LEFT OUTER JOIN (
	--Down hours by fleet	
	SELECT
	shift_date,
	SUM(CAST(DATEDIFF(s, START_TIMESTAMP,ISNULL(END_TIMESTAMP, GETDATE())) AS numeric(18,2)) / 3600) as down_hrs
	FROM dbo.Z_WESTRAC_DOWN
	WHERE
		shift_date BETWEEN @date_from AND @date_to
		AND fleet_ident IN ('85C','85D','992','92K','10R','10T','16G','16M','18M','WD','WC','854')
		AND equip_ident IN (SELECT item FROM dbo.String_split(@equip,','))
	GROUP BY shift_date
) AS equip_stats
ON equip_stats.shift_date = datetable.shift_date
)

select 
m.shift_date,
m.day_count,
m.down_hrs as daily_down_hours,
(case WHEN m.contract_avail = 0 THEN 1 ELSE m.contract_avail END ) as daily_availability,
m.mtd_hours as mtd_total_hours,
(select sum(down_hrs) from maintenance_table where m.day_count >= maintenance_table.day_count) as mtd_down_hours,
(m.mtd_hours - (select sum(down_hrs) from maintenance_table where m.day_count >= maintenance_table.day_count)) / m.mtd_hours as mtd_availability
from maintenance_table as m
)