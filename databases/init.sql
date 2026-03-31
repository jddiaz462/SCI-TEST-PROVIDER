/* ===========================================================
   SCI Test - Database Init Script
   Creates DB (optional), table Providers and CRUD Stored Procedures
   =========================================================== */

-- OPTIONAL: Create DB if it doesn't exist
IF DB_ID('SCICustomers') IS NULL
BEGIN
    CREATE DATABASE SCICustomers;
END
GO

USE SCICustomers;
GO

-- Recommended settings
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ==========================
   TABLE: Providers
   ========================== */
IF OBJECT_ID('dbo.Providers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Providers (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Providers PRIMARY KEY,
        FirstName   NVARCHAR(100) NOT NULL,
        LastName    NVARCHAR(100) NOT NULL,
        Email       NVARCHAR(150) NOT NULL,
        Phone       NVARCHAR(20)  NULL,
        Address     NVARCHAR(250) NULL,
        IsActive    BIT NOT NULL CONSTRAINT DF_Providers_IsActive DEFAULT (1),
        CreatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_Providers_CreatedDate DEFAULT (SYSUTCDATETIME()),
        UpdatedDate DATETIME2(0) NOT NULL CONSTRAINT DF_Providers_UpdatedDate DEFAULT (SYSUTCDATETIME())
    );

    -- Unique index for Email (prevents duplicates)
    CREATE UNIQUE INDEX UX_Providers_Email ON dbo.Providers(Email);
END
GO

/* ==========================
   SP: Create
   ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Providers_Create
(
    @FirstName NVARCHAR(100),
    @LastName  NVARCHAR(100),
    @Email     NVARCHAR(150),
    @Phone     NVARCHAR(20)  = NULL,
    @Address   NVARCHAR(250) = NULL,
    @IsActive  BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Providers (FirstName, LastName, Email, Phone, Address, IsActive, CreatedDate, UpdatedDate)
        VALUES (@FirstName, @LastName, @Email, @Phone, @Address, @IsActive, SYSUTCDATETIME(), SYSUTCDATETIME());

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
    END TRY
    BEGIN CATCH
        -- Handle duplicate email (unique index)
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            THROW 50001, 'Ya existe un Provider con ese Email.', 1;
        END

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrMsg, 1;
    END CATCH
END
GO

/* ==========================
   SP: Update
   ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Providers_Update
(
    @Id        INT,
    @FirstName NVARCHAR(100),
    @LastName  NVARCHAR(100),
    @Email     NVARCHAR(150),
    @Phone     NVARCHAR(20)  = NULL,
    @Address   NVARCHAR(250) = NULL,
    @IsActive  BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Providers WHERE Id = @Id)
            THROW 50002, 'Provider no existe.', 1;

        UPDATE dbo.Providers
        SET
            FirstName   = @FirstName,
            LastName    = @LastName,
            Email       = @Email,
            Phone       = @Phone,
            Address     = @Address,
            IsActive    = @IsActive,
            UpdatedDate = SYSUTCDATETIME()
        WHERE Id = @Id;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            THROW 50003, 'El Email ya está en uso por otro Provider.', 1;
        END

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrMsg, 1;
    END CATCH
END
GO

/* ==========================
   SP: Soft Delete
   ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Providers_Delete
(
    @Id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Providers WHERE Id = @Id AND IsActive = 1)
            THROW 50004, 'Provider no existe o ya está inactivo.', 1;

        UPDATE dbo.Providers
        SET IsActive = 0,
            UpdatedDate = SYSUTCDATETIME()
        WHERE Id = @Id;

        SELECT @@ROWCOUNT AS RowsAffected;
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrMsg, 1;
    END CATCH
END
GO

/* ==========================
   SP: Get By Id
   ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Providers_GetById
(
    @Id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        FirstName,
        LastName,
        Email,
        Phone,
        Address,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM dbo.Providers
    WHERE Id = @Id AND IsActive = 1;
END
GO

/* ==========================
   SP: Get All (pagination)
   ========================== */
CREATE OR ALTER PROCEDURE dbo.sp_Providers_GetAll
(
    @PageNumber INT = 1,
    @PageSize   INT = 50
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize   < 1 SET @PageSize   = 50;

    SELECT
        Id,
        FirstName,
        LastName,
        Email,
        Phone,
        Address,
        IsActive,
        CreatedDate,
        UpdatedDate
    FROM dbo.Providers
    WHERE IsActive = 1
    ORDER BY Id DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO
