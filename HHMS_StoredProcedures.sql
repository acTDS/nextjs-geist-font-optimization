-- Stored Procedures for HHMS_Ngoaingu68 Database
-- Includes authentication, CRUD operations, and dashboard data retrieval

USE HHMS_Ngoaingu68;
GO

-- Stored Procedure: sp_Login
CREATE PROCEDURE sp_Login
    @Username NVARCHAR(100),
    @PasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            a.AccountID,
            a.StaffID,
            a.Username,
            a.Email,
            a.DisplayName,
            a.StatusID,
            s.FullName,
            s.BranchID,
            s.DepartmentID
        FROM Account a
        INNER JOIN Staff s ON a.StaffID = s.StaffID
        WHERE a.Username = @Username AND a.PasswordHash = @PasswordHash AND a.StatusID = 1; -- Active status
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_ChangePassword
CREATE PROCEDURE sp_ChangePassword
    @AccountID INT,
    @OldPasswordHash NVARCHAR(255),
    @NewPasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Account WHERE AccountID = @AccountID AND PasswordHash = @OldPasswordHash)
        BEGIN
            UPDATE Account
            SET PasswordHash = @NewPasswordHash,
                FirstLoginChangePwd = 0,
                UpdatedAt = GETDATE()
            WHERE AccountID = @AccountID;
            SELECT 1 AS Success;
        END
        ELSE
        BEGIN
            SELECT 0 AS Success, 'Old password does not match.' AS ErrorMessage;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_GetDashboardData
CREATE PROCEDURE sp_GetDashboardData
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            (SELECT COUNT(*) FROM Student WHERE StatusID = 1) AS TotalActiveStudents,
            (SELECT COUNT(*) FROM Class WHERE StatusID = 1) AS TotalActiveClasses,
            (SELECT COUNT(*) FROM Staff WHERE StatusID = 1) AS TotalActiveStaff
        -- Add more dashboard metrics as needed
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_GetBranchList
CREATE PROCEDURE sp_GetBranchList
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            BranchID,
            BranchCode,
            BranchName,
            BranchAddress,
            BranchLicense,
            BranchDirector,
            BranchTotalStaff,
            BranchTotalStudent,
            BranchTotalActiveClass,
            StatusID
        FROM Branch
        WHERE StatusID = 1; -- Active branches
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_InsertBranch
CREATE PROCEDURE sp_InsertBranch
    @BranchCode NVARCHAR(20),
    @BranchName NVARCHAR(255),
    @BranchAddress NVARCHAR(255),
    @BranchLicense NVARCHAR(255),
    @BranchDirector NVARCHAR(255),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Branch (BranchCode, BranchName, BranchAddress, BranchLicense, BranchDirector, StatusID, LastModified)
        VALUES (@BranchCode, @BranchName, @BranchAddress, @BranchLicense, @BranchDirector, @StatusID, GETDATE());
        SELECT SCOPE_IDENTITY() AS NewBranchID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_UpdateBranch
CREATE PROCEDURE sp_UpdateBranch
    @BranchID INT,
    @BranchName NVARCHAR(255),
    @BranchAddress NVARCHAR(255),
    @BranchLicense NVARCHAR(255),
    @BranchDirector NVARCHAR(255),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Branch
        SET BranchName = @BranchName,
            BranchAddress = @BranchAddress,
            BranchLicense = @BranchLicense,
            BranchDirector = @BranchDirector,
            StatusID = @StatusID,
            LastModified = GETDATE()
        WHERE BranchID = @BranchID;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_GetStudentList
