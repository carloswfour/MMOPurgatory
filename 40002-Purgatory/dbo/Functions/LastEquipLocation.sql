
-- =============================================
-- Author:		Karl Daws
-- Create date: 26/Nov/2013
-- Description:	Returns the latest EQUIP_LOCATION_TRANS record for a given equipment from a given starting point
--
-- 1/Oct/2014 KDaws - Added ELT2.EQUIP_IDENT = @equip_ident so that records of other equipment aren't considered
-- =============================================
CREATE FUNCTION [dbo].[LastEquipLocation] (
	@equip_ident AS varchar(4),
	@datetime AS datetime
)
RETURNS varchar(24)
AS
BEGIN 
RETURN (

SELECT
ELT2.LOCATION_NAME
FROM (
	SELECT
	MAX(TIMESTAMP) AS LATEST_TIMESTAMP
	FROM WencoReport.dbo.EQUIP_LOCATION_TRANS 
	WHERE EQUIP_IDENT = @equip_ident
	AND TIMESTAMP < @datetime
) ELT1
INNER JOIN WencoReport.dbo.EQUIP_LOCATION_TRANS AS ELT2
ON ELT1.LATEST_TIMESTAMP = ELT2.TIMESTAMP
AND ELT2.EQUIP_IDENT = @equip_ident

)

END