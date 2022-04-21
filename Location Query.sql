/*
This query is meant for the "Number of participating (in network) providers section of the
TDI quarterly report. It pulls all location of specific specialties. The dates can be changed 
in variables QS (start of quarter) and QE (end of quarter) to effect the entire query. The 
specialties can also be changed for the locations in the WHERE section. Per Ed Ochal, this 
report is done for all locations with a TX benefit network in ANY state. This can be changed
in the WHERE section if needed.
*/

DECLARE @QS AS DATE
Set @QS = '2021-10-01' -- Set start of quarter
DECLARE @QE AS DATE
Set @QE = '2022-01-01' -- Set end of quarter

Select DISTINCT
	sl.HCC_id, sl.supp_locn_name
From supp_locn sl
	Join addr a
	On sl.addr_key = a.addr_key
	Join prov_bnft_ntwk bn
	On sl.HCC_id = bn.prov_HCC_id
	Join supp s
	On sl.supp_key = s.supp_key
Where
	bn.bnft_ntwk_name LIKE '%TX%' AND
	bn.record_begin_date < @QE AND -- Checking if the BN is first on the location before the end of the quarter
	bn.record_end_date >= @QS AND -- Checking if the BN does not end before the start of the quarter
	--a.state_code = 'TX' AND
	sl.record_status_code = 'a' AND
	sl.record_end_date >= @QS AND -- Checking if the location does not go incative before the start of the quarter
	sl.prmry_txnmy_code IN ('261QU0200X','207P00000X','207PE0004X','207PP0204X') -- Checking type of location
	--AND s.HCC_id NOT IN ('S00002408','S00004085') -- Suppliers with locations incorerctly marked as hospital, add one to result
	Order By 1