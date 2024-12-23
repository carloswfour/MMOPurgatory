
-- =============================================
-- Author:		Tim Smith
-- Create date: 17/10/2009
-- Description:	returns dry tonnes based on rock domains or material type
-- =============================================
CREATE FUNCTION [dbo].[dry_tonnes] 
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
THEN @Wet_Tonnes / (CASE
				WHEN @material_ident like '10B' THEN 1.55
				WHEN @material_ident like '8BC' THEN 1.18
				WHEN @material_ident like 'TSC' THEN 2.07
				WHEN @material_ident like 'DSC' THEN 1.47
				WHEN @material_ident like 'CSC' THEN 1.47
				WHEN @material_ident like 'EGR' THEN 1.18
				WHEN @material_ident like '50G' THEN 1.54
				WHEN @material_ident like '20O' THEN 1.51
				WHEN @material_ident like '7OB' THEN 1.75
				WHEN @material_ident like 'AOR' THEN 1.60
				WHEN @material_ident like '40P' THEN 1.60
				WHEN @material_ident like '30R' THEN 1.65
				WHEN @material_ident like 'BRS' THEN 1.75
				WHEN @material_ident like 'DTS' THEN 1.18
				WHEN @material_ident like 'TTW' THEN 1.00
				WHEN @material_ident like '00W' THEN 1.21
				WHEN @material_ident like 'WSC' THEN 1.72
				WHEN @material_ident is null THEN 1.21
				END) ELSE 
@Wet_Tonnes / 
(
(COALESCE (@SA, 0)  * 1.58) + 
(COALESCE (@SM, 0) * 1.75) + 
(COALESCE (@FZ, 0) * 1.18) + 
(COALESCE (@LI, 0) * 1.45) + 
(COALESCE (@FEL, 0) * 1.11) + 
(COALESCE (@MAF, 0) * 1.18) + 
(COALESCE (@PC, 0) * 1.33) + 
(COALESCE (@UM, 0) * 1.18) + 
(COALESCE (@SIL, 0) * 1.18))   END )

END