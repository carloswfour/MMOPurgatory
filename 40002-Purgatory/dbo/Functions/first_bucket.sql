
-- =============================================
-- Author:		Karl Daws
-- Create date: 1/5/2010
-- Description:	Counts number of buckets per truck load from the ROM. If the first payload is over the defined threshold then an extra bucket is added to the total number of buckets
-- =============================================
CREATE FUNCTION [dbo].[first_bucket](@date_from datetime, @date_to datetime, @first_bucket_threshold int)
RETURNS TABLE 
AS
RETURN(
SELECT     HAUL_CYCLE_REC_IDENT, LOAD_LOCATION_SNAME, QUANTITY_REPORTING, MIN(CAST(bucket_payloads AS numeric(3, 0))) AS first_bucket,
		(CASE WHEN MIN(CAST(bucket_payloads AS numeric(3, 0))) >= @first_bucket_threshold THEN COUNT(bucket_payloads) + 1 ELSE COUNT(bucket_payloads) END) AS bucket_count
                       FROM          (SELECT     HCT.HAUL_CYCLE_REC_IDENT, HCT.LOAD_LOCATION_SNAME, HCT.QUANTITY_REPORTING, 
                                                                      REPLACE(REPLACE(ET.ENGLISH_MESSAGE, 'Payload=', ''), ' MT', '') AS bucket_payloads
                                               FROM          WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT INNER JOIN
                                                                       WencoReport.dbo.LOAD_UNIT_STATUS_TRANS_COL AS LUST ON HCT.HAUL_CYCLE_REC_IDENT = LUST.HAUL_CYCLE_REC_IDENT INNER JOIN
                                                                       WencoReport.dbo.EQUIPMENT_STATUS_TRANS AS EST ON LUST.EQUIP_STATUS_REC_IDENT = EST.EQUIP_STATUS_REC_IDENT INNER JOIN
                                                                       WencoReport.dbo.EVENT_TRANS AS ET ON HCT.HAULING_UNIT_IDENT = ET.EQUIP_IDENT AND ET.TIMESTAMP BETWEEN 
                                                                      EST.START_TIMESTAMP AND EST.END_TIMESTAMP
                                               WHERE      (HCT.LOAD_LOCATION_SNAME LIKE 'ROM%') AND (HCT.LOAD_START_SHIFT_DATE BETWEEN @date_from AND @date_to) AND 
                                                                      (EST.STATUS_CODE = 'N13') AND (ET.EVENT_ID = '460')
                                               GROUP BY HCT.HAUL_CYCLE_REC_IDENT, HCT.LOAD_LOCATION_SNAME, HCT.QUANTITY_REPORTING, ET.ENGLISH_MESSAGE) 
                                              AS Loads2
                       GROUP BY HAUL_CYCLE_REC_IDENT, LOAD_LOCATION_SNAME, QUANTITY_REPORTING
)