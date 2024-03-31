use PortfolioProject;

select * from dbo.NashvilleHousing;


-- Populate Property Address Data

select * from dbo.NashvilleHousing where PropertyAddress is NULL;

select * from dbo.NashvilleHousing order by ParcelID;

-- We can notice that If two properties(houses) have same parcel id their property address is also same 
-- We can use this idea to populate the missing property address fields.

select ParcelID,count(ParcelID) as count1 from dbo.NashvilleHousing group by ParcelID order by count1 desc ;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing as a 
inner join dbo.NashvilleHousing as b 
on a.ParcelID=b.ParcelID 
where a.UniqueID<>b.UniqueID and a.PropertyAddress is NULL;

-- What isnull does is if a column value is null then we specify what value should come instead of that

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing as a 
inner join dbo.NashvilleHousing as b 
on a.ParcelID=b.ParcelID 
where a.UniqueID<>b.UniqueID and a.PropertyAddress is NULL;


-- Breaking down Property Address into Address and City

select PropertyAddress from dbo.NashvilleHousing ;

select PropertyAddress , substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as propertysplitaddress,
substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) as propertysplitcity
from dbo.NashvilleHousing ;

-- We are identifying the index of comma and we are extracting all the characters 
-- before the comma as a column and all the characters after the comma as a column
-- In substring we specify the starting index and no of characters 
-- it's okay if no of characters is beyond the no of characters available it'll take the whole text
-- now we are adding those two columns to the table and adding all the values to it

alter table dbo.NashvilleHousing 
add propertysplitaddress varchar(50),propertysplitcity varchar(50);

update dbo.NashvilleHousing  set propertysplitaddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1),
propertysplitcity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress)) ;

select * from dbo.NashvilleHousing;

-- Breaking down owner address into address,city and state
select OwnerAddress from dbo.NashvilleHousing ;

-- Parsename acts just like split function in Python, but the delimiter for Parsename is '.'
-- So we replace ',' with '.' and apply parsename
-- Then we get the required fields

select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address, PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State,OwnerAddress
from dbo.NashvilleHousing ;

alter table dbo.NashvilleHousing
add ownersplitaddress varchar(50),ownersplitcity varchar(50),ownersplitstate varchar(50);

update dbo.NashvilleHousing
set ownersplitaddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
ownersplitcity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
ownersplitstate =PARSENAME(REPLACE(OwnerAddress,',','.'),1);

select * from dbo.NashvilleHousing;

-- Replacing Y with Yes and N with No in SoldAsVacant
select SoldAsVacant,count(SoldAsVacant) from dbo.NashvilleHousing
group by SoldAsVacant;

update dbo.NashvilleHousing SET
SoldAsVacant= case
when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant
end;

select SoldAsVacant,count(SoldAsVacant) from dbo.NashvilleHousing
group by SoldAsVacant;


-- Removing duplicates
-- Identify which combination will be unique and impossible to be the same 
-- Specify it in partition by

 select * from    
 (select *,ROW_NUMBER() over (PARTITION by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference Order by UniqueID) as c
 from dbo.NashvilleHousing)a where c<>1;

-- There are 104 duplicate records

with cte1 as
(select * from  (select *,ROW_NUMBER() over (PARTITION by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference Order by UniqueID) as c
 from dbo.NashvilleHousing)a where c<>1)
delete from cte1;

-- select * from cte1, delete from cte1 and not delete * from cte1. No * comes in delete!!!

-- Drop the unused columns
alter table dbo.NashvilleHousing
drop column OwnerAddress,PropertyAddress;