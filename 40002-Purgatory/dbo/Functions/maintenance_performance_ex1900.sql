
-- =============================================
-- Author:		Scott Maynard
-- Create date: 30/09/09
-- Description:	Function to return the availability,MTD availability, 
--				daily downtime and utilisation for EX1900 excavators.
--
-- Changes - 31/12/09
-- Changed downtime events to only include contract maint events as requested by KW.
-- 
-- Changes - 20/8/10
-- Modified to exclude some statuses/sub-statuses which are under contract maint status categories
--
-- Changes - 16/10/11 - KDaws
-- Removed unused column data to improve report efficiency
--
-- 25/Feb/2015 KDaws
-- Modified to vary calendar hours as EX1900-5 fleet is decommissioned unit by unit
-- Inadvertently fixed issue with daily avail calculation
--
-- 13/Apr/2020 KDaws
-- X300 removed
-- =============================================
CREATE FUNCTION [dbo].[maintenance_performance_ex1900] 
(
	-- Add the parameters for the function here
	@date_from datetime, 
	@date_to datetime
)
RETURNS TABLE 
AS
RETURN (
	WITH maintenance_table (day_count, shift_date, calendar_hrs, down_hrs, contract_avail) AS (
		SELECT
		day_count,
		shift_date,
		calendar_hrs,
		COALESCE(down_hrs,0) AS down_hrs,
		COALESCE((calendar_hrs - down_hrs) / calendar_hrs, 0) AS contract_avail
		FROM (
			SELECT
			day_count,
			date AS shift_date,
			CASE
				WHEN date >= '4/18/18' THEN 24*1 --X300 decommissioned 18/Apr/18
				WHEN date >= '1/5/16' THEN 24*2 --X200 decommissioned 5/Jan/16
				WHEN date >= '1/23/15' THEN 24*3 --X500 decommissioned 23/Jan/15
				ELSE 24*4
			END AS calendar_hrs,
			equip_stats.down_hrs
			FROM create_daterange(@date_FROM,@date_to) AS datetable
			LEFT OUTER JOIN (
				SELECT
				Z_HITACHI_DOWN.shift_date,
				SUM(CAST(DATEDIFF(s, Z_HITACHI_DOWN.START_TIMESTAMP,ISNULL(Z_HITACHI_DOWN.END_TIMESTAMP, GETDATE())) AS numeric(18,2)) / 3600) AS down_hrs
				FROM dbo.Z_HITACHI_DOWN
				WHERE
				Z_HITACHI_DOWN.shift_date BETWEEN @date_FROM AND @date_to
				AND Z_HITACHI_DOWN.equip_ident IN ('X200','X300','X400','X500')
				GROUP BY Z_HITACHI_DOWN.SHIFT_DATE
			) AS equip_stats
			ON equip_stats.shift_date = datetable.date
		) a
	)

	SELECT 
	m.shift_date,
	m.day_count,
	m.down_hrs AS daily_down_hours,
	(CASE WHEN m.contract_avail = 0 THEN 1 ELSE m.contract_avail END) AS daily_availability,
	(SELECT SUM(calendar_hrs) FROM maintenance_table WHERE m.day_count >= maintenance_table.day_count) AS mtd_total_hours,
	(SELECT SUM(down_hrs) FROM maintenance_table WHERE m.day_count >= maintenance_table.day_count) AS mtd_down_hours,
	((SELECT SUM(calendar_hrs) FROM maintenance_table WHERE m.day_count >= maintenance_table.day_count) - (SELECT SUM(down_hrs) FROM maintenance_table WHERE m.day_count >= maintenance_table.day_count)) / (SELECT SUM(calendar_hrs) FROM maintenance_table WHERE m.day_count >= maintenance_table.day_count) AS mtd_availability,
	87.5 AS target_avail
	FROM maintenance_table AS m

)