

/*
--KDaws 21Oct10 - Added shift_date and shift_ident

--KDaws 10Jun12 - Reworked to include new Wenco messages (post upgrade Sys4.4.2 19/Jul/11)
--Also includes old messages, reworked to improve efficiency (due to EVENT_ID '3060' ENGLISH_MESSAGE LIKE '%...' clause)

Message examples:
--4310 Text (broadcast) sent from source Fleet Control, detail CH31 IS DOWN, PLS CHANGE TO CH55
--4311 Text sent from source Fleet Control, detail OK I GOT IT THIS MORNING, to unit H011
--4312 Text sent from unit WD01, detail No to dispatch
--4313 Text sent from unit X300, detail Go to CH 55 please to unit X300
*/

CREATE VIEW [dbo].[Z_WENCO_OPERATOR_MESSAGING]
AS

SELECT *
FROM (
SELECT		EVENT_GUID,
			LOG_TIMESTAMP,
			(SELECT shift_date FROM fn_datetime_to_shiftdate(LOG_TIMESTAMP)) AS shift_date,
			(SELECT shift_ident FROM fn_datetime_to_shiftdate(LOG_TIMESTAMP)) AS shift_ident,
			(CASE WHEN EVENT_ID IN ('4310','4311') THEN 'WNCO' ELSE equip_ident END) AS equip_ident,
			CASE
			--Pre 19/7/2011
			WHEN EVENT_ID = '3060' AND english_message LIKE '%SendMdtMessage message from Fleet Control:%' THEN substring(english_message, 86, 4)
			WHEN EVENT_ID = '4302' AND charindex('Dispatcher', english_message) > 0	THEN 'WNCO'
			--Post 19/7/2011
			WHEN EVENT_ID = '4310' THEN 'ALL'
			WHEN EVENT_ID = '4312' THEN 'WNCO'
			WHEN EVENT_ID <> '3060' THEN RIGHT(english_message, 4) --Catches case when english_message not like...
			END AS message_to,
			EVENT_ID,
			CASE
			--Pre 19/7/2011
			WHEN EVENT_ID = '3060' AND ENGLISH_MESSAGE LIKE '%SendMdtMessage message from Fleet Control:%' THEN ltrim(substring(english_message, 97, 32))
			WHEN EVENT_ID = '4302' THEN replace(replace(english_message, 'Sent Text ', ''), 'to Dispatcher.', '')
			WHEN EVENT_ID = '4300' THEN replace(substring(english_message, 0, len(english_message) - 13), 'Sent Text ', '')
			--Post 19/7/2011
			WHEN EVENT_ID = '4310' THEN replace(english_message, 'Text (broadcast) sent from source Fleet Control, detail ','')
			WHEN EVENT_ID = '4311' THEN replace(substring(english_message, 0, len(english_message) - 13), 'Text sent from source Fleet Control, detail ', '')
			WHEN EVENT_ID = '4312' THEN substring(english_message,34,len(english_message)-32-13)
			WHEN EVENT_ID = '4313' THEN substring(english_message,34,len(english_message)-32-14)
			END AS english_message,
			english_message AS orig
FROM		WencoReport.dbo.EVENT_TRANS
WHERE		EVENT_ID IN ('3060','4302','4300','4301','4310','4311','4312','4313')
) messages
WHERE english_message IS NOT NULL


--OLD
/*
SELECT		EVENT_GUID,
			LOG_TIMESTAMP,
			(SELECT shift_date FROM fn_datetime_to_shiftdate(LOG_TIMESTAMP)) AS shift_date,
			(SELECT shift_ident FROM fn_datetime_to_shiftdate(LOG_TIMESTAMP)) AS shift_ident,
			(CASE WHEN EVENT_ID = '3060' THEN 'WNCO' ELSE equip_ident END) AS equip_ident,
            (CASE WHEN EVENT_ID = '3060' THEN substring(english_message, 86, 4)
			WHEN EVENT_ID = '4302' AND charindex('Dispatcher', english_message) > 0
			THEN 'WNCO' ELSE RIGHT(english_message, 4) END) AS message_to,
			EVENT_ID,
            (CASE WHEN EVENT_ID = '3060' THEN ltrim(substring(english_message, 97, 32))
			WHEN EVENT_ID = '4302' THEN replace(replace(english_message, 'Sent Text ', ''), 'to Dispatcher.', '')
			WHEN EVENT_ID = '4300' THEN replace(substring(english_message, 0, len(english_message) - 13), 'Sent Text ', '') 
            ELSE english_message END) AS english_message
FROM		dbo.EVENT_TRANS
WHERE		(EVENT_ID IN ('4302', '4300', '4301'))
			OR ((EVENT_ID = '3060') AND (ENGLISH_MESSAGE LIKE '%SendMdtMessage message from Fleet Control:%'))
*/
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_WENCO_OPERATOR_MESSAGING';


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
         Begin Table = "EVENT_TRANS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 225
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Z_WENCO_OPERATOR_MESSAGING';

