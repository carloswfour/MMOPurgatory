
CREATE VIEW [dbo].[Z_ROMBIN_LU_HOURS_BY_GPS]
AS


SELECT SHIFT_DATE, SHIFT_IDENT, EQUIP_IDENT, LOAD_LOCATION_SNAME, DUMP_LOCATION_SNAME, SUM(DURATION)/60 AS DURATION_HOURS, STATUS_CODE, STATUS_DESC, FLT_DESC, LOC_AREA
FROM WencoReport.dbo.LOAD_UNIT_TIME_PROFILE AS LUTP INNER JOIN
	WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT ON LUTP.HAUL_CYCLE_REC_IDENT = HCT.HAUL_CYCLE_REC_IDENT AND LUTP.SHIFT_DATE = HCT.LOAD_START_SHIFT_DATE AND LUTP.SHIFT_IDENT = HCT.LOAD_START_SHIFT_IDENT INNER JOIN
	WencoReport.dbo.EQUIP ON LUTP.LOADUNIT_EQUIP_IDENT = EQUIP.EQUIP_IDENT INNER JOIN
	WencoReport.dbo.FLEET ON EQUIP.FLEET_IDENT = FLEET.FLT_FLEET_IDENT INNER JOIN
	WencoReport.dbo.LOCATION AS LOC ON HCT.LOAD_LOCATION_SNAME = LOC.LOC_SNAME
WHERE (EQUIP_IDENT LIKE 'X%' OR EQUIP_IDENT LIKE 'L%')
	AND (LUTP.STATUS_CODE LIKE 'N%' OR LUTP.STATUS_CODE IN ('O22'))
	AND HCT.LOAD_LOCATION_SNAME LIKE 'ROM%'
	AND HCT.DUMP_LOCATION_SNAME LIKE 'ROMBIN%'

GROUP BY SHIFT_DATE, SHIFT_IDENT, EQUIP_IDENT, LOAD_LOCATION_SNAME, DUMP_LOCATION_SNAME, STATUS_CODE, STATUS_DESC, FLT_DESC, LOC_AREA

UNION

SELECT SHIFT_DATE, SHIFT_IDENT, EQUIP_IDENT, '' AS LOAD_LOCATION_SNAME, '' AS DUMP_LOCATION_SNAME, DURATION_HOURS, STATUS_CODE, STATUS_DESC, FLT_DESC, 'ROM' AS loc_area
FROM (
	SELECT     EST.EQUIP_IDENT, FLEET.FLT_DESC, EST.SHIFT_DATE, EST.SHIFT_IDENT, EST.STATUS_CODE, ESC.STATUS_DESC, 
                      ESTC.EQUIP_STATUS_COMMENT, SUM(CAST(DATEDIFF(s, EST.START_TIMESTAMP, ISNULL(EST.END_TIMESTAMP, GETDATE())) AS numeric(18, 2)) 
                      / 3600) AS DURATION_HOURS
	FROM         WencoReport.dbo.FLEET INNER JOIN
						  WencoReport.dbo.EQUIP ON FLEET.FLT_FLEET_IDENT = EQUIP.FLEET_IDENT INNER JOIN
						  WencoReport.dbo.EQUIP_STATUS_TRANS_CMT_COL AS ESTC RIGHT OUTER JOIN
						  WencoReport.dbo.EQUIPMENT_STATUS_TRANS AS EST ON ESTC.EQUIP_STATUS_REC_IDENT = EST.EQUIP_STATUS_REC_IDENT INNER JOIN
						  WencoReport.dbo.EQUIP_STATUS_CODE AS ESC ON EST.STATUS_CODE = ESC.STATUS_CODE ON EQUIP.EQUIP_IDENT = EST.EQUIP_IDENT
	WHERE (EST.EQUIP_IDENT LIKE 'X%' OR EST.EQUIP_IDENT LIKE 'L%')
	AND EST.STATUS_CODE IN ('O21')
	GROUP BY EST.EQUIP_IDENT, EST.SHIFT_DATE, EST.SHIFT_IDENT, EST.STATUS_CODE, ESC.STATUS_DESC, ESTC.EQUIP_STATUS_COMMENT, FLEET.FLT_DESC
	) AS ANCIL_LU


