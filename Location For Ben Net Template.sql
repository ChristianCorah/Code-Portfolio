/*
This query pulls all HCC Locations IDs for one more suppliers. Columns Location_Number and 
Location_Check are used as a check to determine if there are any locations HCC IDs that were 
missed. Location_Number gives the location number specific to the supplier. It restarts for
each supplier. Location_Check makes sure the Location_Number on this report matches the location
number in the HCC_id column. If they don't match, the report is missing a location.
*/

Select DISTINCT 
	s.HCC_id, 
	sl.HCC_id,
	Row_Number() Over (Partition By s.hcc_id Order By sl.hcc_id) Location_Number, -- This is the location number for the supplier
	iif(Row_number() Over (Partition By s.hcc_id Order By sl.hcc_id) = right(sl.hcc_id,len(Row_number() Over (Partition By s.hcc_id Order By s.hcc_id))),'','Skipped Location') Location_Check -- This function checks whether the location number and HCC_ID location number match
From supp s
	Join supp_locn sl
	On s.supp_key = sl.supp_key
Where 
	s.HCC_id IN ('S00019672','S00020106','S00020981','S00020253') -- Add Supp_HCC_IDs for each group 
Order By 2