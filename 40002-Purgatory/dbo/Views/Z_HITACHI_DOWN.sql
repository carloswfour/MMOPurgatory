﻿
create VIEW [dbo].[Z_HITACHI_DOWN]
AS

/*
Created 20Aug10 - Used in 'Hitachi KPI Report' to calculate the availability of the EX1900 fleet.
This view considers special scenarios which aren't covered by the MARC contract and are therefore ommited from the availability calculation.

17Nov10 - Added '%MMO%' status comment exception
*/

SELECT     EST.SHIFT_DATE, EST.EQUIP_IDENT, ESC.STATUS_DESC, ESSC.SUB_STATUS_DESC, EST_CMT.EQUIP_STATUS_COMMENT, EST.START_TIMESTAMP, EST.END_TIMESTAMP
FROM	WencoReport.dbo.EQUIPMENT_STATUS_TRANS AS EST
		INNER JOIN (SELECT * FROM WencoReport.dbo.EQUIP WHERE TEST = 'N') E ON EST.EQUIP_IDENT = E.EQUIP_IDENT
		INNER JOIN WencoReport.dbo.EQUIP_STATUS_CODE AS ESC ON EST.STATUS_CODE = ESC.STATUS_CODE
		LEFT OUTER JOIN WencoReport.dbo.EQUIP_STATUS_TRANS_CMT_COL AS EST_CMT ON EST.EQUIP_STATUS_REC_IDENT = EST_CMT.EQUIP_STATUS_REC_IDENT
		LEFT OUTER JOIN WencoReport.dbo.EQUIP_SUB_STATUS_CODE AS ESSC ON (EST.STATUS_CODE = ESSC.STATUS_CODE AND EST.SUB_STATUS_CODE = ESSC.SUB_STATUS_CODE)
WHERE     (EST.STATUS_CODE LIKE 'M%')
AND (EST_CMT.EQUIP_STATUS_COMMENT NOT LIKE '%MMO%' OR EST_CMT.EQUIP_STATUS_COMMENT IS NULL)
AND (EST.STATUS_CODE NOT IN ('M59', 'M60', 'M53', 'M58', 'M62')) --EXCLUDES Non-Contract MMO Statuses
AND (EST.SUB_STATUS_CODE NOT IN ('5101', '5116', '5109', '6110') OR EST.SUB_STATUS_CODE IS NULL) --EXCLUDES Sub-Statuses '2-Way Radio', 'Wenco', 'Laser', 'Fueling' Allows NULL's
AND (EST.EQUIP_IDENT LIKE 'X%')
AND (EST.EQUIP_IDENT NOT LIKE 'T%')
AND (EST.EQUIP_IDENT NOT IN ('X100','X600')) --EXCLUDES X100 & X600 as they aren't included in the MARC contract