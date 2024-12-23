
create VIEW [dbo].[Z_EQUIP_KPI_BY_MODEL]
AS

-- =============================================
-- Author:		Tim Smith
-- Create date: 24/Jan/2012
-- Description:	Calculates all KPI's for all equipment per shift
-- 
-- Modified:
-- KDaws 12Oct10-15Oct10
-- Added all categories from Murrin KPI's as columns, calculate OPER, DELAY etc from their sub-categories
-- Made ERROR column, should be close to 0, if not there is an issue with statuses being assigned to status categories
-- Changed calculation for PRODCTIVITY, should use EFFIC+INEFFIC (direct) hours, not OPER
-- Issue with CONT_AVAIL calculation, typo in statuscat_code IN statement
-- Added join on e.descrip. Fleet count wasn't calculating correctly for equipment with same eqmodel_code, but different descrip.
--
-- KDaws 21Oct10 - Added shift_ident
--
-- KDaws 8Feb11 - Needs to group by equip_desc when calculating wet_tonnes
--
-- KDaws 11Nov12 - Renamed to [Z_EQUIP_KPI_BY_MODEL]
--
-- KDaws 1Nov13 - Added equipment exceptions
-- =============================================


SELECT
time_kpi.shift_date,
time_kpi.shift_ident,
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
12*fleet_count AS CAL,
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
(12 * fleet_count) - (CONT_PLN + CONT_BKD + MMO_PLN + MMO_BKD + EFFIC + INEFFIC + ANCIL + AUX + SCHED + UNSCHED + NOT_USED + LOST) AS ERROR,
LU_LOAD,
HU_LOAD,
CASE WHEN (EFFIC+INEFFIC) > 0 THEN wet_tonnes/(EFFIC+INEFFIC) ELSE 0 END AS PRODUCTIVITY, --DIRECT not OPER
CASE WHEN LU_LOAD > 0 THEN wet_tonnes/LU_LOAD ELSE 0 END AS DIGABILITY

