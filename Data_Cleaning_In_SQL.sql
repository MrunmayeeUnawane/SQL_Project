/*

Cleaning Data in SQL Queries

*/

select * from
[dbo].[NashvilleHousing]

-- Standardize Date Format

select SaleDate, CONVERT(date,SaleDate)
from [dbo].[NashvilleHousing]

update NashvilleHousing
set SaleDate= CONVERT(date,SaleDate)

-- If it doesn't Update properly

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted, CONVERT(date,SaleDate)
from [dbo].[NashvilleHousing]


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select *
from [dbo].[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [dbo].[NashvilleHousing]
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from [dbo].[NashvilleHousing]

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

select * from
[dbo].[NashvilleHousing]

--4. owner's address

select OwnerAddress
from [dbo].[NashvilleHousing]

select
PARSENAME(replace(OwnerAddress,',', '.'), 3),
PARSENAME(replace(OwnerAddress,',', '.'), 2),
PARSENAME(replace(OwnerAddress,',', '.'), 1)
from [dbo].[NashvilleHousing]

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',', '.'), 1)


select * from
[dbo].[NashvilleHousing]

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from [dbo].[NashvilleHousing]
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [dbo].[NashvilleHousing]

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) row_num
from [dbo].[NashvilleHousing]
--order by ParcelID
)
select *  
from RowNumCTE
where row_num >1
order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select * from
[dbo].[NashvilleHousing]

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate