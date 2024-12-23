﻿
-- =============================================
-- Author:		Karl Daws
-- Create date: 4/Sep/2012
-- Description:	All Cost Reallocation reports to be based off this view
-- 
-- Modified:
-- 2/Nov/12 KDaws - Added DUMP_LOC NOT LIKE '%SKIN' to prevent ROM% --> %SKIN movements (Expit --> %SKIN will be captured in 'DIRECT_HAUL')
-- 23/Jan/13 KDaws - Added Ore Leach, modified Utils
-- 3/Dec/2013 KDaws - Added '20O' to material list for Ore movements
-- 16/Dec/2013 KDaws - Added columns: LOAD_START_SHIFT_DATE, LOAD_START_SHIFT_IDENT, DUMP_END_SHIFT_IDENT
-- 1/Jul/2014 KDaws- Added '00W' & 'LAT' to CLEARING work for 0906DRAIN job
-- 30/Jul/2014 KDaws - Changed ROM% to ROM[A-Z] for DIRECT_HAUL and ROM_REHANDLE to prevent ROMRDCONST counting
-- 20/Aug/2014 KDaws - Added '10B' to ROM_REHANDLE
-- 2/Mar/2015 KDaws  - Added 'MILL' load/dump areas to 'OL'
-- 3/Mar/2015 KDaws - Added LOAD_LOC <> 'ROM_OVERSIZE' exception to ROM_REHANDLE
-- =============================================

CREATE VIEW [dbo].[Z_BUSINESS_RULES_HAULCYCLES]
AS

SELECT
--Business rules in order of priority
CASE
WHEN DUMP_LOC LIKE 'ROMBIN%' AND MAT IN ('20O','30R','40P','AOR') THEN 'ROMBIN_FEED'
WHEN LOAD_LOC LIKE '%.%' AND DUMP_LOC LIKE 'ROM[A-Z]' THEN 'DIRECT_HAUL'
WHEN DUMP_LOC LIKE 'ROM[A-Z]' AND DUMP_LOC NOT LIKE '%SKIN' AND MAT IN ('10B','20O','30R','40P','AOR') AND LOAD_LOC <> 'ROM_OVERSIZE' AND LOAD_LOC <> DUMP_LOC THEN 'ROM_REHANDLE'

--Clearing
WHEN LOAD_AREA LIKE '%CLEAR%' AND MAT IN ('DTS','TTW','00W','LAT') AND LOAD_LOC <> DUMP_LOC THEN 'CLEARING'

--HL
WHEN LOAD_LOC LIKE 'HLCELL[1-8]' THEN 'HL'
WHEN DUMP_LOC = 'HLROMPAD1' THEN 'HL'

--Scats
WHEN LOAD_AREA = 'SCATS' THEN 'SCATS'
WHEN DUMP_AREA = 'SCATS' THEN 'SCATS'

--Topsoil catch (not Rehab)
WHEN (DUMP_LOC LIKE '%TSOIL%' OR DUMP_LOC LIKE '%TOPSOIL%' OR DUMP_LOC LIKE '%TS%' OR DUMP_LOC LIKE '%TREE%') THEN 'TOPSOIL'

--Rehab
WHEN DUMP_AREA LIKE 'REHAB%' AND MAT IN ('DTS','TTW','LAT') THEN 'REHAB'

--Ore Leach (Inpit Tailings)
WHEN LOAD_AREA = 'TAILS' THEN 'OL'
WHEN LOAD_AREA = 'MILL' OR DUMP_AREA = 'MILL' THEN 'OL'

--Utils (Borefields, Sulphur SP, Pit Water)
WHEN LOAD_AREA = 'UTILS' THEN 'UTILS'
WHEN DUMP_AREA = 'UTILS' THEN 'UTILS'

--Catch generic production
WHEN LOAD_LOC LIKE '%.%' THEN 'EXPIT'
WHEN LOAD_LOC NOT LIKE '%.%' THEN 'REHANDLE'

--Catch rest
ELSE 'CATCH'
END AS BUS_RULE,
HAUL_CYCLE_REC_IDENT,
LOAD_LOC,
LOAD_AREA,
MAT,
DUMP_LOC,
DUMP_AREA,
LOADING_UNIT_IDENT, 
HAULING_UNIT_IDENT,
LOAD_START_SHIFT_DATE,
LOAD_START_SHIFT_IDENT,
DUMP_END_SHIFT_DATE,
DUMP_END_SHIFT_IDENT,
QUANTITY_REPORTING
FROM (
	SELECT
	HCT.HAUL_CYCLE_REC_IDENT,
	LOAD_LOCATION_SNAME AS LOAD_LOC,
	L_LOC.LOC_AREA AS LOAD_AREA,
	MATERIAL_IDENT AS MAT,
	DUMP_LOCATION_SNAME AS DUMP_LOC,
	D_LOC.LOC_AREA AS DUMP_AREA,
	LOADING_UNIT_IDENT,
	HAULING_UNIT_IDENT,
	LOAD_START_SHIFT_DATE,
	LOAD_START_SHIFT_IDENT,
	DUMP_END_SHIFT_DATE,
	DUMP_END_SHIFT_IDENT,
	QUANTITY_REPORTING
	FROM WencoReport.dbo.HAUL_CYCLE_TRANS AS HCT
	LEFT OUTER JOIN WencoReport.dbo.LOCATION AS L_LOC ON HCT.LOAD_LOCATION_SNAME = L_LOC.LOC_SNAME
	LEFT OUTER JOIN WencoReport.dbo.LOCATION AS D_LOC ON HCT.DUMP_LOCATION_SNAME = D_LOC.LOC_SNAME
) AS HCT