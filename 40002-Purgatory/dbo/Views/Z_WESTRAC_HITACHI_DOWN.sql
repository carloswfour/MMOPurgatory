
-- =============================================
-- Author:		Karl Daws
-- Create date: 21/Aug/2010
-- Description:	Data for the Westrac/Hitachi Plant Hours report
--				Marks particular units/statuses/status comments as 'MMO' or 'MARC' depending on who it is covered by
-- 
-- Modified: 
-- v1.1 09/Jan/2011 KDaws - Edited to include '%MMO%' status comment case
-- v1.2 17/Apr/2011 KDaws - Added 'S99 - Opportune  Maint', will help workshop reconcile against their system
-- v1.3 13/May/2011 KDaws - Excluded G966 (AKA Grader 3)
-- v1.4 16/Apr/2013 KDaws - Included W003 as MMO
-- v1.5 26/Apr/2013 KDaws - Added 'M61 - Tray Change' as MMO
-- v1.6 10/Dec/2013 KDaws - Included H012 as MMO
-- v1.7 05/Dec/2019 KDaws - H012 removed as MMO
-- =============================================

CREATE VIEW [dbo].[Z_WESTRAC_HITACHI_DOWN]
AS
SELECT     EST.SHIFT_DATE, EST.EQUIP_IDENT, ESC.STATUS_DESC, ESSC.SUB_STATUS_DESC, EST_CMT.EQUIP_STATUS_COMMENT, EST.START_TIMESTAMP, EST.END_TIMESTAMP, 
(CASE		--Assigns MMO to statuses/sub-statuses that aren't covered in the MARC contract, also excludes certain equipment
	WHEN (EST_CMT.EQUIP_STATUS_COMMENT LIKE '%MMO%') THEN 'MMO'
	WHEN (EST.EQUIP_IDENT NOT IN ('X100','X600','MF01','G996','W003') --Equipment not-covered under MARC contract (always show 'MMO')
			AND EST.STATUS_CODE NOT IN ('M59', 'M60', 'M53', 'M58', 'M62') --Statuses excluded
			AND (EST.SUB_STATUS_CODE NOT IN ('5101', '5116', '5109', '6110', '6113', '9922') OR EST.SUB_STATUS_CODE IS NULL)) THEN NULL
			ELSE 'MMO' END
) AS MARC	
FROM	WencoReport.dbo.EQUIPMENT_STATUS_TRANS AS EST
		INNER JOIN (SELECT * FROM WencoReport.dbo.EQUIP WHERE TEST = 'N') E ON EST.EQUIP_IDENT = E.EQUIP_IDENT
		INNER JOIN WencoReport.dbo.EQUIP_STATUS_CODE AS ESC ON EST.STATUS_CODE = ESC.STATUS_CODE
		LEFT OUTER JOIN WencoReport.dbo.EQUIP_STATUS_TRANS_CMT_COL AS EST_CMT ON EST.EQUIP_STATUS_REC_IDENT = EST_CMT.EQUIP_STATUS_REC_IDENT
		LEFT OUTER JOIN WencoReport.dbo.EQUIP_SUB_STATUS_CODE AS ESSC ON (EST.STATUS_CODE = ESSC.STATUS_CODE AND EST.SUB_STATUS_CODE = ESSC.SUB_STATUS_CODE)
WHERE	((EST.STATUS_CODE LIKE 'M%') 
		OR (EST.STATUS_CODE = 'S99' AND EST.SUB_STATUS_CODE = '9922')) --Down codes OR Standby - Opportune Maint.
		AND (EST.EQUIP_IDENT NOT LIKE 'T%')	--Exclude Test Equipment