
-- =============================================
-- Author:		Karl Daws	
-- Create date: 15/10/10
-- Description:	Gives the status code for all statuses during an hour period
--				Used for calculating cost per tonne
-- =============================================
CREATE FUNCTION [dbo].[equip_status_hour_summary_old]
(	
	@shift_date datetime,
	@start_hour int
)

RETURNS TABLE
AS
RETURN(
	--DECLARE @st_ts datetime
	--DECLARE @end_ts DATETIME
	--SET @st_ts = dateadd(hh,@start_hour,@shift_date)
	--SET end_ts = dateadd(hh,@start_hour+1,@shift_date)

	SELECT shift_date,
	shift_ident,
	statuscat_code,
	status_desc,
	eqmodel_code,
	equip_desc,
	equip_ident,
	sum(duration_min) as duration_min
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
		equip_info.descrip as equip_desc,
		CASE
		WHEN
		start_timestamp <= dateadd(hh,@start_hour,@shift_date)
		AND end_timestamp IS NULL
		AND GETDATE() BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,dateadd(hh,@start_hour,@shift_date),GETDATE())/60.0

		WHEN
		start_timestamp <= dateadd(hh,@start_hour,@shift_date)
		AND end_timestamp IS NULL
		AND GETDATE() > dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,dateadd(hh,@start_hour,@shift_date),dateadd(hh,@start_hour+1,@shift_date))/60.0
		
		WHEN
		start_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		AND end_timestamp IS NULL
		AND GETDATE() BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,start_timestamp,GETDATE())/60.0

		WHEN
		start_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		AND end_timestamp IS NULL
		AND GETDATE() > dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,start_timestamp,dateadd(hh,@start_hour+1,@shift_date))/60.0

		WHEN 
		start_timestamp <= dateadd(hh,@start_hour,@shift_date)
		AND end_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,dateadd(hh,@start_hour,@shift_date),end_timestamp)/60.0
		
		WHEN
		start_timestamp <= dateadd(hh,@start_hour,@shift_date)
		AND end_timestamp > dateadd(hh,@start_hour+1,@shift_date)
		THEN
		60
		
		WHEN
		start_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)
		AND end_timestamp > dateadd(hh,@start_hour+1,@shift_date)
		THEN
		datediff(ss,start_timestamp,dateadd(hh,@start_hour+1,@shift_date))/60.0
		
		WHEN
		start_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)	
		AND end_timestamp BETWEEN dateadd(hh,@start_hour,@shift_date) AND dateadd(hh,@start_hour+1,@shift_date)	
		THEN
		datediff(ss,start_timestamp,end_timestamp)/60.0
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
		--AND end_timestamp > dateadd(hh,@start_hour,@shift_date) --Can not constrain end_timestamp since live data has a NULL
		AND start_timestamp < dateadd(hh,@start_hour+1,@shift_date)
	) AS equip_status_info
	WHERE equip_status_info.duration_min IS NOT NULL
	GROUP BY shift_date,
	shift_ident,
	eqmodel_code,
	statuscat_code,
	status_desc,
	equip_desc,
	equip_ident
)