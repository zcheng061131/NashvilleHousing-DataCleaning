/*

Cleaning Data in SQL Queries

*/

use PortFolioProject;

Select *
From NashvilleHousing;

-- Standardize Date Format

Select SaleDateConverted, CONVERT(STR_TO_DATE(SaleDate, '%M %d,%Y'), Date)
From NashvilleHousing;


-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(STR_TO_DATE(SaleDate, '%M %d,%Y'), Date);


-- Populate Property Address data

Select *
From NashvilleHousing
Where PropertyAddress is null
order by ParcelID;



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IF(ISNULL(a.PropertyAddress),b.PropertyAddress, a.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;


Update NashvilleHousing a
INNER JOIN NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF(ISNULL(a.PropertyAddress),b.PropertyAddress, a.PropertyAddress)
Where a.PropertyAddress is null;



-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing;
# Where PropertyAddress is null
# order by ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
From NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));


Select *
From NashvilleHousing;





Select OwnerAddress
From NashvilleHousing;


Select
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 1), '.', -1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 2), '.', -1)
,SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 3), '.', -1)
From NashvilleHousing;



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 1), '.', -1);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 2), '.', -1);



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.') , '.', 3), '.', -1);



Select *
From NashvilleHousing;




-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;




-- Remove Duplicates


Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
order by ParcelID;


DROP TABLE IF EXISTS RowNumCTE;
CREATE TEMPORARY TABLE RowNumCTE
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
order by ParcelID
;

SELECT UniqueID
From RowNumCTE
Where row_num > 1;

DELETE FROM NashvilleHousing
WHERE UniqueID in (SELECT UniqueID
From RowNumCTE
Where row_num > 1);

# Order by PropertyAddress;

Select *
From NashvilleHousing;

-- Delete Unused Columns


Select *
From NashvilleHousing;


# ALTER TABLE NashvilleHousing
# DROP COLUMN OwnerAddress,
# DROP COLUMN TaxDistrict,
# DROP COLUMN PropertyAddress,
# DROP COLUMN SaleDate;



