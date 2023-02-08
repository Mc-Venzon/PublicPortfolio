Select * 
From PortfolioProject..NashvilleNatHousing

--Format date values
Select FormatedSaledate, Convert(Date, Saledate)
From PortfolioProject..NashvilleNatHousing


Update NashvilleNatHousing
Set SaleDate = cast (SaleDate as date);

Alter table NashvilleNatHousing
Add FormatedSaledate  date;

Update NashvilleNatHousing
Set FormatedSaledate = cast (SaleDate as date);


--------------------------------------------------------------------------------
--populate address field
Select *
From PortfolioProject..NashvilleNatHousing
Where PropertyAddress is null

Select ref.ParcelID, ref.PropertyAddress, fer.ParcelID, fer.PropertyAddress, ISNULL(ref.PropertyAddress, fer.PropertyAddress)
From PortfolioProject..NashvilleNatHousing ref
Join PortfolioProject..NashvilleNatHousing fer
	on ref.ParcelID = fer.ParcelID
	and ref.[UniqueID ]<>fer.[UniqueID ]
Where ref.PropertyAddress is null

update ref
set ref.PropertyAddress= ISNULL(ref.PropertyAddress, fer.PropertyAddress)
From PortfolioProject..NashvilleNatHousing ref
Join PortfolioProject..NashvilleNatHousing fer
	on ref.ParcelID = fer.ParcelID
	and ref.[UniqueID ]<>fer.[UniqueID ]
Where ref.PropertyAddress is null



---------------------------------------------------------------------------------------------------------------------
--separating and fixing the addresses
--1. property address------------------------------------------------------------------------------------------------
Select PropertyAddress
from PortfolioProject..NashvilleNatHousing

Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress)) as Address
From PortfolioProject..NashvilleNatHousing

Alter table NashvilleNatHousing
Add PropertyLocalAddress  NVARCHAR(255);

Update NashvilleNatHousing
Set PropertyLocalAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleNatHousing
Add PropertyCityAddress NVARCHAR(255);

Update NashvilleNatHousing
Set PropertyLocalAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN (PropertyAddress))

Select *
from PortfolioProject..NashvilleNatHousing


--2. Owner address------------------------------------------------------------------------------------------------

Select owneraddress
From PortfolioProject..NashvilleNatHousing;

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleNatHousing;

Alter table NashvilleNatHousing
Add OwnerLocalAddress  NVARCHAR(255);

Update NashvilleNatHousing
Set OwnerLocalAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

Alter table NashvilleNatHousing
Add OwnerCityAddress  NVARCHAR(255);

Update NashvilleNatHousing
Set OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

Alter table NashvilleNatHousing
Add OwnerStateAddress  NVARCHAR(255);

Update NashvilleNatHousing
Set OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);



----------------------------------------------------------------------------------------------------------------
--Change Y and N values to yes and no

Select Distinct(SoldasVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleNatHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From PortfolioProject..NashvilleNatHousing

Update NashvilleNatHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End;



-------------------------------------------------------------------------------------------------------------------------------
--remove duplicates
With CheckduplicatesCTE as(
Select *
, ROW_NUMBER() Over(
	partition by parcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num
From PortfolioProject..NashvilleNatHousing
)
Select * 
From CheckduplicatesCTE
Where row_num>1;


-------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns

Select * 
From PortfolioProject..NashvilleNatHousing

Alter Table PortfolioProject..NashvilleNatHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict