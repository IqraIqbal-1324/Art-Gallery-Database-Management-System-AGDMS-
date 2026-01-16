# Art-Gallery-Database-Management-System-AGDMS-
Implementation of a comprehensive database management system for art galleries that manages artists, artworks, customers, employees, exhibitions, orders, and ticketing operations while maintaining complete audit trails and price history tracking. 

A detailed project report is also attached in this repository for design explanation, ER diagrams, normalization, and documentation.

## 🗂️ Database Tables

Main entities include:
- ARTIST  
- CUSTOMER  
- EMPLOYEE  
- EXHIBITION  
- ARTWORK  
- ORDERS  
- ORDERLINE  
- TICKET  

Supporting tables:
- ARTIST_ARTSTYLE  
- ARTIST_ADDRESS  
- Customer_Preference  
- CUSTOMER_Location  
- EXHIBITION_LOCATION  
- ARTWORK_RANGE  
- ARTWORK_DIMENSIONS  
- ORDER_SHIPMENT  


## ⚙️ Technologies Used

- Microsoft SQL Server
- T-SQL (DDL, DML, Stored Procedures, Triggers)

## ▶️ How to Run the Project

1. Open **SQL Server Management Studio (SSMS)**.
2. Create a new query window.
3. Paste the full SQL script provided in this repository.
4. Execute the script.
5. The database `ArtGalleryDB` will be created and populated automatically.

To verify data:

```sql
SELECT * FROM ARTIST;
SELECT * FROM CUSTOMER;
SELECT * FROM EMPLOYEE;
SELECT * FROM EXHIBITION;
SELECT * FROM ARTWORK;
SELECT * FROM ORDERS;
SELECT * FROM ORDERLINE;
SELECT * FROM TICKET;
