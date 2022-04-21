/*
This query is meant for the "Number of participating (in network) providers section of the
TDI quarterly report. It pulls all providers of specific specialties that are active at a 
location of specific specialties in a specific quarter. The dates can be changed in variables 
QS (start of quarter) and QE (end of quarter) to effect the entire query. The specialties can 
also be changed for the practitioners and locations in the WHERE section. Per Ed Ochal, this 
report is done for all locations with a TX benefit network in ANY state. This can be changed
in the WHERE section if needed.
*/

DECLARE @QS AS DATE
Set @QS = '2022-01-01' -- Set start of quarter for query
DECLARE @QE AS DATE
Set @QE = '2022-04-01' -- Set end of quarter for query

Select DISTINCT pr.prctnr_NPI
From prctnr_role pr
	Join supp_locn sl
	On pr.supp_locn_HCC_id = sl.HCC_id
	Join addr a
	On sl.addr_key = a.addr_key
	Join prov_bnft_ntwk bn
	On sl.HCC_id = bn.prov_HCC_id
Where
	bn.bnft_ntwk_name LIKE '%TX%' AND
	bn.record_begin_date < @QE AND -- Checking if the BN is first on the location before the end of the quarter
	bn.record_end_date >= @QS AND -- Checking if the BN does not end before the start of the quarter
	--a.state_code IN ('TX') AND -- Toggle this on and off to makesure all providers are located in TX, or include INN TX facilties in ALL states
	sl.record_status_code = 'a' AND
	sl.record_end_date >= @QS AND -- Checking if the location doe snot end before the start of the quarter
	sl.prmry_txnmy_code NOT IN ('291U00000X','261QU0200X','207P00000X','207PE0004X','207PP0204X') AND -- Checking type of location
	pr.prctnr_role_status = 'a' AND
	pr.record_end_date >= @QS AND -- Checking if the role does not end before the start of the quarter
	pr.prctnr_role_eff_date < @QE -- Checking if the role is first active before the end of the quarter
	AND pr.prctnr_role_txnmy_code IN ('246ZC0007X','363AS0400X') -- Checking type of provider
