
-- =============================================
-- Author:		Karl Daws	
-- Create date: 18Apr11
-- Description:	Created view for 'SMU Engine Hours' Report to point at.
--				Can query by shift
--
-- v1.1 26/Jul/2011 FEshraghi - Added 'flt_id' field to return the FLT_FLEET_IDENT from FLEET.
-- v1.2 26/Jun/2014 KDaws - Included 'DBEDIT' for METER_SOURCE.
-- v1.3 03/Oct/2015 KDaws - Modfiied to use most recent date, not max date for the start date.
-- v1.4 19/Apr/2020 KDaws - Wenco supports 6 digit equip_ident's, changed to varchar(6).
-- =============================================
CREATE FUNCTION [dbo].[fn_smu_hour_by_shift]
(	
	@date_from datetime,
	@shift_from int,	--values 1-2
	@date_to datetime,
	@shift_to int		--values 1-2
)

RETURNS @smu_by_shift TABLE (
	equip_ident varchar(6),
	flt_desc varchar(35),
	start_hours numeric(9,2),
	finish_hours numeric(9,2),
	flt_id varchar(3)
)
AS BEGIN

	--Determine shift_date and shift_ident	
	DECLARE @shift_from_hrs int
	DECLARE @shift_to_hrs int

	IF @shift_from = 2 SELECT @shift_from_hrs = 18 ELSE SELECT @shift_from_hrs = 6
	IF @shift_to = 2 SELECT @shift_to_hrs = 30 ELSE SELECT @shift_to_hrs = 18

	INSERT INTO @smu_by_shift
	SELECT
	EH.EQUIP_IDENT, 
	F.FLT_DESC,
	CASE
		WHEN recent_hours.most_recent_hrs IS NULL
		THEN MIN(EH.ACCUMULATED_HOURS)
		ELSE recent_hours.most_recent_hrs
	END AS start_hours,
	MAX(EH.ACCUMULATED_HOURS) AS finish_hours,
	F.FLT_FLEET_IDENT
	FROM WencoReport.dbo.EQUIP AS E
	INNER JOIN WencoReport.dbo.FLEET AS F ON E.FLEET_IDENT = F.FLT_FLEET_IDENT 
	INNER JOIN WencoReport.dbo.ENGINE_HOURS AS EH ON E.EQUIP_IDENT = EH.EQUIP_IDENT
	LEFT JOIN (
		SELECT
		EH.EQUIP_IDENT,
		ACCUMULATED_HOURS AS most_recent_hrs
		FROM WencoReport.dbo.ENGINE_HOURS AS EH
		INNER JOIN (
			SELECT
			EQUIP_IDENT, MAX(TIMESTAMP) AS most_recent_time
			FROM WencoReport.dbo.ENGINE_HOURS
			WHERE TIMESTAMP < DATEADD(hh, @shift_from_hrs, @date_from)
			AND METER_SOURCE IN ('MANUAL','DBEDIT')
			GROUP BY EQUIP_IDENT
		) AS recent_hours
		ON EH.EQUIP_IDENT = recent_hours.EQUIP_IDENT AND EH.TIMESTAMP = recent_hours.most_recent_time
		WHERE TIMESTAMP < DATEADD(hh, @shift_from_hrs, @date_from)
		AND METER_SOURCE IN ('MANUAL','DBEDIT')
	) AS recent_hours
	ON EH.EQUIP_IDENT = recent_hours.EQUIP_IDENT
	WHERE EH.TIMESTAMP BETWEEN DATEADD(hh, @shift_from_hrs, @date_from) AND DATEADD(hh, @shift_to_hrs, @date_to)
	AND METER_SOURCE IN ('MANUAL','DBEDIT')
	GROUP BY EH.EQUIP_IDENT, recent_hours.most_recent_hrs,
	F.FLT_DESC, F.FLT_FLEET_IDENT
	ORDER BY EH.EQUIP_IDENT

RETURN
END