FROM (
	SELECT
	ZESS.shift_date, 
	ZESS.shift_ident,
	ZESS.eqmodel_code,
	equip_desc,
	SUM((CASE WHEN statuscat_code in ('LU_LOAD') THEN duration_min/60 ELSE 0 END)) AS LU_LOAD,
	SUM((CASE WHEN statuscat_code in ('HU_LOAD') THEN duration_min/60 ELSE 0 END)) AS HU_LOAD,
	SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END)) AS OPER, --'OPER' in Wenco terms is any N% code
	SUM((CASE WHEN statuscat_code in ('SCHED','UNSCHED') THEN duration_min/60 ELSE 0 END)) AS [DELAY], --'DELAY' in Wenco terms is any O% code
	SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END)) AS [DOWN], --'DOWN' is any M% code
	SUM((CASE WHEN statuscat_code in ('NOT_USED','LOST') THEN duration_min/60 ELSE 0 END)) AS [STANDBY], --'STANDBY' is any S% code
	SUM((CASE WHEN statuscat_code in ('CONT_PLN') THEN duration_min/60 ELSE 0 END)) AS [CONT_PLN],
	SUM((CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min/60 ELSE 0 END)) AS [CONT_BKD],
	SUM((CASE WHEN statuscat_code in ('MMO_PLN') THEN duration_min/60 ELSE 0 END)) AS [MMO_PLN],
	SUM((CASE WHEN statuscat_code in ('MMO_BKD') THEN duration_min/60 ELSE 0 END)) AS [MMO_BKD],
	SUM((CASE WHEN statuscat_code in ('EFFIC') THEN duration_min/60 ELSE 0 END)) AS [EFFIC],
	SUM((CASE WHEN statuscat_code in ('INEFFIC') THEN duration_min/60 ELSE 0 END)) AS [INEFFIC],
	SUM((CASE WHEN statuscat_code in ('ANCIL') THEN duration_min/60 ELSE 0 END)) AS [ANCIL],
	SUM((CASE WHEN statuscat_code in ('AUX') THEN duration_min/60 ELSE 0 END)) AS [AUX],
	SUM((CASE WHEN statuscat_code in ('SCHED') THEN duration_min/60 ELSE 0 END)) AS [SCHED],
	SUM((CASE WHEN statuscat_code in ('UNSCHED') THEN duration_min/60 ELSE 0 END)) AS [UNSCHED],
	SUM((CASE WHEN statuscat_code in ('NOT_USED') THEN duration_min/60 ELSE 0 END)) AS [NOT_USED],
	SUM((CASE WHEN statuscat_code in ('LOST') THEN duration_min/60 ELSE 0 END)) AS [LOST],
	SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END))/(12 * fleet_count) AS UTIL,
	((12 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END)))/(12 * fleet_count) AS MINE_AVAIL,
	((12 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD') THEN duration_min/60 ELSE 0 END)))/(12 * fleet_count) AS CONT_AVAIL,
	CASE WHEN ((12 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END))) > 0 
		THEN SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END))/((12 * fleet_count)-SUM((CASE WHEN statuscat_code in ('CONT_PLN','CONT_BKD','MMO_PLN','MMO_BKD') THEN duration_min/60 ELSE 0 END))) ELSE 0 END AS USE_AVAIL,
	CASE WHEN SUM(CASE WHEN statuscat_code in ('EFFIC','INEFFIC')  THEN duration_min/60 ELSE 0 END) > 0 
		THEN SUM((CASE WHEN statuscat_code in ('EFFIC') THEN duration_min/60 ELSE 0 END))/SUM((CASE WHEN statuscat_code in ('EFFIC','INEFFIC') THEN duration_min/60 ELSE 0 END)) ELSE 0 END AS EFFICIENCY,
	CASE WHEN COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) > 0
		THEN SUM(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min/60 ELSE 0 END) /  COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) ELSE 0 END AS MTTR,
	CASE WHEN COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) > 0
		THEN SUM(CASE WHEN statuscat_code in ('EFFIC','INEFFIC','ANCIL','AUX') THEN duration_min/60 ELSE 0 END) /  COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) ELSE 0 END AS MTBF,
	COUNT(CASE WHEN statuscat_code in ('CONT_BKD') THEN duration_min ELSE NULL END) AS failures,
	fleet_count
	FROM Z_EQUIP_STATUS_SUMMARY AS ZESS
	INNER JOIN (
		SELECT eqmodel_code, descrip, COUNT(equip_ident) AS fleet_count
		FROM WencoReport.dbo.equip
		WHERE active = 'Y'
		AND test = 'N'
		AND equip_ident NOT LIKE 'T9%'
		AND equip_ident NOT IN ('E262','W999')
		AND eqmodel_code NOT IN ('BRT','WencoCPU','ST02','EX200','EX210')
		GROUP BY eqmodel_code, descrip
	) AS e 
	ON e.eqmodel_code = ZESS.eqmodel_code AND e.descrip = ZESS.equip_desc AND fleet_count > 0
	GROUP BY
	ZESS.shift_date,
	ZESS.shift_ident,
	ZESS.eqmodel_code,
	ZESS.equip_desc,
	fleet_count
) AS time_kpi

--left join here because HCT does not contain a material transaction for all time events
LEFT JOIN (
	SELECT
	dump_end_shift_date AS shift_date,
	dump_end_shift_ident AS shift_ident,
	eqmodel_code,
	descrip,
	SUM(quantity_reporting) AS wet_tonnes,
	COUNT(haul_cycle_rec_ident) AS num_loads 
	FROM WencoReport.dbo.haul_cycle_trans AS hct
	INNER JOIN WencoReport.dbo.equip AS e
	ON (hct.loading_unit_ident = e.equip_ident OR hct.hauling_unit_ident = e.equip_ident)
	GROUP BY dump_end_shift_date, dump_end_shift_ident, eqmodel_code, descrip
) AS movements
ON movements.eqmodel_code = time_kpi.eqmodel_code
AND movements.descrip = time_kpi.equip_desc
AND movements.shift_date = time_kpi.shift_date
AND movements.shift_ident = time_kpi.shift_ident