--This technique doesn't work properly in S4.4.2
/*
SELECT     TOP (100) PERCENT dbo.EQUIPMENT_STATUS_TRANS.SHIFT_DATE, dbo.EQUIPMENT_STATUS_TRANS.SHIFT_IDENT, 
                      dbo.EQUIPMENT_STATUS_TRANS.EQUIP_IDENT, dbo.FLEET.FLT_DESC, dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE, 
                      dbo.EQUIP_STATUS_CODE.STATUS_DESC, SUM(CAST(DATEDIFF(s, dbo.EQUIPMENT_STATUS_TRANS.START_TIMESTAMP, 
                      ISNULL(dbo.EQUIPMENT_STATUS_TRANS.END_TIMESTAMP, GETDATE())) AS DECIMAL) / 3600) AS DURATION_HOURS, 
                      dbo.EQUIP_LOCATION_TRANS.LOCATION_NAME
FROM         dbo.EQUIP_LOCATION_TRANS INNER JOIN
                      dbo.EQUIPMENT_STATUS_TRANS ON 
                      dbo.EQUIP_LOCATION_TRANS.EQUIP_STATUS_REC_IDENT = dbo.EQUIPMENT_STATUS_TRANS.EQUIP_STATUS_REC_IDENT INNER JOIN
                      dbo.EQUIP ON dbo.EQUIP_LOCATION_TRANS.EQUIP_IDENT = dbo.EQUIP.EQUIP_IDENT INNER JOIN
                      dbo.FLEET ON dbo.EQUIP.FLEET_IDENT = dbo.FLEET.FLT_FLEET_IDENT INNER JOIN
                      dbo.EQUIP_STATUS_CODE ON dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE = dbo.EQUIP_STATUS_CODE.STATUS_CODE
WHERE     (dbo.EQUIP_LOCATION_TRANS.LOCATION_NAME LIKE 'ROM%') AND (dbo.EQUIPMENT_STATUS_TRANS.EQUIP_IDENT LIKE 'X%' OR
                      dbo.EQUIPMENT_STATUS_TRANS.EQUIP_IDENT LIKE 'L%') AND (dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE = 'O22' OR
                      dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE LIKE 'N%' OR
                      dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE = 'O21')
GROUP BY dbo.EQUIPMENT_STATUS_TRANS.SHIFT_DATE, dbo.EQUIPMENT_STATUS_TRANS.SHIFT_IDENT, dbo.EQUIPMENT_STATUS_TRANS.EQUIP_IDENT, 
                      dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE, dbo.FLEET.FLT_DESC, dbo.EQUIP_STATUS_CODE.STATUS_DESC, 
                      dbo.EQUIP_LOCATION_TRANS.LOCATION_NAME
ORDER BY dbo.EQUIPMENT_STATUS_TRANS.SHIFT_DATE, dbo.EQUIPMENT_STATUS_TRANS.EQUIP_IDENT, dbo.EQUIPMENT_STATUS_TRANS.STATUS_CODE
*/
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_ROMBIN_LU_HOURS_BY_GPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_ROMBIN_LU_HOURS_BY_GPS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[20] 2[21] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -1197
      End
      Begin Tables = 
         Begin Table = "EQUIP_LOCATION_TRANS"
            Begin Extent = 
               Top = 6
               Left = 1235
               Bottom = 114
               Right = 1468
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "EQUIPMENT_STATUS_TRANS"
            Begin Extent = 
               Top = 155
               Left = 1499
               Bottom = 263
               Right = 1732
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EQUIP"
            Begin Extent = 
               Top = 6
               Left = 1777
               Bottom = 114
               Right = 2021
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FLEET"
            Begin Extent = 
               Top = 6
               Left = 2059
               Bottom = 99
               Right = 2243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EQUIP_STATUS_CODE"
            Begin Extent = 
               Top = 178
               Left = 1771
               Bottom = 286
               Right = 2003
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
       ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_ROMBIN_LU_HOURS_BY_GPS';

