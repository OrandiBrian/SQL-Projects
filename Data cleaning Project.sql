/*
Data cleaning in sql
working with the Nashville Housing dataset
*/

SELECT *
FROM  DataCleaning..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------
-- Standardizing the date format

SELECT SaleDateConv, convert(DATE, SaleDate)
FROM DataCleaning..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConv DATE

UPDATE NashvilleHousing
SET SaleDateConv = CONVERT(DATE, SaleDate)


------------------------------------------------------------------------------------------------------------------------------------------
-- Populating the property address data
-- checking for duplicate parcelid
SELECT *
FROM DataCleaning..NashvilleHousing
ORDER BY ParcelID


-- performing a self join
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID ] <> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out the address into individual columns

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address1
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address2
FROM NashvilleHousing

-- Adding the columns

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nVARCHAR(100)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nVARCHAR(100)

-- Populating the columns 

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

-- checking

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvilleHousing


-- OwnerAddress Split

SELECT OwnerAddress
FROM NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address1
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS Address2
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Address3
FROM NashvilleHousing

-- Adding columns

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nVARCHAR(100)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nVARCHAR(100)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nVARCHAR(100)

-- Populating the columns

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- checking

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------------
-- Solid vacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Counts
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM NashvilleHousing

-- Updating the table
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END


------------------------------------------------------------------------------------------------------------------------------------------
-- Removing duplicates

WITH Duplic 
AS
(SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference 
						ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
)
DELETE
FROM Duplic
WHERE row_num > 1


------------------------------------------------------------------------------------------------------------------------------------------
-- Dropping unused columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN	OwnerAddress, SaleDate, PropertyAddress, TaxDistrict 
