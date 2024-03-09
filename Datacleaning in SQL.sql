---Data cleaning in SQL
select *
from Housingdata.[dbo].[nashvillehousingdata]

-- Standardizing date format

select SaleDate, convert(date, SaleDate)
from Housingdata.[dbo].[nashvillehousingdata]

update nashvillehousingdata
set SaleDate = convert(date, SaleDate)

Alter table nashvillehousingdata
add Saledateconverted date;

update nashvillehousingdata
set Saledateconverted = convert(date, SaleDate)

select Saledateconverted
from Housingdata.[dbo].[nashvillehousingdata]

--Populating PropertyAddress Column

select *
from Housingdata.[dbo].[nashvillehousingdata]
order by ParcelID

select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,  b.PropertyAddress)
from Housingdata.[dbo].[nashvillehousingdata] a
join Housingdata.[dbo].[nashvillehousingdata] b
on a.ParcelID = b.ParcelID and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,  b.PropertyAddress)
from Housingdata.[dbo].[nashvillehousingdata] a
join Housingdata.[dbo].[nashvillehousingdata] b
on a.ParcelID = b.ParcelID and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--Dividing PropertyAddress column into individual columns (Address, City, State)

select PropertyAddress
from Housingdata.[dbo].[nashvillehousingdata]

select 
substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from Housingdata.[dbo].[nashvillehousingdata]

Alter table nashvillehousingdata
add PropertysplitAddress nvarchar(255);

update nashvillehousingdata
set PropertysplitAddress = substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

Alter table nashvillehousingdata
add PropertysplitCity nvarchar(255);

update nashvillehousingdata
set PropertysplitCity = substring(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from Housingdata.[dbo].[nashvillehousingdata]

--Dividing OwnerAddress in to individual columns(Address, city and state)

select OwnerAddress
from Housingdata.[dbo].[nashvillehousingdata]

select 
parsename(replace(OwnerAddress, ',', '.') , 3),
parsename(replace(OwnerAddress, ',', '.') , 2),
parsename(replace(OwnerAddress, ',', '.') , 1)
from Housingdata.[dbo].[nashvillehousingdata]

Alter table nashvillehousingdata
add OwnerAddresssplit nvarchar(255);

update nashvillehousingdata
set OwnerAddresssplit = parsename(replace(OwnerAddress, ',', '.') , 3)

Alter table nashvillehousingdata
add OwnerCity nvarchar(255);

update nashvillehousingdata
set OwnerCity = parsename(replace(OwnerAddress, ',', '.') , 2)

Alter table nashvillehousingdata
add OwnerState nvarchar(255);

update nashvillehousingdata
set OwnerState = parsename(replace(OwnerAddress, ',', '.') , 1)

select *
from Housingdata.[dbo].[nashvillehousingdata]

--Change Y and N to Yes and No in "Slod as Vacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Housingdata.[dbo].[nashvillehousingdata]
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
 from Housingdata.[dbo].[nashvillehousingdata]
update nashvillehousingdata
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
--Removing duplicates

with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
 from Housingdata.[dbo].[nashvillehousingdata]
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

with RowNumCTE as (
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
 from Housingdata.[dbo].[nashvillehousingdata]
)
delete
from RowNumCTE
where row_num > 1

select *
from Housingdata.[dbo].[nashvillehousingdata]

--Deleting unused columns

select *
from Housingdata.[dbo].[nashvillehousingdata]

alter table Housingdata.[dbo].[nashvillehousingdata]
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Housingdata.[dbo].[nashvillehousingdata]
drop column SaleDate