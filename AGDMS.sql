-- Art Gallery Database Schema

CREATE DATABASE ArtGalleryDB;
USE ArtGalleryDB;


-- Create ARTIST table
CREATE TABLE ARTIST (
    ArtistID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Biography TEXT,
    BirthDate DATE,
    Nationality VARCHAR(50),
    ContactPhone VARCHAR(20),
    ContactEmail VARCHAR(100),
    RegistrationDate DATE
);

-- Create CUSTOMER table
CREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    TotalPurchaseAmount DECIMAL(10,2),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    RegistrationDate DATE
);

-- Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    HireDate DATE,
    Salary DECIMAL(10,2),
    Department VARCHAR(50)
);

-- Create EXHIBITION table
CREATE TABLE EXHIBITION (
    ExhibitionID INT PRIMARY KEY IDENTITY(1,1),
    ExhibitionName VARCHAR(100),
    Description TEXT,
    StartDate DATE,
    EndDate DATE,
    TicketPrice DECIMAL(10,2),
    MaxCapacity INT,
    Theme VARCHAR(100)
);

-- Create ARTWORK table
CREATE TABLE ARTWORK (
    ArtworkID INT PRIMARY KEY IDENTITY(1,1),
    ArtistID INT,
    Title VARCHAR(100),
    CreationYear INT,
    CurrentPrice DECIMAL(10,2),
    Medium VARCHAR(50),
    AcquisitionDate DATE,
    CurrentStatus VARCHAR(50),
    FOREIGN KEY (ArtistID) REFERENCES ARTIST(ArtistID)
);

-- Create ORDERS table
CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    PaymentMethod VARCHAR(50),
    PaymentStatus VARCHAR(50),
    TotalAmount DECIMAL(10,2),
    ContactEmail VARCHAR(100),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES EMPLOYEE(EmployeeID)
);

-- Create ORDERLINE table
CREATE TABLE ORDERLINE (
    OrderLineID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ArtWorkID INT,
    SalePrice DECIMAL(10,2),
    Commission DECIMAL(10,2),
    LineTotal DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ArtWorkID) REFERENCES ARTWORK(ArtworkID)
);

-- Create TICKET table
CREATE TABLE TICKET (
    TicketID INT PRIMARY KEY IDENTITY(1,1),
    ExhibitionID INT,
    CustomerID INT,
    VisitDate DATE,
    PaymentStatus VARCHAR(50),
    TicketType VARCHAR(50),
    TicketPrice DECIMAL(10,2),
    PurchaseDate DATE,
    FOREIGN KEY (ExhibitionID) REFERENCES EXHIBITION(ExhibitionID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

-- Create ARTIST_ARTSTYLE table
CREATE TABLE ARTIST_ARTSTYLE (
    ArtistID INT,
    ArtStyle VARCHAR(50),
    PRIMARY KEY (ArtistID, ArtStyle),
    FOREIGN KEY (ArtistID) REFERENCES ARTIST(ArtistID)
);

-- Create ARTIST_ADDRESS table
CREATE TABLE ARTIST_ADDRESS (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    ArtistID INT,
    Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    FOREIGN KEY (ArtistID) REFERENCES ARTIST(ArtistID)
);

-- Create Customer_Preference table
CREATE TABLE Customer_Preference (
    CustomerID INT PRIMARY KEY,
    PreferredArtStyles VARCHAR(200),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

-- Create CUSTOMER_Location table
CREATE TABLE CUSTOMER_Location (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

-- Create EXHIBITION_LOCATION table
CREATE TABLE EXHIBITION_LOCATION (
    ExhibitionID INT PRIMARY KEY,
    Hall VARCHAR(50),
    Floor VARCHAR(20),
    Building VARCHAR(50),
    FOREIGN KEY (ExhibitionID) REFERENCES EXHIBITION(ExhibitionID)
);

-- Create ARTWORK_RANGE table
CREATE TABLE ARTWORK_RANGE (
    ArtworkID INT PRIMARY KEY,
    PriceHistory TEXT,
    FOREIGN KEY (ArtworkID) REFERENCES ARTWORK(ArtworkID)
);

-- Create ARTWORK_DIMENSIONS table
CREATE TABLE ARTWORK_DIMENSIONS (
    ArtworkID INT PRIMARY KEY,
    Height DECIMAL(10,2),
    Width DECIMAL(10,2),
    Depth DECIMAL(10,2),
    FOREIGN KEY (ArtworkID) REFERENCES ARTWORK(ArtworkID)
);

-- Create ORDER_SHIPMENT table
CREATE TABLE ORDER_SHIPMENT (
    OrderID INT PRIMARY KEY,
    Street VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    ZipCode VARCHAR(20),
    Country VARCHAR(50),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID)
);




GO
-- STORED PROCEDURES

-- 1. Add New Artist
CREATE PROCEDURE sp_AddArtist
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Biography TEXT,
    @BirthDate DATE,
    @Nationality VARCHAR(50),
    @ContactPhone VARCHAR(20),
    @ContactEmail VARCHAR(100)
AS
BEGIN
    INSERT INTO ARTIST (FirstName, LastName, Biography, BirthDate, Nationality, ContactPhone, ContactEmail, RegistrationDate)
    VALUES (@FirstName, @LastName, @Biography, @BirthDate, @Nationality, @ContactPhone, @ContactEmail, GETDATE());
END;
GO


-- 2. Add New Artwork
CREATE PROCEDURE sp_AddArtwork
    @ArtistID INT,
    @Title VARCHAR(100),
    @CreationYear INT,
    @CurrentPrice DECIMAL(10,2),
    @Medium VARCHAR(50),
    @CurrentStatus VARCHAR(50)
AS
BEGIN
    INSERT INTO ARTWORK (ArtistID, Title, CreationYear, CurrentPrice, Medium, AcquisitionDate, CurrentStatus)
    VALUES (@ArtistID, @Title, @CreationYear, @CurrentPrice, @Medium, GETDATE(), @CurrentStatus);
END;
GO

-- 3. Create New Order
CREATE PROCEDURE sp_CreateOrder
    @CustomerID INT,
    @EmployeeID INT,
    @PaymentMethod VARCHAR(50),
    @ContactEmail VARCHAR(100)
AS
BEGIN
    INSERT INTO ORDERS (CustomerID, EmployeeID, OrderDate, PaymentMethod, PaymentStatus, TotalAmount, ContactEmail)
    VALUES (@CustomerID, @EmployeeID, GETDATE(), @PaymentMethod, 'Pending', 0.00, @ContactEmail);
    
    SELECT SCOPE_IDENTITY() AS NewOrderID;
END;
GO

-- 4. Add Order Line Item
CREATE PROCEDURE sp_AddOrderLine
    @OrderID INT,
    @ArtworkID INT,
    @SalePrice DECIMAL(10,2),
    @CommissionRate DECIMAL(5,2)
AS
BEGIN
    DECLARE @Commission DECIMAL(10,2);
    DECLARE @LineTotal DECIMAL(10,2);
    
    SET @Commission = @SalePrice * (@CommissionRate / 100);
    SET @LineTotal = @SalePrice + @Commission;
    
    INSERT INTO ORDERLINE (OrderID, ArtWorkID, SalePrice, Commission, LineTotal)
    VALUES (@OrderID, @ArtworkID, @SalePrice, @Commission, @LineTotal);
END;
GO

-- 5. Register Customer
CREATE PROCEDURE sp_RegisterCustomer
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Phone VARCHAR(20),
    @Email VARCHAR(100)
AS
BEGIN
    INSERT INTO CUSTOMER (FirstName, LastName, TotalPurchaseAmount, Phone, Email, RegistrationDate)
    VALUES (@FirstName, @LastName, 0.00, @Phone, @Email, GETDATE());
    
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;
GO

-- 6. Purchase Ticket
CREATE PROCEDURE sp_PurchaseTicket
    @ExhibitionID INT,
    @CustomerID INT,
    @VisitDate DATE,
    @TicketType VARCHAR(50)
AS
BEGIN
    DECLARE @TicketPrice DECIMAL(10,2);
    
    SELECT @TicketPrice = TicketPrice FROM EXHIBITION WHERE ExhibitionID = @ExhibitionID;
    
    INSERT INTO TICKET (ExhibitionID, CustomerID, VisitDate, PaymentStatus, TicketType, TicketPrice, PurchaseDate)
    VALUES (@ExhibitionID, @CustomerID, @VisitDate, 'Paid', @TicketType, @TicketPrice, GETDATE());
END;
GO

-- 7. Get Artist Artworks
CREATE PROCEDURE sp_GetArtistArtworks
    @ArtistID INT
AS
BEGIN
    SELECT * FROM ARTWORK WHERE ArtistID = @ArtistID;
END;
GO

-- 8. Get Customer Order History
CREATE PROCEDURE sp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT O.*, OL.ArtWorkID, OL.SalePrice, A.Title
    FROM ORDERS O
    JOIN ORDERLINE OL ON O.OrderID = OL.OrderID
    JOIN ARTWORK A ON OL.ArtWorkID = A.ArtworkID
    WHERE O.CustomerID = @CustomerID;
END;
GO

-- 9. Update Artwork Status
CREATE PROCEDURE sp_UpdateArtworkStatus
    @ArtworkID INT,
    @NewStatus VARCHAR(50)
AS
BEGIN
    UPDATE ARTWORK
    SET CurrentStatus = @NewStatus
    WHERE ArtworkID = @ArtworkID;
END;
GO

-- 10. Get Exhibition Statistics
CREATE PROCEDURE sp_GetExhibitionStats
    @ExhibitionID INT
AS
BEGIN
    SELECT 
        E.ExhibitionName,
        COUNT(T.TicketID) AS TotalTicketsSold,
        SUM(T.TicketPrice) AS TotalRevenue,
        E.MaxCapacity,
        (E.MaxCapacity - COUNT(T.TicketID)) AS RemainingCapacity
    FROM EXHIBITION E
    LEFT JOIN TICKET T ON E.ExhibitionID = T.ExhibitionID
    WHERE E.ExhibitionID = @ExhibitionID
    GROUP BY E.ExhibitionName, E.MaxCapacity;
END;
GO



SELECT * FROM sys.tables;

EXEC sp_MSforeachtable 'SELECT * FROM ?';

SELECT * FROM ARTIST;
SELECT * FROM CUSTOMER;
SELECT * FROM EMPLOYEE;
SELECT * FROM EXHIBITION;
SELECT * FROM ARTWORK;
SELECT * FROM ORDERS;
SELECT * FROM ORDERLINE;
SELECT * FROM TICKET;
SELECT * FROM ARTIST_ARTSTYLE;
SELECT * FROM ARTIST_ADDRESS;
SELECT * FROM Customer_Preference;
SELECT * FROM CUSTOMER_Location;
SELECT * FROM EXHIBITION_LOCATION;
SELECT * FROM ARTWORK_RANGE;
SELECT * FROM ARTWORK_DIMENSIONS;
SELECT * FROM ORDER_SHIPMENT;

-- TRIGGERS

-- 1. Update Order Total After OrderLine Insert
CREATE TRIGGER trg_UpdateOrderTotal
ON ORDERLINE
AFTER INSERT
AS
BEGIN
    UPDATE ORDERS
    SET TotalAmount = (
        SELECT SUM(LineTotal)
        FROM ORDERLINE
        WHERE OrderID = i.OrderID
    )
    FROM ORDERS O
    INNER JOIN inserted i ON O.OrderID = i.OrderID;
END;
GO

-- 2. Update Customer Total Purchase Amount
CREATE TRIGGER trg_UpdateCustomerPurchaseAmount
ON ORDERS
AFTER UPDATE
AS
BEGIN
    IF UPDATE(PaymentStatus)
    BEGIN
        UPDATE CUSTOMER
        SET TotalPurchaseAmount = TotalPurchaseAmount + i.TotalAmount
        FROM CUSTOMER C
        INNER JOIN inserted i ON C.CustomerID = i.CustomerID
        INNER JOIN deleted d ON i.OrderID = d.OrderID
        WHERE i.PaymentStatus = 'Completed' AND d.PaymentStatus <> 'Completed';
    END;
END;
GO

-- 3. Update Artwork Status on Sale
CREATE TRIGGER trg_UpdateArtworkOnSale
ON ORDERLINE
AFTER INSERT
AS
BEGIN
    UPDATE ARTWORK
    SET CurrentStatus = 'Sold'
    FROM ARTWORK A
    INNER JOIN inserted i ON A.ArtworkID = i.ArtWorkID;
END;
GO

-- 4. Prevent Order Deletion if Completed
CREATE TRIGGER trg_PreventCompletedOrderDeletion
ON ORDERS
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE PaymentStatus = 'Completed')
    BEGIN
        RAISERROR ('Cannot delete completed orders', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM ORDERS WHERE OrderID IN (SELECT OrderID FROM deleted);
    END;
END;
GO

-- 5. Log Price Changes in Artwork
CREATE TRIGGER trg_LogArtworkPriceChange
ON ARTWORK
AFTER UPDATE
AS
BEGIN
    IF UPDATE(CurrentPrice)
    BEGIN
        UPDATE ARTWORK_RANGE
        SET PriceHistory = CONCAT(
            ISNULL(PriceHistory, ''), 
            FORMAT(GETDATE(), 'yyyy-MM-dd'), 
            ': $', 
            CAST(i.CurrentPrice AS VARCHAR), 
            '; '
        )
        FROM ARTWORK_RANGE AR
        INNER JOIN inserted i ON AR.ArtworkID = i.ArtworkID;
    END;
END;
GO

-- 6. Validate Exhibition Capacity
CREATE TRIGGER trg_ValidateTicketCapacity
ON TICKET
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ExhibitionID INT;
    DECLARE @MaxCapacity INT;
    DECLARE @CurrentTickets INT;
    
    SELECT @ExhibitionID = ExhibitionID FROM inserted;
    
    SELECT @MaxCapacity = MaxCapacity FROM EXHIBITION WHERE ExhibitionID = @ExhibitionID;
    SELECT @CurrentTickets = COUNT(*) FROM TICKET WHERE ExhibitionID = @ExhibitionID;
    
    IF @CurrentTickets >= @MaxCapacity
    BEGIN
        RAISERROR ('Exhibition is at full capacity', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO TICKET (ExhibitionID, CustomerID, VisitDate, PaymentStatus, TicketType, TicketPrice, PurchaseDate)
        SELECT ExhibitionID, CustomerID, VisitDate, PaymentStatus, TicketType, TicketPrice, PurchaseDate
        FROM inserted;
    END;
END;
GO




-- POPULATE ART GALLERY DATABASE
-- 10 Records per Table 

-- Insert ARTIST (10 records)
INSERT INTO ARTIST (FirstName, LastName, Biography, BirthDate, Nationality, ContactPhone, ContactEmail, RegistrationDate)
VALUES 
('Ahmed', 'Khan', 'Contemporary calligraphy and Islamic art specialist', '1985-03-15', 'Pakistani', '0300-1234501', 'ahmed.khan@email.com', '2023-01-10'),
('Fatima', 'Ahmed', 'Miniature painter following Mughal traditions', '1990-07-22', 'Pakistani', '0321-1234502', 'fatima.ahmed@email.com', '2023-02-15'),
('Ali', 'Hassan', 'Modern landscape and cityscape artist', '1988-11-30', 'Pakistani', '0333-1234503', 'ali.hassan@email.com', '2023-03-20'),
('Ayesha', 'Malik', 'Portrait and figurative painter', '1982-05-18', 'Pakistani', '0301-1234504', 'ayesha.malik@email.com', '2023-04-05'),
('Usman', 'Raza', 'Mixed media and installation artist', '1995-09-12', 'Pakistani', '0345-1234505', 'usman.raza@email.com', '2023-05-18'),
('Zainab', 'Siddiqui', 'Contemporary textile and embroidery artist', '1987-12-08', 'Pakistani', '0312-1234506', 'zainab.siddiqui@email.com', '2023-06-22'),
('Hamza', 'Butt', 'Abstract painter and digital artist', '1980-04-25', 'Pakistani', '0335-1234507', 'hamza.butt@email.com', '2023-07-30'),
('Maryam', 'Iqbal', 'Watercolor artist specializing in nature', '1992-08-14', 'Pakistani', '0303-1234508', 'maryam.iqbal@email.com', '2023-08-12'),
('Bilal', 'Shah', 'Sculpture and ceramic artist', '1986-02-28', 'Pakistani', '0322-1234509', 'bilal.shah@email.com', '2023-09-15'),
('Sara', 'Javed', 'Contemporary calligrapher and illustrator', '1991-06-19', 'Pakistani', '0344-1234510', 'sara.javed@email.com', '2023-10-20');

-- Insert CUSTOMER (10 records)
INSERT INTO CUSTOMER (FirstName, LastName, TotalPurchaseAmount, Phone, Email, RegistrationDate)
VALUES 
('Muhammad', 'Asif', 450000.00, '0300-2345601', 'muhammad.asif@email.com', '2023-01-15'),
('Hira', 'Saleem', 285000.00, '0321-2345602', 'hira.saleem@email.com', '2023-02-20'),
('Imran', 'Haider', 680000.00, '0333-2345603', 'imran.haider@email.com', '2023-03-10'),
('Sana', 'Tariq', 175000.00, '0301-2345604', 'sana.tariq@email.com', '2023-04-18'),
('Kamran', 'Bashir', 395000.00, '0345-2345605', 'kamran.bashir@email.com', '2023-05-22'),
('Nadia', 'Rehman', 520000.00, '0312-2345606', 'nadia.rehman@email.com', '2023-06-15'),
('Faisal', 'Mahmood', 125000.00, '0335-2345607', 'faisal.mahmood@email.com', '2023-07-08'),
('Rabia', 'Nawaz', 310000.00, '0303-2345608', 'rabia.nawaz@email.com', '2023-08-25'),
('Adeel', 'Chaudhry', 465000.00, '0322-2345609', 'adeel.chaudhry@email.com', '2023-09-12'),
('Amna', 'Riaz', 240000.00, '0344-2345610', 'amna.riaz@email.com', '2023-10-05');

-- Insert EMPLOYEE (10 records)
INSERT INTO EMPLOYEE (FirstName, LastName, Position, Phone, Email, HireDate, Salary, Department)
VALUES 
('Hassan', 'Mirza', 'Gallery Manager', '0300-3456701', 'hassan.mirza@gallery.com', '2020-01-15', 95000.00, 'Management'),
('Saima', 'Arif', 'Sales Associate', '0321-3456702', 'saima.arif@gallery.com', '2021-03-20', 55000.00, 'Sales'),
('Tariq', 'Hussain', 'Curator', '0333-3456703', 'tariq.hussain@gallery.com', '2019-06-10', 85000.00, 'Curatorial'),
('Zara', 'Noor', 'Customer Service Rep', '0301-3456704', 'zara.noor@gallery.com', '2022-02-14', 48000.00, 'Customer Service'),
('Waqas', 'Ahmed', 'Sales Associate', '0345-3456705', 'waqas.ahmed@gallery.com', '2021-08-22', 55000.00, 'Sales'),
('Mahira', 'Khan', 'Marketing Manager', '0312-3456706', 'mahira.khan@gallery.com', '2020-05-18', 78000.00, 'Marketing'),
('Shahid', 'Malik', 'Exhibition Coordinator', '0335-3456707', 'shahid.malik@gallery.com', '2021-11-30', 65000.00, 'Operations'),
('Aiza', 'Rauf', 'Sales Associate', '0303-3456708', 'aiza.rauf@gallery.com', '2022-07-12', 55000.00, 'Sales'),
('Farhan', 'Butt', 'Finance Officer', '0322-3456709', 'farhan.butt@gallery.com', '2020-09-15', 88000.00, 'Finance'),
('Hina', 'Baig', 'Customer Service Rep', '0344-3456710', 'hina.baig@gallery.com', '2023-01-20', 48000.00, 'Customer Service');

-- Insert EXHIBITION (10 records)
INSERT INTO EXHIBITION (ExhibitionName, Description, StartDate, EndDate, TicketPrice, MaxCapacity, Theme)
VALUES 
('Naqsh-e-Fikr', 'Contemporary Pakistani art celebrating national identity', '2024-01-15', '2024-03-15', 2000.00, 200, 'Contemporary'),
('Rang-e-Pakistan', 'Landscape paintings from northern areas', '2024-02-01', '2024-04-01', 1500.00, 150, 'Nature'),
('Digital Tehzeeb', 'Modern digital art exploring cultural fusion', '2024-03-10', '2024-05-10', 2500.00, 180, 'Digital Art'),
('Mitti ki Roshni', 'Sculptural works in clay and ceramic', '2024-04-05', '2024-06-05', 2000.00, 120, 'Sculpture'),
('Khat-o-Kitabat', 'Islamic calligraphy and typography exhibition', '2024-05-15', '2024-07-15', 2200.00, 220, 'Calligraphy'),
('Chehre Pakistan Kay', 'Portrait exhibition featuring Pakistani personalities', '2024-06-20', '2024-08-20', 1800.00, 160, 'Portrait'),
('Shehr-e-Lahore', 'Urban art celebrating Lahore culture', '2024-07-10', '2024-09-10', 2100.00, 190, 'Urban Art'),
('Mughal Virsa', 'Miniature paintings following Mughal tradition', '2024-08-15', '2024-10-15', 2300.00, 140, 'Miniature'),
('Rang aur Roshni', 'Mixed media exploring light and color', '2024-09-20', '2024-11-20', 2400.00, 170, 'Mixed Media'),
('Roshan Mustaqbil', 'Contemporary works envisioning Pakistan future', '2024-10-25', '2024-12-25', 2600.00, 200, 'Contemporary');

-- Insert ARTWORK (10 records)
INSERT INTO ARTWORK (ArtistID, Title, CreationYear, CurrentPrice, Medium, AcquisitionDate, CurrentStatus)
VALUES 
(1, 'Ayat-ul-Kursi', 2023, 180000.00, 'Calligraphy on Canvas', '2023-02-15', 'Available'),
(2, 'Mughal Garden', 2023, 320000.00, 'Miniature Painting', '2023-03-20', 'Sold'),
(3, 'Badshahi Mosque at Dawn', 2024, 125000.00, 'Oil on Canvas', '2024-01-10', 'Available'),
(4, 'Portrait of a Scholar', 2023, 215000.00, 'Oil on Canvas', '2023-05-12', 'Available'),
(5, 'Urban Dreams', 2024, 165000.00, 'Mixed Media', '2024-02-08', 'Reserved'),
(6, 'Phulkari Heritage', 2023, 275000.00, 'Textile Art', '2023-06-25', 'Available'),
(7, 'Abstract Lahore', 2024, 340000.00, 'Acrylic on Canvas', '2024-03-15', 'Available'),
(8, 'Kashmir Valley', 2023, 145000.00, 'Watercolor', '2023-07-18', 'Sold'),
(9, 'Clay Vessel Series', 2024, 425000.00, 'Ceramic Sculpture', '2024-04-20', 'Available'),
(10, 'Surah Rahman', 2023, 195000.00, 'Digital Calligraphy', '2023-08-30', 'Available');

-- Insert ORDERS (10 records)
INSERT INTO ORDERS (CustomerID, EmployeeID, OrderDate, PaymentMethod, PaymentStatus, TotalAmount, ContactEmail)
VALUES 
(1, 2, '2024-01-20', 'Bank Transfer', 'Completed', 180000.00, 'muhammad.asif@email.com'),
(2, 5, '2024-02-15', 'Bank Transfer', 'Completed', 320000.00, 'hira.saleem@email.com'),
(3, 2, '2024-03-10', 'Credit Card', 'Completed', 215000.00, 'imran.haider@email.com'),
(4, 8, '2024-04-05', 'Cash', 'Completed', 165000.00, 'sana.tariq@email.com'),
(5, 5, '2024-05-12', 'Bank Transfer', 'Pending', 275000.00, 'kamran.bashir@email.com'),
(6, 2, '2024-06-18', 'Bank Transfer', 'Completed', 340000.00, 'nadia.rehman@email.com'),
(7, 8, '2024-07-22', 'Credit Card', 'Completed', 125000.00, 'faisal.mahmood@email.com'),
(8, 5, '2024-08-15', 'Bank Transfer', 'Completed', 145000.00, 'rabia.nawaz@email.com'),
(9, 2, '2024-09-20', 'Bank Transfer', 'Pending', 425000.00, 'adeel.chaudhry@email.com'),
(10, 8, '2024-10-10', 'Credit Card', 'Completed', 195000.00, 'amna.riaz@email.com');

-- Insert ORDERLINE (10 records)
INSERT INTO ORDERLINE (OrderID, ArtWorkID, SalePrice, Commission, LineTotal)
VALUES 
(1, 1, 180000.00, 18000.00, 198000.00),
(2, 2, 320000.00, 32000.00, 352000.00),
(3, 4, 215000.00, 21500.00, 236500.00),
(4, 5, 165000.00, 16500.00, 181500.00),
(5, 6, 275000.00, 27500.00, 302500.00),
(6, 7, 340000.00, 34000.00, 374000.00),
(7, 3, 125000.00, 12500.00, 137500.00),
(8, 8, 145000.00, 14500.00, 159500.00),
(9, 9, 425000.00, 42500.00, 467500.00),
(10, 10, 195000.00, 19500.00, 214500.00);

-- Insert TICKET (10 records)
INSERT INTO TICKET (ExhibitionID, CustomerID, VisitDate, PaymentStatus, TicketType, TicketPrice, PurchaseDate)
VALUES 
(1, 1, '2024-02-10', 'Paid', 'General', 2000.00, '2024-01-20'),
(2, 2, '2024-02-20', 'Paid', 'VIP', 1500.00, '2024-02-01'),
(3, 3, '2024-04-15', 'Paid', 'General', 2500.00, '2024-03-15'),
(4, 4, '2024-05-10', 'Paid', 'Student', 2000.00, '2024-04-20'),
(5, 5, '2024-06-20', 'Paid', 'General', 2200.00, '2024-05-25'),
(6, 6, '2024-07-15', 'Paid', 'VIP', 1800.00, '2024-06-30'),
(7, 7, '2024-08-05', 'Paid', 'General', 2100.00, '2024-07-15'),
(8, 8, '2024-09-10', 'Paid', 'Student', 2300.00, '2024-08-20'),
(9, 9, '2024-10-15', 'Paid', 'General', 2400.00, '2024-09-25'),
(10, 10, '2024-11-20', 'Paid', 'Family', 2600.00, '2024-10-30');

-- Insert ARTIST_ARTSTYLE (10 records)
INSERT INTO ARTIST_ARTSTYLE (ArtistID, ArtStyle)
VALUES 
(1, 'Calligraphy'),
(1, 'Islamic Art'),
(2, 'Miniature'),
(3, 'Landscape'),
(4, 'Portrait'),
(5, 'Mixed Media'),
(6, 'Textile Art'),
(7, 'Abstract'),
(8, 'Watercolor'),
(9, 'Sculpture');

-- Insert ARTIST_ADDRESS (10 records)
INSERT INTO ARTIST_ADDRESS (ArtistID, Street, City, State, ZipCode, Country)
VALUES 
(1, 'House 45, Street 7, F-10/3', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(2, 'Plot 123, DHA Phase 5', 'Lahore', 'Punjab', '54000', 'Pakistan'),
(3, 'Flat 6, Block A, Gulistan-e-Jauhar', 'Karachi', 'Sindh', '75290', 'Pakistan'),
(4, 'House 78, Cavalry Ground', 'Lahore', 'Punjab', '54810', 'Pakistan'),
(5, 'Street 12, Sector F-11', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(6, 'House 34, Gulberg III', 'Lahore', 'Punjab', '54660', 'Pakistan'),
(7, 'Flat 9, Clifton Block 5', 'Karachi', 'Sindh', '75600', 'Pakistan'),
(8, 'House 56, Model Town', 'Lahore', 'Punjab', '54700', 'Pakistan'),
(9, 'Plot 89, DHA Phase 6', 'Karachi', 'Sindh', '75500', 'Pakistan'),
(10, 'House 23, G-9/4', 'Islamabad', 'ICT', '44000', 'Pakistan');

-- Insert Customer_Preference (10 records)
INSERT INTO Customer_Preference (CustomerID, PreferredArtStyles)
VALUES 
(1, 'Calligraphy, Islamic Art'),
(2, 'Miniature, Traditional'),
(3, 'Landscape, Contemporary'),
(4, 'Portrait, Realistic'),
(5, 'Mixed Media, Abstract'),
(6, 'Textile, Traditional'),
(7, 'Abstract, Modern'),
(8, 'Watercolor, Nature'),
(9, 'Sculpture, Contemporary'),
(10, 'Calligraphy, Digital Art');

-- Insert CUSTOMER_Location (10 records)
INSERT INTO CUSTOMER_Location (CustomerID, Street, City, State, ZipCode, Country)
VALUES 
(1, 'House 12, Street 5, DHA Phase 4', 'Rawalpindi', 'Punjab', '46000', 'Pakistan'),
(2, 'Flat 3B, Bahria Town Phase 7', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(3, 'Plot 67, DHA Phase 8', 'Lahore', 'Punjab', '54792', 'Pakistan'),
(4, 'House 89, Johar Town', 'Lahore', 'Punjab', '54782', 'Pakistan'),
(5, 'Street 10, Sector E-11', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(6, 'Flat 12, Defence View', 'Karachi', 'Sindh', '75500', 'Pakistan'),
(7, 'House 45, Satellite Town', 'Rawalpindi', 'Punjab', '46300', 'Pakistan'),
(8, 'Plot 23, Bahria Town', 'Lahore', 'Punjab', '53720', 'Pakistan'),
(9, 'House 78, F-7/2', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(10, 'Flat 5, Gulshan-e-Iqbal', 'Karachi', 'Sindh', '75300', 'Pakistan');

-- Insert EXHIBITION_LOCATION (10 records)
INSERT INTO EXHIBITION_LOCATION (ExhibitionID, Hall, Floor, Building)
VALUES 
(1, 'Jinnah Hall', 'Ground Floor', 'Main Building'),
(2, 'Iqbal Hall', '1st Floor', 'Main Building'),
(3, 'Faiz Hall', 'Ground Floor', 'West Wing'),
(4, 'Ghalib Hall', '2nd Floor', 'Main Building'),
(5, 'Rumi Hall', '1st Floor', 'East Wing'),
(6, 'Meer Hall', 'Ground Floor', 'Main Building'),
(7, 'Sirshar Hall', '1st Floor', 'West Wing'),
(8, 'Saadat Hall', '2nd Floor', 'East Wing'),
(9, 'Zauq Hall', 'Ground Floor', 'North Building'),
(10, 'Momin Hall', '1st Floor', 'South Building');

-- Insert ARTWORK_RANGE (10 records)
INSERT INTO ARTWORK_RANGE (ArtworkID, PriceHistory)
VALUES 
(1, '2023-02-15: Rs.165000; 2023-08-20: Rs.180000;'),
(2, '2023-03-20: Rs.295000; 2023-09-15: Rs.320000;'),
(3, '2024-01-10: Rs.125000;'),
(4, '2023-05-12: Rs.195000; 2023-11-10: Rs.215000;'),
(5, '2024-02-08: Rs.155000; 2024-06-15: Rs.165000;'),
(6, '2023-06-25: Rs.250000; 2023-12-20: Rs.275000;'),
(7, '2024-03-15: Rs.340000;'),
(8, '2023-07-18: Rs.135000; 2023-10-12: Rs.145000;'),
(9, '2024-04-20: Rs.400000; 2024-08-15: Rs.425000;'),
(10, '2023-08-30: Rs.180000; 2024-02-10: Rs.195000;');

-- Insert ARTWORK_DIMENSIONS (10 records)
INSERT INTO ARTWORK_DIMENSIONS (ArtworkID, Height, Width, Depth)
VALUES 
(1, 91.44, 60.96, 3.00),
(2, 30.48, 40.64, 0.50),
(3, 121.92, 91.44, 2.50),
(4, 106.68, 76.20, 2.00),
(5, 91.44, 91.44, 10.00),
(6, 152.40, 121.92, 5.00),
(7, 182.88, 121.92, 3.50),
(8, 45.72, 60.96, 0.20),
(9, 60.96, 45.72, 45.72),
(10, 76.20, 101.60, 0.10);

-- Insert ORDER_SHIPMENT (10 records)
INSERT INTO ORDER_SHIPMENT (OrderID, Street, City, State, ZipCode, Country)
VALUES 
(1, 'House 12, Street 5, DHA Phase 4', 'Rawalpindi', 'Punjab', '46000', 'Pakistan'),
(2, 'Flat 3B, Bahria Town Phase 7', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(3, 'Plot 67, DHA Phase 8', 'Lahore', 'Punjab', '54792', 'Pakistan'),
(4, 'House 89, Johar Town', 'Lahore', 'Punjab', '54782', 'Pakistan'),
(5, 'Street 10, Sector E-11', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(6, 'Flat 12, Defence View', 'Karachi', 'Sindh', '75500', 'Pakistan'),
(7, 'House 45, Satellite Town', 'Rawalpindi', 'Punjab', '46300', 'Pakistan'),
(8, 'Plot 23, Bahria Town', 'Lahore', 'Punjab', '53720', 'Pakistan'),
(9, 'House 78, F-7/2', 'Islamabad', 'ICT', '44000', 'Pakistan'),
(10, 'Flat 5, Gulshan-e-Iqbal', 'Karachi', 'Sindh', '75300', 'Pakistan');

-- Display confirmation message
PRINT 'Database populated successfully with 10 records per table!';
PRINT 'All data reflects Pakistani cultural context and society';
PRINT 'Total records inserted: 170';
GO

