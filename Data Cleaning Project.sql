Select *
From PortfolioProjects.dbo.NashvilleHousing



-- Standardizing Date Format 2 ways --


Select SaleDate, CONVERT (Date,SaleDate)
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
	Add SaleDateConverted = CONVERT(Date,SaleDate)

Update NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)


-- Populate Property Address Data --



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a 
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.NashvilleHousing a 
JOIN PortfolioProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking Out Address Into Individual Columns (Address, City, State) --



SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
	Add PropertySplitAddress Nvarchar(255)
Update NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
ALTER TABLE NashvilleHousing
	Add PropertySplitCity Nvarchar(255)
Update NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))



-- Changing Y and N to Yes and No in "Sold as Vacant" field --


Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Removing Duplicates --

WITH RowNumCTE AS(
SELECT *
	, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID
			) row_num

From PortfolioProjects.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

-- Deleting Unused Columns --

SELECT *
FROM PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate
