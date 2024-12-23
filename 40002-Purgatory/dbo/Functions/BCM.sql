
-- =============================================
-- Author:		Tim Smith
-- Create date: 17/10/2009
-- Description:	returns BCM's based on rock domains or material type
-- =============================================
CREATE FUNCTION [dbo].[BCM]
(
	@Wet_Tonnes as numeric(18,5),@material_ident as varchar(24),@SA as numeric(18,5),@SM  as numeric(18,5)
,@FZ  as numeric(18,5),@FEL as numeric(18,5),@UM as numeric(18,5),@MAF as numeric(18,5),@SIL as numeric(18,5),@LI as numeric(18,5),@PC as numeric(18,5)
)
RETURNS numeric(18,5)
AS
BEGIN 
RETURN(
	CASE 
 
WHEN (COALESCE (@SA, 0)  + 
COALESCE (@SM, 0)  + 
COALESCE (@FZ, 0)  + 
COALESCE (@LI, 0)  + 
COALESCE (@FEL, 0)  + 
COALESCE (@MAF, 0) + 
COALESCE (@PC, 0)  + 
COALESCE (@UM, 0) + 
COALESCE (@SIL, 0) ) NOT BETWEEN 0.999 and 1.001  
THEN  @Wet_Tonnes / (CASE
				WHEN @material_ident like '10B' THEN 2.0625 -- base on survey rules of thumb conversions
				WHEN @material_ident like '8BC' THEN 2.0625
				WHEN @material_ident like 'TSC' THEN 2.0625
				WHEN @material_ident like 'DSC' THEN 2.0625
				WHEN @material_ident like 'CSC' THEN 2.0625
				WHEN @material_ident like 'EGR' THEN 2.0625
				WHEN @material_ident like '50G' THEN 2.0625
				WHEN @material_ident like '20O' THEN 2.0625
				WHEN @material_ident like '7OB' THEN 2.0625
				WHEN @material_ident like 'AOR' THEN 2.0625
				WHEN @material_ident like '40P' THEN 2.0625
				WHEN @material_ident like '30R' THEN 2.0625
				WHEN @material_ident like 'BRS' THEN 2.0625
				WHEN @material_ident like 'DTS' THEN 2.0625
				WHEN @material_ident like 'TTW' THEN 2.0625
				WHEN @material_ident like '00W' THEN 2.0625
				WHEN @material_ident like 'WSC' THEN 2.0625
				WHEN @material_ident is null THEN 2.0625
				END) ELSE 
@Wet_Tonnes / 
(
(COALESCE (@SA, 0)  * 1.91) + 
(COALESCE (@SM, 0) * 2.11) + 
(COALESCE (@FZ, 0) * 2.14) + 
(COALESCE (@LI, 0) * 1.97) + 
(COALESCE (@FEL, 0) * 1.34) + 
(COALESCE (@MAF, 0) * 3.06) + 
(COALESCE (@PC, 0) * 2.00) + 
(COALESCE (@UM, 0) * 3.12) + 
(COALESCE (@SIL, 0) * 1.76))   END )


END