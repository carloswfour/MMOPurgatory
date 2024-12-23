
-- =============================================
-- Author:		Karl Daws	
-- Create date: 23/1/11
-- Description:	Equipment KPI by hour by unit
--				Used for general KPI calculations per hour
--
--12Jun KDaws - Created new temporary function for digger productivity/digability calcs
--				Original function has a flaw in that the link between a haul cycle and statuses is via dump_timestamp not load_timestamp...
-- =============================================
CREATE FUNCTION [dbo].[equip_kpi_hour_per_unit_digger_temp]
(	
	@shift_date datetime,
	@start_hour int --values 6-29
)

RETURNS TABLE
AS
RETURN(
	SELECT
	time_kpi.start_hour,
	time_kpi.shift_date, 
	time_kpi.shift_ident,
	time_kpi.equip_ident,
	time_kpi.eqmodel_code,
	equip_desc,
	UTIL,
	MINE_AVAIL,
	CONT_AVAIL,
	USE_AVAIL,
	EFFICIENCY,
	MTTR,
	MTBF,
	failures,
	fleet_count,
	wet_tonnes,
	num_loads,
	(1) AS CAL,
	OPER,
	EFFIC,
	INEFFIC,
	ANCIL,
	AUX,
	[DELAY],
	SCHED,
	UNSCHED,
	DOWN,
	CONT_PLN,
	CONT_BKD,
	MMO_PLN,
	MMO_BKD,
	[STANDBY],
	NOT_USED,
	LOST,
	(1) - (CONT_PLN + CONT_BKD + MMO_PLN + MMO_BKD + EFFIC + INEFFIC + ANCIL + AUX + SCHED + UNSCHED + NOT_USED + LOST) AS ERROR,
	LU_LOAD,
	HU_LOAD,
	CASE WHEN (EFFIC+INEFFIC) > 0 THEN wet_tonnes/(EFFIC+INEFFIC) ELSE 0 END as PRODUCTIVITY, --DIRECT not OPER
	CASE WHEN LU_LOAD > 0 THEN wet_tonnes/LU_LOAD ELSE 0 END as DIGABILITY
	FROM(
		SELECT
		ESHS.start_hour,
		ESHS.shift_date,
 		ESHS.shift_ident,
		ESHS.equip_ident,
		ESHS.eqmodel_code,
		equip_desc,
		SUM((CASE WHEN statuscat_code in ('LU_LOAD') THEN duration_min/60 ELSE 0 END)) as LU_LOAD,
		SUM((CASE WHEN statuscat_code in ('HU_LOAD') THEN duration_min/60 ELSE 0 END)) as HU_LOAD,
		SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END)) as OPER, --'OPER' in Wenco terms is any N% code
		SUM((CASE WHEN statuscat_code in ('SCHED','UNSCHED') THEN duration_min/60 ELSE 0 END)) as [DELAY], --'DELAY' in Wenco terms is any O% code
		SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END)) as [DOWN], --'DOWN' is any M% code
		SUM((CASE WHEN statuscat_code in ('NOT_USED','LOST') THEN duration_min/60 ELSE 0 END)) as [STANDBY], --'STANDBY' is any S% code
		SUM((CASE WHEN statuscat_code in ('CONT_PLN') THEN duration_min/60 ELSE 0 END)) as [CONT_PLN],
		SUM((CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min/60 ELSE 0 END)) as [CONT_BKD],
		SUM((CASE WHEN statuscat_code in ('MMO_PLN') THEN duration_min/60 ELSE 0 END)) as [MMO_PLN],
		SUM((CASE WHEN statuscat_code in ('MMO_BKD') THEN duration_min/60 ELSE 0 END)) as [MMO_BKD],
		SUM((CASE WHEN statuscat_code in ('EFFIC') THEN duration_min/60 ELSE 0 END)) as [EFFIC],
		SUM((CASE WHEN statuscat_code in ('INEFFIC') THEN duration_min/60 ELSE 0 END)) as [INEFFIC],
		SUM((CASE WHEN statuscat_code in ('ANCIL') THEN duration_min/60 ELSE 0 END)) as [ANCIL],
		SUM((CASE WHEN statuscat_code in ('AUX') THEN duration_min/60 ELSE 0 END)) as [AUX],
		SUM((CASE WHEN statuscat_code in ('SCHED') THEN duration_min/60 ELSE 0 END)) as [SCHED],
		SUM((CASE WHEN statuscat_code in ('UNSCHED') THEN duration_min/60 ELSE 0 END)) as [UNSCHED],
		SUM((CASE WHEN statuscat_code in ('NOT_USED') THEN duration_min/60 ELSE 0 END)) as [NOT_USED],
		SUM((CASE WHEN statuscat_code in ('LOST') THEN duration_min/60 ELSE 0 END)) as [LOST],
		SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END))/(1 * fleet_count) as UTIL,
		((1 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END)))/(1 * fleet_count) as MINE_AVAIL,
		((1 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD') THEN duration_min/60 ELSE 0 END)))/(1 * fleet_count) as CONT_AVAIL,
		CASE WHEN ((1 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END))) > 0 
			THEN SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END))/((1 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END))) ELSE 0 END as USE_AVAIL,
		CASE WHEN SUM(CASE WHEN statuscat_code in ('EFFIC','INEFFIC')  THEN duration_min/60 ELSE 0 END) > 0 
			THEN SUM((CASE WHEN statuscat_code in ('EFFIC') THEN duration_min/60 ELSE 0 END))/SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC') THEN duration_min/60 ELSE 0 END)) ELSE 0 END as EFFICIENCY,
		CASE WHEN COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) > 0
			THEN SUM(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min/60 ELSE 0 END) /  COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) ELSE 0 END as MTTR,
		CASE WHEN COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) > 0
			THEN SUM(CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END) /  COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) ELSE 0 END as MTBF,
		COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) AS failures,
		fleet_count
		FROM WencoReport.dbo.EQUIP_STATUS_HOUR_SUMMARY(@shift_date, @start_hour) AS ESHS
		INNER JOIN(
		SELECT eqmodel_code, descrip, COUNT(*) AS fleet_count
		FROM WencoReport.dbo.equip
		WHERE active = 'Y'
		AND test = 'N'
		GROUP BY eqmodel_code, descrip
		) AS e 
		ON e.eqmodel_code = ESHS.eqmodel_code
		AND e.descrip = ESHS.equip_desc
		AND fleet_count > 0
		GROUP BY
		ESHS.start_hour,
		ESHS.shift_date,
		ESHS.shift_ident,
		ESHS.equip_ident,
		ESHS.eqmodel_code,
		equip_desc,
		fleet_count
	) AS time_kpi
	
	--left join here because HCT does not contain a material transaction for all time events
	LEFT JOIN(
	SELECT load_start_shift_date AS shift_date, load_start_shift_ident as shift_ident, equip_ident, eqmodel_code, SUM(quantity_reporting) AS wet_tonnes, COUNT(*) AS num_loads 
	FROM WencoReport.dbo.haul_cycle_trans AS hct
	INNER JOIN WencoReport.dbo.equip AS e
	ON (hct.loading_unit_ident = e.equip_ident OR hct.hauling_unit_ident = e.equip_ident)
	WHERE hct.load_start_shift_date = @shift_date
	AND load_start_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
	GROUP BY load_start_shift_date, load_start_shift_ident, e.equip_ident, eqmodel_code
	) AS movements
	ON movements.eqmodel_code = time_kpi.eqmodel_code
	AND movements.shift_date = time_kpi.shift_date
	AND movements.shift_ident = time_kpi.shift_ident
	AND movements.equip_ident = time_kpi.equip_ident
)