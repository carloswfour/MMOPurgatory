
CREATE VIEW [dbo].[Z_PRODUCTIVITY_ROMBIN2]
AS
--HU's
SELECT     EST.SHIFT_DATE AS shift_date, EST.SHIFT_IDENT AS shift_ident, tonnes_tbl.rom_source, SUM(CAST(DATEDIFF(s, EST.START_TIMESTAMP, ISNULL(EST.END_TIMESTAMP, GETDATE())) AS DECIMAL) / 60 / 60) 
                      AS duration, S.STATUS_DESC AS status_desc, tonnes_tbl.tonnes, tonnes_tbl.empty_dist, tonnes_tbl.haul_dist, tonnes_tbl.loads, dbo.fn_truck_count(EST.SHIFT_DATE, EST.SHIFT_IDENT, 'L%', 'ROM[A-Z]%', 'ROMBIN%', 1) AS truck_count
FROM         WencoReport.dbo.FLEET INNER JOIN
                      WencoReport.dbo.EQUIP ON FLEET.FLT_FLEET_IDENT = EQUIP.FLEET_IDENT INNER JOIN
                      WencoReport.dbo.EQUIP_STATUS_CODE AS S INNER JOIN
                      WencoReport.dbo.EQUIPMENT_STATUS_TRANS AS EST ON S.STATUS_CODE = EST.STATUS_CODE INNER JOIN
                      WencoReport.dbo.HAUL_UNIT_STATUS_TRANS_COL AS HUSTC ON EST.EQUIP_STATUS_REC_IDENT = HUSTC.EQUIP_STATUS_REC_IDENT INNER JOIN
                      WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT ON HUSTC.HAUL_CYCLE_REC_IDENT = HCT.HAUL_CYCLE_REC_IDENT ON 
                      EQUIP.EQUIP_IDENT = HCT.HAULING_UNIT_IDENT INNER JOIN
                          (SELECT     DUMP_END_SHIFT_DATE AS DESD, DUMP_END_SHIFT_IDENT AS DESI, LOAD_LOCATION_SNAME as rom_source, SUM(QUANTITY_REPORTING) AS tonnes, SUM(EMPTY_DISTANCE) AS empty_dist, 
                                                   SUM(HAUL_DISTANCE) AS haul_dist, COUNT(QUANTITY_REPORTING) AS loads
                            FROM          WencoReport.dbo.HAUL_CYCLE_TRANS
                            WHERE      (LOADING_UNIT_IDENT LIKE 'L%') AND (LOAD_LOCATION_SNAME LIKE 'ROM[A-Z]%')
                            GROUP BY DUMP_END_SHIFT_DATE, DUMP_END_SHIFT_IDENT, LOAD_LOCATION_SNAME) AS tonnes_tbl
					  ON (tonnes_tbl.DESD = EST.SHIFT_DATE) AND (tonnes_tbl.DESI = EST.SHIFT_IDENT) AND (tonnes_tbl.rom_source = HCT.LOAD_LOCATION_SNAME)
WHERE     (HCT.LOADING_UNIT_IDENT LIKE 'L%') AND (HCT.LOAD_LOCATION_SNAME LIKE 'ROM[A-Z]%') AND (S.STATUS_CODE LIKE 'N%')
GROUP BY EST.SHIFT_DATE, EST.SHIFT_IDENT, S.STATUS_DESC, tonnes_tbl.rom_source, tonnes_tbl.tonnes, tonnes_tbl.empty_dist, tonnes_tbl.haul_dist, tonnes_tbl.loads
/*
--Wait time isn't accurate?
UNION
--LU's
SELECT     TOP (100) PERCENT EST.SHIFT_DATE AS shift_date, tonnes_tbl_1.rom_source, SUM(CAST(DATEDIFF(s, EST.START_TIMESTAMP, ISNULL(EST.END_TIMESTAMP, GETDATE())) 
                      AS DECIMAL) / 60 / 60) AS duration, S.STATUS_DESC AS status_desc, tonnes_tbl_1.tonnes, tonnes_tbl_1.empty_dist, tonnes_tbl_1.haul_dist, tonnes_tbl_1.loads
FROM         dbo.EQUIP_STATUS_CODE AS S INNER JOIN
                      dbo.EQUIPMENT_STATUS_TRANS AS EST ON S.STATUS_CODE = EST.STATUS_CODE INNER JOIN
                      dbo.LOAD_UNIT_STATUS_TRANS_COL AS LUSTC ON EST.EQUIP_STATUS_REC_IDENT = LUSTC.EQUIP_STATUS_REC_IDENT INNER JOIN
                      dbo.FLEET AS FLEET_1 INNER JOIN
                      dbo.EQUIP AS EQUIP_1 ON FLEET_1.FLT_FLEET_IDENT = EQUIP_1.FLEET_IDENT INNER JOIN
                      dbo.HAUL_CYCLE_TRANS AS HCT ON EQUIP_1.EQUIP_IDENT = HCT.HAULING_UNIT_IDENT ON 
                      LUSTC.HAUL_CYCLE_REC_IDENT = HCT.HAUL_CYCLE_REC_IDENT INNER JOIN
                          (SELECT     DUMP_END_SHIFT_DATE AS DESD, LOAD_LOCATION_SNAME as rom_source, SUM(QUANTITY_REPORTING) AS tonnes, SUM(EMPTY_DISTANCE) AS empty_dist, 
                                                   SUM(HAUL_DISTANCE) AS haul_dist, COUNT(QUANTITY_REPORTING) AS loads
                            FROM          dbo.HAUL_CYCLE_TRANS AS HAUL_CYCLE_TRANS_1
                            WHERE      (LOADING_UNIT_IDENT LIKE 'L%') AND (LOAD_LOCATION_SNAME LIKE 'ROM[A-J]%')
                            GROUP BY DUMP_END_SHIFT_DATE, LOAD_LOCATION_SNAME) AS tonnes_tbl_1 ON tonnes_tbl_1.DESD = EST.SHIFT_DATE AND (tonnes_tbl_1.rom_source = HCT.LOAD_LOCATION_SNAME) 
WHERE     (HCT.LOADING_UNIT_IDENT LIKE 'L%') AND (HCT.LOAD_LOCATION_SNAME LIKE 'ROM[A-J]%') AND (S.STATUS_CODE LIKE 'N%')
GROUP BY EST.SHIFT_DATE, S.STATUS_DESC, tonnes_tbl_1.rom_source, tonnes_tbl_1.tonnes, tonnes_tbl_1.empty_dist, tonnes_tbl_1.haul_dist, tonnes_tbl_1.loads
*/