

/*
--KDaws 21/Oct/2010 - Added shift_date and shift_ident
--KDaws 11/Aug/2013 - Doesn't work for operators who are still badged in, added ISNULL(SBT.END_TIMESTAMP,GETDATE().
					- Also shows messages sent with NULL badges.
*/

CREATE VIEW [dbo].[Z_WENCO_OPERATOR_MESSAGING_NAMES]
AS

SELECT		
OM.EVENT_GUID,
OM.LOG_TIMESTAMP,
OM.SHIFT_DATE,
OM.SHIFT_IDENT,
OM.EQUIP_IDENT,
SB.FIRST_NAME + ' ' + SB.LAST_NAME AS SEND_BADGE,
OM.MESSAGE_TO,
RB.FIRST_NAME + ' ' + RB.LAST_NAME AS RECV_BADGE,
OM.EVENT_ID,
OM.ENGLISH_MESSAGE
FROM Z_WENCO_OPERATOR_MESSAGING AS OM
LEFT OUTER JOIN WencoReport.dbo.BADGE_TRANS AS SBT
ON OM.EQUIP_IDENT = SBT.EQUIP_IDENT
AND OM.SHIFT_DATE = SBT.SHIFT_DATE
AND OM.SHIFT_IDENT = SBT.SHIFT_IDENT
AND OM.LOG_TIMESTAMP BETWEEN SBT.START_TIMESTAMP AND ISNULL(SBT.END_TIMESTAMP,GETDATE())
AND SBT.IS_PRIMARY_BADGE = 'Y'
LEFT OUTER JOIN WencoReport.dbo.BADGE AS SB ON SB.BADGE_IDENT = SBT.BADGE_IDENT
LEFT OUTER JOIN WencoReport.dbo.BADGE_TRANS AS RBT
ON OM.MESSAGE_TO = RBT.EQUIP_IDENT
AND OM.SHIFT_DATE = RBT.SHIFT_DATE
AND OM.SHIFT_IDENT = RBT.SHIFT_IDENT
AND OM.LOG_TIMESTAMP BETWEEN RBT.START_TIMESTAMP AND ISNULL(RBT.END_TIMESTAMP,GETDATE())
AND RBT.IS_PRIMARY_BADGE = 'Y'
LEFT OUTER JOIN WencoReport.dbo.BADGE AS RB ON RB.BADGE_IDENT = RBT.BADGE_IDENT


/*
SELECT		OM.EVENT_GUID, OM.LOG_TIMESTAMP, OM.shift_date, OM.shift_ident, OM.equip_ident, SB.FIRST_NAME + ' ' + SB.LAST_NAME AS SEND_BADGE,
			OM.message_to, RB.FIRST_NAME + ' ' + RB.LAST_NAME AS RECV_BADGE, OM.EVENT_ID, OM.english_message
FROM		dbo.Z_WENCO_OPERATOR_MESSAGING AS OM RIGHT OUTER JOIN
			dbo.BADGE AS SB INNER JOIN
			dbo.BADGE_TRANS AS SBT ON SB.BADGE_IDENT = SBT.BADGE_IDENT ON OM.LOG_TIMESTAMP BETWEEN SBT.START_TIMESTAMP AND 
			SBT.END_TIMESTAMP AND OM.equip_ident = SBT.EQUIP_IDENT RIGHT OUTER JOIN
			dbo.BADGE_TRANS AS RBT INNER JOIN
			dbo.BADGE AS RB ON RBT.BADGE_IDENT = RB.BADGE_IDENT ON OM.LOG_TIMESTAMP BETWEEN RBT.START_TIMESTAMP AND 
			RBT.END_TIMESTAMP AND OM.message_to = RBT.EQUIP_IDENT
*/
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_WENCO_OPERATOR_MESSAGING_NAMES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'put = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_WENCO_OPERATOR_MESSAGING_NAMES';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Left = 0
      End
      Begin Tables = 
         Begin Table = "OM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SB"
            Begin Extent = 
               Top = 6
               Left = 239
               Bottom = 114
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SBT"
            Begin Extent = 
               Top = 6
               Left = 474
               Bottom = 114
               Right = 654
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RBT"
            Begin Extent = 
               Top = 6
               Left = 692
               Bottom = 114
               Right = 872
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RB"
            Begin Extent = 
               Top = 6
               Left = 910
               Bottom = 114
               Right = 1107
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
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Out', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_WENCO_OPERATOR_MESSAGING_NAMES';

