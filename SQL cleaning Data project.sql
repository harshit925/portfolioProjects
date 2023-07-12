/*

Cleaning data in SQL Qeries

*/

select * from PortfolioProject.dbo.NashvilleHousing



--Standardize Date Format

select saledate, convert(date,saledate)
from portfolioproject..NashvilleHousing



alter table NashvilleHousing
add saledateconverted date


update NashvilleHousing
set saledateconverted = convert(date,saledate)


select saledateconverted from NashvilleHousing



--populate property address data


select *
from portfolioproject..NashvilleHousing
--where propertyaddress is null
order by ParcelID


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from portfolioproject..NashvilleHousing a
join portfolioproject..NashvilleHousing b
on a.parcelid=b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null 


update a
set propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from portfolioproject..NashvilleHousing a
join portfolioproject..NashvilleHousing b
on a.parcelid=b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null 



--breaking out address into individual columns(address, city, state)


select propertyaddress 
from portfolioproject..NashvilleHousing;


select
substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as address,
substring(propertyaddress,CHARINDEX(',', propertyaddress)+1,len(propertyaddress)) as address
from portfolioproject..NashvilleHousing;


alter table portfolioproject..nashvillehousing
add propertysplitaddress nvarchar(255);

update portfolioproject..nashvillehousing
set propertysplitaddress=substring(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1);


alter table portfolioproject..nashvillehousing
add propertysplitcity nvarchar(255);

update portfolioproject..NashvilleHousing
set propertysplitcity=substring(propertyaddress,CHARINDEX(',', propertyaddress)+1,len(propertyaddress));



select * from portfolioproject..nashvillehousing








--lets work on owneraddress to split it but not with substring but some other simplerway(PARSENAME)

select owneraddress 
from portfolioproject..nashvillehousing



select
PARSENAME(REPLACE(owneraddress,',','.'),1),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),3)
from portfolioproject..nashvillehousing



alter table portfolioproject..nashvillehousing
add ownersplitaddress nvarchar(255);

update portfolioproject..nashvillehousing
set ownersplitaddress=PARSENAME(REPLACE(owneraddress,',','.'),3)



alter table portfolioproject..nashvillehousing
add ownwersplitcity nvarchar(255);

update portfolioproject..NashvilleHousing
set ownwersplitcity=PARSENAME(REPLACE(owneraddress,',','.'),2)



alter table portfolioproject..nashvillehousing
add ownersplitstate nvarchar(255);

update portfolioproject..NashvilleHousing
set ownersplitstate=PARSENAME(REPLACE(owneraddress,',','.'),1)


select * 
from portfolioproject..NashvilleHousing



--CHANGE Y AND N TO YES AND NO in 'SOLD AS VACANT' FIELD


select distinct(soldasvacant), count(soldasvacant)
from portfolioproject..NashvilleHousing
group by soldasvacant
order by 2


select soldasvacant,
case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end
from portfolioproject..NashvilleHousing



update portfolioproject..NashvilleHousing
set SoldAsVacant=case when soldasvacant='Y' then 'Yes'
when soldasvacant='N' then 'No'
else soldasvacant
end




--Remove Duplicate


with rownumCTE as (
select *,
ROW_NUMBER() over (
partition by parcelid,
			propertyaddress,
			saledate,
			legalreference
			order by uniqueid) as row_num
from portfolioproject..NashvilleHousing
)


delete
from rownumCTE
where row_num>1




-- delete unused columns


alter table portfolioproject..NashvilleHousing
drop column owneraddress, taxDistrict,PropertyAddress

