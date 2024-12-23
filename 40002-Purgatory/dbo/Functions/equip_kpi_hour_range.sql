
-- =============================================
-- Author:		Karl Daws	
-- Create date: 15/10/10
-- Description:	Runs equip_kpi_hour for an entire shift.
--				Used for calculating cost per tonne
-- =============================================
CREATE FUNCTION [dbo].[equip_kpi_hour_range]
(	
	@shift_date datetime,
	@shift_ident int
)

RETURNS TABLE 
AS RETURN (

	--Run for every hour of day, then query the desired shift. Crude, but works.
	SELECT *
	FROM(SELECT * FROM equip_kpi_hour(@shift_date,6)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,7)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,8)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,9)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,10)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,11)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,12)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,13)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,14)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,15)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,16)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,17)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,18)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,19)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,20)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,21)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,22)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,23)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,24)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,25)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,26)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,27)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,28)
	UNION ALL SELECT * FROM equip_kpi_hour(@shift_date,29)
	) AS EKH
	WHERE shift_ident = @shift_ident
)