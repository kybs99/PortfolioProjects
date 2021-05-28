-- Altering date format (Datetime to date)

Select SaleDate, CONVERT(DATE, SaleDate)
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


-- Populating the property address for missing values

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null
Order by a.ParcelID


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a 
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null



-- Partitioning address into address, city, and state column

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress  nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,  CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



-- Change Y and N  to Yes and No for Sold as vacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant


Select SoldAsVacant, 
CASE
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	ELSE SoldAsVacant 
END
From PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
Set SoldAsVacant = 
CASE
	When SoldAsVacant = 'N' Then 'No'
	When SoldAsVacant = 'Y' Then 'Yes'
	ELSE SoldAsVacant 
END



-- Removing Duplicates

With RowNumCTE AS ( 
Select *,
ROW_NUMBER() OVER 
	(PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDateConverted,
				  LegalReference
				  ORDER BY 
					UniqueID) row_num
From PortfolioProject..NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num > 1


-- Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress