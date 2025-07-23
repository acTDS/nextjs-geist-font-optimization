-- Stored Procedures and Triggers for HHMS_Ngoaingu68

-- Stored Procedure: User Login Authentication
CREATE OR ALTER PROCEDURE SP_UserLogin
    @Username NVARCHAR(100),
    @Password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PasswordHash VARBINARY(64);
    SET @PasswordHash = HASHBYTES('SHA2_256', @Password);

    SELECT 
        A.AccountID,
        A.StaffID,
        A.Username,
        A.Email,
        A.DisplayName,
        A.StatusID,
        S.FullName AS StaffFullName,
        GS.StatusName AS AccountStatus
    FROM Account A
    JOIN Staff S ON A.StaffID = S.StaffID
    JOIN GeneralStatus GS ON A.StatusID = GS.StatusID
    WHERE A.Username = @Username AND A.PasswordHash = @PasswordHash AND A.StatusID = (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Account');

END;
GO

-- Stored Procedure: Get Student List with Search
CREATE OR ALTER PROCEDURE SP_GetStudents
    @SearchTerm NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        S.StudentID,
        S.StudentCode,
        S.FullName,
        S.Gender,
        S.IDNumber,
        S.BirthDate,
        S.StudentAddress,
        S.Phone,
        S.Email,
        B.BranchName,
        M.MajorName,
        ST.FullName AS ConsultantName,
        S.EntryLevel,
        GS.StatusName AS Status
    FROM Student S
    LEFT JOIN Branch B ON S.BranchID = B.BranchID
    LEFT JOIN Major M ON S.MajorID = M.MajorID
    LEFT JOIN Staff ST ON S.ConsultantStaffID = ST.StaffID
    LEFT JOIN GeneralStatus GS ON S.StatusID = GS.StatusID
    WHERE (@SearchTerm IS NULL OR S.FullName LIKE '%' + @SearchTerm + '%' OR S.Phone LIKE '%' + @SearchTerm + '%' OR S.Email LIKE '%' + @SearchTerm + '%')
    ORDER BY S.FullName;
END;
GO

-- Stored Procedure: Add or Update Student
CREATE OR ALTER PROCEDURE SP_AddOrUpdateStudent
    @StudentID INT = NULL,
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

    IF @StudentID IS NULL
    BEGIN
        INSERT INTO Student (FullName, Gender, IDNumber, BirthDate, StudentAddress, Phone, Email, BranchID, MajorID, ConsultantStaffID, EntryLevel, ExitLevel, StatusID)
        VALUES (@FullName, @Gender, @IDNumber, @BirthDate, @StudentAddress, @Phone, @Email, @BranchID, @MajorID, @ConsultantStaffID, @EntryLevel, @ExitLevel, @StatusID);
        SELECT SCOPE_IDENTITY() AS NewStudentID;
    END
    ELSE
    BEGIN
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
    END
END;
GO

-- Stored Procedure: Get Staff List with Search
CREATE OR ALTER PROCEDURE SP_GetStaff
    @SearchTerm NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ST.StaffID,
        ST.StaffCode,
        ST.FullName,
        ST.Gender,
        ST.IDNumber,
        ST.BirthDate,
        ST.StaffAddress,
        ST.Phone,
        ST.Email,
        B.BranchName,
        D.DepartmentName,
        ST.Position,
        GS.StatusName AS Status
    FROM Staff ST
    LEFT JOIN Branch B ON ST.BranchID = B.BranchID
    LEFT JOIN Department D ON ST.DepartmentID = D.DepartmentID
    LEFT JOIN GeneralStatus GS ON ST.StatusID = GS.StatusID
    WHERE (@SearchTerm IS NULL OR ST.FullName LIKE '%' + @SearchTerm + '%' OR ST.Phone LIKE '%' + @SearchTerm + '%' OR ST.Email LIKE '%' + @SearchTerm + '%')
    ORDER BY ST.FullName;
END;
GO

-- Stored Procedure: Add or Update Staff
CREATE OR ALTER PROCEDURE SP_AddOrUpdateStaff
    @StaffID INT = NULL,
    @FullName NVARCHAR(255),
    @Gender NVARCHAR(10),
    @IDNumber NVARCHAR(50),
    @BirthDate DATE,
    @StaffAddress NVARCHAR(255),
    @Phone NVARCHAR(20),
    @Email NVARCHAR(255),
    @BranchID INT,
    @DepartmentID INT,
    @Position NVARCHAR(100),
    @ContractType NVARCHAR(50),
    @DateJoined DATE,
    @StatusID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @StaffID IS NULL
    BEGIN
        INSERT INTO Staff (FullName, Gender, IDNumber, BirthDate, StaffAddress, Phone, Email, BranchID, DepartmentID, Position, ContractType, DateJoined, StatusID)
        VALUES (@FullName, @Gender, @IDNumber, @BirthDate, @StaffAddress, @Phone, @Email, @BranchID, @DepartmentID, @Position, @ContractType, @DateJoined, @StatusID);
        SELECT SCOPE_IDENTITY() AS NewStaffID;
    END
    ELSE
    BEGIN
        UPDATE Staff
        SET FullName = @FullName,
            Gender = @Gender,
            IDNumber = @IDNumber,
            BirthDate = @BirthDate,
            StaffAddress = @StaffAddress,
            Phone = @Phone,
            Email = @Email,
            BranchID = @BranchID,
            DepartmentID = @DepartmentID,
            Position = @Position,
            ContractType = @ContractType,
            DateJoined = @DateJoined,
            StatusID = @StatusID
        WHERE StaffID = @StaffID;
    END
END;
GO

-- Stored Procedure: Get Class List with Search
CREATE OR ALTER PROCEDURE SP_GetClasses
    @SearchTerm NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        C.ClassID,
        C.ClassCode,
        C.ClassName,
        B.BranchName,
        M.MajorName,
        ST.FullName AS MainTeacherName,
        A.FullName AS AssistantName,
        C.Room,
        C.StartDate,
        C.ExpectedEndDate,
        GS.StatusName AS Status
    FROM Class C
    LEFT JOIN Branch B ON C.BranchID = B.BranchID
    LEFT JOIN Major M ON C.MajorID = M.MajorID
    LEFT JOIN Staff ST ON C.MainTeacherID = ST.StaffID
    LEFT JOIN Staff A ON C.AssistantID = A.StaffID
    LEFT JOIN GeneralStatus GS ON C.StatusID = GS.StatusID
    WHERE (@SearchTerm IS NULL OR C.ClassName LIKE '%' + @SearchTerm + '%' OR B.BranchName LIKE '%' + @SearchTerm + '%' OR M.MajorName LIKE '%' + @SearchTerm + '%')
    ORDER BY C.ClassName;
END;
GO

-- Stored Procedure: Add or Update Class
CREATE OR ALTER PROCEDURE SP_AddOrUpdateClass
    @ClassID INT = NULL,
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

    IF @ClassID IS NULL
    BEGIN
        INSERT INTO Class (ClassName, MajorID, BranchID, MainTeacherID, AssistantID, Room, StartDate, ExpectedEndDate, TrainingProgress, StatusID)
        VALUES (@ClassName, @MajorID, @BranchID, @MainTeacherID, @AssistantID, @Room, @StartDate, @ExpectedEndDate, @TrainingProgress, @StatusID);
        SELECT SCOPE_IDENTITY() AS NewClassID;
    END
    ELSE
    BEGIN
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
    END
END;
GO

-- Triggers for auto-generating codes and logging changes

-- Trigger: Auto-generate StaffCode and DisplayName on Staff insert
CREATE OR ALTER TRIGGER trg_Staff_AutoCode
ON Staff
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S
    SET
        StaffCode = dbo.GenerateStaffCode(),
        DisplayName = dbo.GenerateStaffDisplayName(i.FullName, i.BranchID, i.DepartmentID)
    FROM Staff S
    INNER JOIN inserted i ON S.StaffID = i.StaffID;
END;
GO

-- Trigger: Auto-generate StudentCode on Student insert
CREATE OR ALTER TRIGGER trg_Student_AutoCode
ON Student
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S
    SET StudentCode = dbo.GenerateStudentCode(i.MajorID)
    FROM Student S
    INNER JOIN inserted i ON S.StudentID = i.StudentID;
END;
GO

-- Trigger: Auto-generate ClassCode on Class insert
CREATE OR ALTER TRIGGER trg_Class_AutoCode
ON Class
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE C
    SET ClassCode = dbo.GenerateClassCode(i.BranchID, i.MajorID)
    FROM Class C
    INNER JOIN inserted i ON C.ClassID = i.ClassID;
END;
GO

-- Trigger: Log changes on Staff table
CREATE OR ALTER TRIGGER trg_Staff_LogChanges
ON Staff
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'INSERT', GETDATE() FROM inserted;
    END
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'UPDATE', GETDATE() FROM inserted;
    END
    ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'DELETE', GETDATE() FROM deleted;
    END
END;
GO

-- Additional triggers and stored procedures can be added as needed to fully support the UI functionalities.

-- This completes the core functions for the database schema aligned with the UI.
