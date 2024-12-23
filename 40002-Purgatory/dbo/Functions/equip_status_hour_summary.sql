
-- =============================================
-- Author:		Karl Daws	
-- Create date: 15/10/10
-- Description:	Gives the status code for all statuses during an hour period
--				Used for calculating cost per tonne
-- 1/Jun/24
-- Increased size of equip_ident to accommodate A2Ds longer equipment IDs
-- =============================================
--select * from EQUIP_STATUS_HOUR_SUMMARY('20240501',6)
CREATE FUNCTION [dbo].[equip_status_hour_summary]
(	
	@shift_date datetime,
	@start_hour int --values 6-29
)

RETURNS @equip_status_hour TABLE (
	start_hour datetime,
	shift_date datetime,
	shift_ident varchar(1),
	statuscat_code varchar(8),
	status_desc varchar(50),
	eqmodel_code varchar(15),
	equip_desc varchar(50),
	equip_ident varchar(8),
	duration_min numeric(18,4)
)
AS BEGIN

	--Determine shift_date and shift_ident	
	DECLARE @shift_ident varchar(1)
	DECLARE @st_ts datetime
	DECLARE @end_ts datetime
	
	SELECT @shift_ident = shift_ident
	FROM fn_shift_ident(@shift_date,@start_hour)

	SELECT @st_ts = dateadd(hh,@start_hour,@shift_date)
	SELECT @end_ts = dateadd(hh,@start_hour+1,@shift_date)
	
	INSERT INTO @equip_status_hour
	SELECT 
	CONVERT(datetime, @st_ts, 8) AS start_hour,
	shift_date,
	shift_ident,
	statuscat_code,
	status_desc,
	eqmodel_code,
	equip_desc,
	equip_ident,
	SUM(duration_min) AS duration_min
	FROM(
		SELECT equip_status_rec_ident,
		start_timestamp,
		end_timestamp,
		shift_date,
		shift_ident,
		status_info.status_code,
		statuscat_code,
		status_desc,
		eqmodel_code,
		est.equip_ident,
		equip_info.descrip AS equip_desc,
		CASE
		--Status is current (NULL end timestamp)		
		WHEN
		start_timestamp <= @st_ts
		AND end_timestamp IS NULL
		AND GETDATE() BETWEEN @st_ts AND @end_ts --Current time is within hour period
		THEN
		datediff(ss,@st_ts,GETDATE())/60.0

		WHEN 
		start_timestamp <= @st_ts
		AND end_timestamp IS NULL
		AND GETDATE() > @end_ts --Current time is after hour period
		THEN
		datediff(ss,@st_ts,@end_ts)/60.0
		
		WHEN
		start_timestamp BETWEEN @st_ts AND @end_ts
		AND end_timestamp IS NULL
		AND GETDATE() BETWEEN @st_ts AND @end_ts --Current time is within hour period
		THEN
		datediff(ss,start_timestamp,GETDATE())/60.0

		WHEN
		start_timestamp BETWEEN @st_ts AND @end_ts
		AND end_timestamp IS NULL
		AND GETDATE() > @end_ts --Current time is after hour period
		THEN
		datediff(ss,start_timestamp,@end_ts)/60.0

		--Status is complete (end_timesatmp IS NOT NULL)
		WHEN 
		start_timestamp <= @st_ts
		AND end_timestamp BETWEEN @st_ts AND @end_ts
		THEN
		datediff(ss,@st_ts,end_timestamp)/60.0
		
		WHEN
		start_timestamp <= @st_ts
		AND end_timestamp > @end_ts
		THEN
		60
		
		WHEN
		start_timestamp BETWEEN @st_ts AND @end_ts
		AND end_timestamp > @end_ts
		THEN
		datediff(ss,start_timestamp,@end_ts)/60.0
		
		WHEN
		start_timestamp BETWEEN @st_ts AND @end_ts	
		AND end_timestamp BETWEEN @st_ts AND @end_ts	
		THEN
		datediff(ss,start_timestamp,end_timestamp)/60.0
		--No ELSE
		END AS duration_min
		from wencoreport.dbo.equipment_status_trans as est

		inner join (
		select sc.statuscat_code, sc.descrip,esc.status_code,esc.status_desc,esc.active from wencoreport.dbo.status_category as sc 
		inner join wencoreport.dbo.status_code_category as scc on scc.statuscat_code = sc.statuscat_code
		inner join wencoreport.dbo.equip_status_code as esc on esc.status_code = scc.status_code
		) as status_info
		on status_info.status_code = est.status_code

		inner join (
		select em.eqmodel_code,e.equip_ident,e.descrip
		from wencoreport.dbo.equip_model as em inner join wencoreport.dbo.equip as e on e.eqmodel_code = em.eqmodel_code
		where e.active = 'Y' and e.test = 'N'
		) as equip_info
		on equip_info.equip_ident = est.equip_ident

		where shift_date = @shift_date
		AND shift_ident = @shift_ident
		--AND end_timestamp > @st_ts --Can not constrain end_timestamp since live data has a NULL value
		AND start_timestamp < @end_ts
	) AS equip_status_info
	WHERE equip_status_info.duration_min IS NOT NULL
	GROUP BY
	shift_date,
	shift_ident,
	eqmodel_code,
	statuscat_code,
	status_desc,
	equip_desc,
	equip_ident

RETURN
END