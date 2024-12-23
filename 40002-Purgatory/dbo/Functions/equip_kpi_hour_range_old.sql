
-- =============================================
-- Author:		Karl Daws	
-- Create date: 15/10/10
-- Description:	Calculates equipment KPI by hour
--				Used for calculating cost per tonne
-- =============================================
CREATE FUNCTION [dbo].[equip_kpi_hour_range_old]
(	
	@shift_date datetime,
	@shift_ident int
)

RETURNS @hour_range
TABLE (
	shift_date datetime,
	shift_ident int,
	start_hour datetime,
	eqmodel_code varchar(15),
	equip_desc varchar(35)--,
	--UTIL varchar
/*,
	MINE_AVAIL numeric(18,3),
	CONT_AVAIL numeric(18,3),
	USE_AVAIL numeric(18,3),
	EFFICIENCY numeric(18,3),
	MTTR numeric(18,3),
	MTBF numeric(18,3),
	failures int,
	fleet_count int,
	wet_tonnes numeric(18,2),
	num_loads int,
	CAL int,
	OPER numeric(18,3),
	EFFIC numeric(18,3),
	INEFFIC numeric(18,3),
	ANCIL numeric(18,3),
	AUX numeric(18,3),
	[DELAY] numeric(18,3),
	SCHED numeric(18,3),
	UNSCHED numeric(18,3),
	DOWN numeric(18,3),
	CONT_PLN numeric(18,3),
	CONT_BKD numeric(18,3),
	MMO_PLN numeric(18,3),
	MMO_BKD numeric(18,3),
	[STANDBY] numeric(18,3),
	NOT_USED numeric(18,3),
	LOST numeric(18,3),
	ERROR numeric(18,2),
	LU_LOAD numeric(18,3),
	HU_LOAD numeric(18,3),
	PRODUCTIVITY numeric(18,2),
	DIGABILITY numeric(18,2)*/
)
AS BEGIN



IF (@shift_ident = 1)
BEGIN
	INSERT INTO @hour_range
	SELECT
	@shift_date as shift_date,
	@shift_ident as shift_ident,
	start_hour,
	eqmodel_code,
	equip_desc--,
--	UTIL
/*,
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
	CAL,
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
	ERROR,
	LU_LOAD,
	HU_LOAD,
	PRODUCTIVITY,
	DIGABILITY*/
	FROM
	equip_kpi_hour(@shift_date,6)



END
ELSE IF (@shift_ident = 2)
BEGIN
	INSERT INTO @hour_range
	SELECT
	@shift_date as shift_date,
	@shift_ident as shift_ident,
	start_hour,
	eqmodel_code,
	equip_desc
	FROM
	equip_kpi_hour(@shift_date,18)
END

/*
ELSE BEGIN
		SELECT
		@shift_date as shift_date,
		@shift_ident as shift_ident
		--FROM
		--equip_kpi_hour(@shift_date,18)
END
*/

RETURN

END