CREATE PROCEDURE sp_GetStudentList
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            StudentID,
            StudentCode,
            FullName,
            Gender,
            IDNumber,
            BirthDate,
            StudentAddress,
            Phone,
            Email,
            BranchID,
            MajorID,
            ConsultantStaffID,
            EntryLevel,
            ExitLevel,
            StatusID
        FROM Student
        WHERE StatusID = 1; -- Active students
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_InsertStudent
CREATE PROCEDURE sp_InsertStudent
    @StudentCode NVARCHAR(20),
    @FullName NVARCHAR(255),
    @Gender NVARCHAR(10),
    @IDNumber NVARCHAR(50),
    @BirthDate DATE,
    @StudentAddress NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(255),
    @BranchID INT,
    @MajorID INT,
    @ConsultantStaffID INT,
    @EntryLevel NVARCHAR(20),
    @ExitLevel NVARCHAR(20),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Student (StudentCode, FullName, Gender, IDNumber, BirthDate, StudentAddress, Phone, Email, BranchID, MajorID, ConsultantStaffID, EntryLevel, ExitLevel, StatusID)
        VALUES (@StudentCode, @FullName, @Gender, @IDNumber, @BirthDate, @StudentAddress, @Phone, @Email, @BranchID, @MajorID, @ConsultantStaffID, @EntryLevel, @ExitLevel, @StatusID);
        SELECT SCOPE_IDENTITY() AS NewStudentID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_UpdateStudent
CREATE PROCEDURE sp_UpdateStudent
    @StudentID INT,
    @FullName NVARCHAR(255),
    @Gender NVARCHAR(10),
    @IDNumber NVARCHAR(50),
    @BirthDate DATE,
    @StudentAddress NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(255),
    @BranchID INT,
    @MajorID INT,
    @ConsultantStaffID INT,
    @EntryLevel NVARCHAR(20),
    @ExitLevel NVARCHAR(20),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Student
        SET FullName = @FullName,
            Gender = @Gender,
            IDNumber = @IDNumber,
            BirthDate = @BirthDate,
            StudentAddress = @StudentAddress,
            Phone = @Phone,
            Email = @Email,
            BranchID = @BranchID,
            MajorID = @MajorID,
            ConsultantStaffID = @ConsultantStaffID,
            EntryLevel = @EntryLevel,
            ExitLevel = @ExitLevel,
            StatusID = @StatusID
        WHERE StudentID = @StudentID;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_GetClassList
CREATE PROCEDURE sp_GetClassList
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            ClassID,
            ClassCode,
            ClassName,
            MajorID,
            BranchID,
            MainTeacherID,
            AssistantID,
            Room,
            StartDate,
            ExpectedEndDate,
            TrainingProgress,
            StatusID
        FROM Class
        WHERE StatusID = 1; -- Active classes
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_InsertClass
CREATE PROCEDURE sp_InsertClass
    @ClassCode NVARCHAR(30),
    @ClassName NVARCHAR(255),
    @MajorID INT,
    @BranchID INT,
    @MainTeacherID INT,
    @AssistantID INT,
    @Room NVARCHAR(50),
    @StartDate DATE,
    @ExpectedEndDate DATE,
    @TrainingProgress NVARCHAR(255),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Class (ClassCode, ClassName, MajorID, BranchID, MainTeacherID, AssistantID, Room, StartDate, ExpectedEndDate, TrainingProgress, StatusID)
        VALUES (@ClassCode, @ClassName, @MajorID, @BranchID, @MainTeacherID, @AssistantID, @Room, @StartDate, @ExpectedEndDate, @TrainingProgress, @StatusID);
        SELECT SCOPE_IDENTITY() AS NewClassID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Stored Procedure: sp_UpdateClass
CREATE PROCEDURE sp_UpdateClass
    @ClassID INT,
    @ClassName NVARCHAR(255),
    @MajorID INT,
    @BranchID INT,
    @MainTeacherID INT,
    @AssistantID INT,
    @Room NVARCHAR(50),
    @StartDate DATE,
    @ExpectedEndDate DATE,
    @TrainingProgress NVARCHAR(255),
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE Class
        SET ClassName = @ClassName,
            MajorID = @MajorID,
            BranchID = @BranchID,
            MainTeacherID = @MainTeacherID,
            AssistantID = @AssistantID,
            Room = @Room,
            StartDate = @StartDate,
            ExpectedEndDate = @ExpectedEndDate,
            TrainingProgress = @TrainingProgress,
            StatusID = @StatusID
        WHERE ClassID = @ClassID;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Additional stored procedures for other entities (Staff, Department, Financial, Document, etc.) can be added similarly.
