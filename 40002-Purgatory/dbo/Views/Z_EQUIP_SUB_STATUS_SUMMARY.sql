
CREATE VIEW [dbo].[Z_EQUIP_SUB_STATUS_SUMMARY]
AS

/*
--KDaws 15/10/10 - Changed duration_min formula, did not handle the NULL end_timestamp of a current status
--Added shift_ident

*/

SELECT shift_date,
shift_ident,
statuscat_code,
status_desc,
sub_status_desc,
eqmodel_code,
equip_desc,
equip_ident,
sum(duration_min) as duration_min
FROM(
	select equip_status_rec_ident,
	start_timestamp,
	shift_date,
	shift_ident,
	status_info.status_code,
	end_timestamp,
	statuscat_code,
	status_desc,
	essc.sub_status_code,
	sub_status_desc,
	eqmodel_code,
	est.equip_ident,
	equip_info.descrip as equip_desc,
	--convert(numeric(10,2),datediff(ss,start_timestamp,end_timestamp)/60.0) as duration_min
	convert(numeric(10,2),datediff(ss,start_timestamp,ISNULL(end_timestamp,GETDATE()))/60.0) as duration_min
	from WencoReport.dbo.equipment_status_trans as est
inner join (
	select sc.statuscat_code, sc.descrip,esc.status_code,esc.status_desc,esc.active from WencoReport.dbo.status_category as sc 
	inner join WencoReport.dbo.status_code_category as scc on scc.statuscat_code = sc.statuscat_code
	inner join WencoReport.dbo.equip_status_code as esc on esc.status_code = scc.status_code
	) as status_info
	on status_info.status_code = est.status_code
inner join (
	select em.eqmodel_code,e.equip_ident,e.descrip from WencoReport.dbo.equip_model as em
	inner join WencoReport.dbo.equip as e on e.eqmodel_code = em.eqmodel_code
	where e.active = 'Y' and e.test = 'N') as equip_info
	on equip_info.equip_ident = est.equip_ident
LEFT JOIN WencoReport.dbo.EQUIP_SUB_STATUS_CODE AS essc ON est.SUB_STATUS_CODE = essc.SUB_STATUS_CODE
) as equip_status_info
GROUP BY shift_date,
shift_ident,
eqmodel_code,
statuscat_code,
status_desc,
sub_status_desc,
equip_desc,
equip_ident