
CREATE view [dbo].[z_ROMLoadGPS]
as 
select   ect.timestamp,ect.equip_ident,ect.shift_date,a.LOCATION_NAME,ect.northing,ect.easting 
from WencoReport.dbo.equip_coord_trans as ect join 
(SELECT    EQUIPMENT_STATUS_TRANS.SHIFT_DATE, EQUIPMENT_STATUS_TRANS.SHIFT_IDENT, EQUIPMENT_STATUS_TRANS.start_timestamp,
EQUIPMENT_STATUS_TRANS.end_timestamp, EQUIPMENT_STATUS_TRANS.EQUIP_IDENT, EQUIP_LOCATION_TRANS.LOCATION_NAME
FROM         WencoReport.dbo.EQUIP_LOCATION_TRANS INNER JOIN
                      WencoReport.dbo.EQUIPMENT_STATUS_TRANS ON 
                      WencoReport.dbo.EQUIP_LOCATION_TRANS.EQUIP_STATUS_REC_IDENT = EQUIPMENT_STATUS_TRANS.EQUIP_STATUS_REC_IDENT 
WHERE     (EQUIP_LOCATION_TRANS.LOCATION_NAME LIKE 'ROM%') AND (EQUIPMENT_STATUS_TRANS.EQUIP_IDENT LIKE 'X%' OR
                      EQUIPMENT_STATUS_TRANS.EQUIP_IDENT LIKE 'L%') AND (EQUIPMENT_STATUS_TRANS.STATUS_CODE = 'O22' OR
                      EQUIPMENT_STATUS_TRANS.STATUS_CODE LIKE 'N%' OR
                      EQUIPMENT_STATUS_TRANS.STATUS_CODE = 'O21')
AND EQUIPMENT_STATUS_TRANS.shift_date >GETDATE()-62
GROUP BY EQUIPMENT_STATUS_TRANS.SHIFT_DATE, EQUIPMENT_STATUS_TRANS.SHIFT_IDENT, EQUIPMENT_STATUS_TRANS.EQUIP_IDENT, 
                      EQUIP_LOCATION_TRANS.LOCATION_NAME,EQUIPMENT_STATUS_TRANS.start_timestamp,EQUIPMENT_STATUS_TRANS.end_timestamp
) as a
ON ect.timestamp between a.start_timestamp and a.end_timestamp AND ect.equip_ident = a.equip_ident

--select row_number() OVER(order by [timestamp]) as ident,* from z_romloadgps where shift_date > '2009-05-016' and LOCATION_NAME = 'ROMC' order by timestamp