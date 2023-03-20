--Cleaning Data in SQL Queries


select *
from PortfolioProj2..NashvilleHousing



--Standardize Date format



Select saledateconverted, convert(date, saledate)
from PortfolioProj2..NashvilleHousing

alter table nashvillehousing
add saledateconverted date

update NashvilleHousing
set saledateconverted = convert(date, saledate)

 



--Populate Property address data



Select *
from PortfolioProj2..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.[UniqueID ] , a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProj2..NashvilleHousing a
join PortfolioProj2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProj2..NashvilleHousing a
join PortfolioProj2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns (address, city, state)


select 
substring(propertyaddress, 1, charindex(',' , propertyaddress) -1) as address,
substring(propertyaddress, charindex(',' , propertyaddress) +1, len(propertyaddress)) as city
from PortfolioProj2..NashvilleHousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255)

update NashvilleHousing
set Propertysplitaddress = substring(propertyaddress, 1, charindex(',' , propertyaddress) -1)

alter table nashvillehousing
add propertysplitcity nvarchar(255)

update NashvilleHousing
set Propertysplitcity = substring(propertyaddress, charindex(',' , propertyaddress) +1, len(propertyaddress))

select *
from PortfolioProj2..NashvilleHousing


--2nd way : parse name -->only useful for periods. So in this case, we change the comma to a period

select OwnerAddress
from PortfolioProj2..NashvilleHousing

select 
owneraddress,
parsename(replace(owneraddress,',','.'), 3),
parsename(replace(owneraddress,',','.'), 2),
parsename(replace(owneraddress,',','.'), 1)
from PortfolioProj2..NashvilleHousing

alter table nashvillehousing
add ownersplitaddress nvarchar(255)

update NashvilleHousing
set ownersplitaddress = parsename(replace(owneraddress,',','.'), 3)

alter table nashvillehousing
add ownersplitcity nvarchar(255)

update NashvilleHousing
set ownersplitcity = parsename(replace(owneraddress,',','.'), 2)

alter table nashvillehousing
add ownersplitstate nvarchar(255)

update NashvilleHousing
set ownersplitstate = parsename(replace(owneraddress,',','.'), 1)

select *
from PortfolioProj2..NashvilleHousing


--Change Y and N to yes and no in 'sold as vacant' field

select distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProj2..NashvilleHousing
group by SoldAsVacant
order by 2 desc


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'yes'
	   when soldasvacant = 'N' then 'no'
	   else SoldAsVacant
	   END
from PortfolioProj2..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'yes'
	   when soldasvacant = 'N' then 'no'
	   else SoldAsVacant
	   END


--remove duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 saledate,
				 legalreference
				 order by
					uniqueid
					) row_num

from PortfolioProj2..NashvilleHousing
)
SELECT *
from RowNumCTE
where row_num > 1
order by PropertyAddress


--delete unused columns

select *
from PortfolioProj2..NashvilleHousing

alter table portfolioproj2..nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress

alter table portfolioproj2..nashvillehousing
drop column saledate