-- Cleaning Data in SQL
-- Viewing the entire dataset
select *
from nashville_housing nh 


-----------------------------------------------
-- 1. Standardizing the Date Format

select saledate, to_char(to_date(saledate, 'Month DD, YYYY'), 
	'YYYY-MM-DD')
from nashville_housing nh 

update nashville_housing 
set saledate = to_char(to_date(saledate, 'Month DD, YYYY'),'YYYY-MM-DD')



--------------------------------------------------
-- 2. Populating Property Address Data
-- Use the COALESE function to change the address

select * 
from nashville_housing nh 
where propertyaddress is null
--

select nh.parcelid, nh.propertyaddress, nh2.parcelid, 
	nh2.propertyaddress, coalesce(nh.propertyaddress, nh2.propertyaddress)
from nashville_housing nh 
join nashville_housing nh2
	on nh.parcelid = nh2.parcelid 
	and nh."UniqueID " != nh2."UniqueID "  
where nh.propertyaddress is null

--

update nashville_housing 
set propertyaddress = coalesce(nh.propertyaddress, nh2.propertyaddress)
from nashville_housing nh 
join nashville_housing nh2
	on nh.parcelid = nh2.parcelid 
	and nh."UniqueID " != nh2."UniqueID "  
where nh.propertyaddress is null




--------------------------------------------------
-- 3. Breaking out Address into Individual Columns (Address, City, State)

select substring(propertyaddress, 1, position(',' in propertyaddress) -1) as Address,
	   substring(propertyaddress, position(',' in propertyaddress)+1) as City
from nashville_housing nh 

--
alter table nashville_housing 
add address varchar(255)
--

update nashville_housing 
set address = substring(propertyaddress, 1, position(',' in propertyaddress) -1)

--
alter table nashville_housing 
add city varchar(255)

--
update nashville_housing 
set city = substring(propertyaddress, position(',' in propertyaddress)+1)

-- Getting the state from the Owner Address
select split_part(owneraddress, ',', 1) as address,
	   split_part(owneraddress, ',', 2) as city,
	   split_part(owneraddress, ',', 3) as state
from nashville_housing nh 

--
alter table nashville_housing 
add owner_postcode varchar(255),
add owner_city varchar(255),
add owner_state varchar(255)

--
update nashville_housing 
	set owner_state = split_part(owneraddress, ',', 3)



-- 4. Changing the Y and N into Yes and No in the 'Sold as Vacant' Field

select distinct soldasvacant, count(soldasvacant)  
from nashville_housing nh 
group by soldasvacant 
order by 2 desc

-- Using CASE to change the Ys and Ns

select soldasvacant, 
	case
		when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant
	end
from nashville_housing nh 
	
-- Updating the change to the column

update nashville_housing 
set soldasvacant = case
					when soldasvacant = 'Y' then 'Yes'
					when soldasvacant = 'N' then 'No'
					else soldasvacant
				   end

	

-- 5. Removing Duplicates

select *,
	row_number () over(
		partition by parcelid,
					propertyaddress,
					saledate,
					saleprice,
					legalreference
					order by 
						'UniqueID'
	) as row_num
from nashville_housing nh 
order by parcelid 
				   

-- Using CTE to Retrieve the Duplicated Rows

with RowNumCTE as(
	select *,
		row_number () over(
			partition by parcelid,
					propertyaddress,
					saledate,
					saleprice,
					legalreference
					order by 
						'UniqueID'
		) as row_num
	from nashville_housing nh 
	--order by parcelid
)

select *
from RowNumCTE
where row_num > 1
order by propertyaddress 

-- Deleting the Duplicates
-- Will make use of the same query above

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid, 
            	propertyaddress, 
            	saledate, 
            	saleprice, 
            	legalreference
            ORDER BY 'UniqueID'
        ) AS row_num
    FROM nashville_housing
)

DELETE FROM nashville_housing
WHERE (parcelid, propertyaddress, saledate, saleprice, legalreference) IN (
    SELECT parcelid, propertyaddress, saledate, saleprice, legalreference
    FROM RowNumCTE
    WHERE row_num > 1
)
