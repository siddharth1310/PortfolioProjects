-- Cleaning Data in SQL Queries
select * from [Housing Data].dbo.National_Housing;


-- Standardize Date Format
select SaleDate, CONVERT(Date, SaleDate) from [Housing Data].dbo.National_Housing;

Alter table National_Housing add SaleDate_Converted Date;

select * from [Housing Data].dbo.National_Housing;

Update National_Housing set SaleDate_Converted = CONVERT(Date, SaleDate);

select * from [Housing Data].dbo.National_Housing;


-- Populate Property Address data
select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, 
ISNULL(a.propertyAddress, b.PropertyAddress)
from [Housing Data].dbo.National_Housing a 
join 
[Housing Data].dbo.National_Housing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by a.[UniqueID ]

update a set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from [Housing Data].dbo.National_Housing a join 
[Housing Data].dbo.National_Housing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select * from [Housing Data].dbo.National_Housing where PropertyAddress is null;


-- Breaking out address into Individual Columns (Address, City, States)
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from [Housing Data].dbo.National_Housing 
order by ParcelID;

Alter table National_Housing add Property_Split_Address Nvarchar(255);
Alter table National_Housing add City Nvarchar(255);

update National_Housing set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);
update National_Housing set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

select * from [Housing Data].dbo.National_Housing;

-- Owner Address
select OwnerAddress from [Housing Data].dbo.National_Housing;

select PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from National_Housing;

Alter table National_Housing add Owner_Split_Address Nvarchar(255);
Alter table National_Housing add Owner_Split_City Nvarchar(255);
Alter table National_Housing add Owner_Split_State Nvarchar(255);

update National_Housing set Owner_Split_Address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);
update National_Housing set Owner_Split_City = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);
update National_Housing set Owner_Split_State = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

select * from National_Housing;


-- Used to change the column name of city to property_split_city
EXEC sp_rename 'dbo.National_Housing.city', 'Property_Split_City', 'COLUMN';


-- Change Y and N to Yes and No in "Solid as Vacant" field
select Distinct(SoldAsVacant), count(*) from National_Housing group by SoldAsVacant order by 2;
update National_Housing set SoldAsVacant = 'No' where SoldAsVacant = 'N';
update National_Housing set SoldAsVacant = 'Yes' where SoldAsVacant = 'Y';


-- Remove Duplicates
----------- Using VTE
with RowNumCTE AS(select *, ROW_NUMBER() OVER 
(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num
from National_Housing)

select * from RowNumCTE where row_num > 1 order by [UniqueID ];
--delete from RowNumCTE where row_num > 1;

----------- Using Normal Convention
select * 
from (select *, ROW_NUMBER() OVER 
(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num
from National_Housing) as a 
where a.row_num > 1 order by a.[UniqueID ];


-- Delete unused columns
alter table National_Housing drop column OwnerAddress, TaxDistrict, PropertyAddress;
alter table National_Housing drop column SaleDate;
select * from National_Housing;