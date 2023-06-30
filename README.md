# Data-Cleaning-with-PostgreSQL
This PostgreSQL project mainly deals with cleaning the Nashville Housing Dataset.
The cleaning process is divided into several steps. These include:
* Standardizing the date format.
  Here, the date is changed from its initial format of 'Month DD, YYYY' to 'YYYY-MM-DD'
* Populating the Property Address Data
  All empty property address rows that shared other details to show that they belonged to the same person were populated.
* Breaking the Address into Individual Columns (Address, City, State)
  This led to the addition of three new columns.
* Changing the Y and N in the SoldAsVacant column into 'Yes' and 'No'
  For purposes of uniformity, all entries with Y and N were changed. 
* Removal of Duplicates
  All entries that were duplicates were dropped. These included entries that shared details such as property address, saledate, saleprice, and legalreference.
