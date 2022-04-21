/*
This query pulls all locations affialied with a certain benefit network. It is filtered by benefit network
and looks as of a certain date. This date can be today for states we are in, or a future date for states
we are not in yet. Information provided is supplier name, supplier HCC ID, tax ID, location name, location 
HCC ID, all addrss information, and all benefit networks for the location listed in one line.
*/

With Ben_Net_Query as 
	(Select 
		sl.HCC_id, 
		bn.record_end_date,
		(Select 
			'; ' + bn.bnft_ntwk_name
		From prov_bnft_ntwk bn
		Where bn.prov_HCC_id = sl.HCC_id
		Order By bn.bnft_ntwk_name
		For XML PATH('')) Benefit_Networks
	From supp_locn sl
		Join prov_bnft_ntwk bn
		On sl.HCC_id = bn.prov_HCC_id) -- This subquery is used to place all benefit networks for each location on one line

Select DISTINCT 
	s.supp_name, 
	s.HCC_id, 
	s.tax_id, 
	sl.supp_locn_name, 
	sl.HCC_id, a.addr_line_1, 
	isnull(a.addr_line_2,'') addre_line_2, 
	isnull(a.addr_line_3,'') addr_line_3, 
	a.state_name, 
	right(bq.Benefit_Networks,
	LEN(bq.Benefit_Networks)-1) 'Benefit Networks'
From supp_locn sl
	Join Ben_Net_Query bq
	On sl.HCC_id = bq.HCC_id
	Join supp s
	On sl.supp_key = s.supp_key
	Join addr a
	On sl.addr_key = a.addr_key
Where 
	bq.Benefit_Networks LIKE '%GA%' AND -- Change state code to switch between states
	bq.record_end_date >=GETDATE() AND 
	sl.record_end_date >= GETDATE() -- Change dates to look for future states (2023-01-01)
Order By 3