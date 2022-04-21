/*
This query pulls all providers affiliated with one or multiple Tax IDs. It is filtered to providers
with active roles as of today. The data included is the provider NPI, full name, Tax ID, role effective date,
and all address information. It is first ordered by Tax ID and then ordered by provider full name within
each Tax ID.
*/

Select DISTINCT
	p.npi NPI, 
	p.full_name 'Full Name', 
	s.tax_id 'Tax ID', 
	pr.prctnr_role_eff_date 'Effective Date', 
	a.addr_line_1 'Address Line 1', 
	isnull(a.addr_line_2,'') 'Address Line 2', 
	isnull(a.addr_line_3,'') 'Address Line 3', 
	a.city_name 'City', 
	a.state_code 'State'
From prctnr p
	Join prctnr_role pr
	On pr.prctnr_key = p.prctnr_key
	Join supp_locn sl
	On pr.supp_locn_HCC_id = sl.hcc_id
	Join addr a
	On sl.addr_key = a.addr_key
	Join supp s
	On sl.supp_key = s.supp_key
	Join prov_bnft_ntwk bn
	On 
		sl.HCC_id = bn.prov_HCC_id AND
		bn.record_end_date >= GETDATE() -- Data from this table is not included in the report, it is just used to ensure the addresses listed have benefit networks
Where 
	pr.prctnr_role_status = 'a' AND 
	pr.record_end_date >= GETDATE() AND -- These two statements filter to active roles as of today
	s.tax_id IN ('00-0000000') -- Change TIN to switch between groups
Order By 3,2;