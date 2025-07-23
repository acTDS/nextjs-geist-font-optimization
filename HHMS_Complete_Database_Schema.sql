-- Complete SQL Server Database Schema for Multi-branch Foreign Language Center Management System
-- This schema is designed to support the foreign language center management system
-- It includes tables, relationships, indexes, and key stored procedures
-- Created based on analysis of UI files and existing schema

-- Create Database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'HHMS_Ngoaingu68')
BEGIN
    CREATE DATABASE HHMS_Ngoaingu68;
END
GO

USE HHMS_Ngoaingu68;
GO

-- Table: GeneralStatus
CREATE TABLE GeneralStatus (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName NVARCHAR(100) NOT NULL,
    StatusType NVARCHAR(50),
    DisplayOrder INT,
    IsActive BIT DEFAULT 1
);
GO

-- Table: Branch
CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) PRIMARY KEY,
    BranchCode NVARCHAR(20) UNIQUE NOT NULL,
    BranchName NVARCHAR(255) NOT NULL,
    BranchAddress NVARCHAR(255),
    BranchLicense NVARCHAR(255),
    BranchDirector NVARCHAR(255),
    BranchTotalStaff INT DEFAULT 0,
    BranchTotalStudent INT DEFAULT 0,
    BranchTotalActiveClass INT DEFAULT 0,
    StatusID INT,
    LastModified DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Branch_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Department
CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentCode NVARCHAR(20) UNIQUE NOT NULL,
    DepartmentName NVARCHAR(255) NOT NULL,
    ManagerStaffName NVARCHAR(255),
    StaffQuota INT,
    StatusID INT,
    CONSTRAINT FK_Department_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Major
CREATE TABLE Major (
    MajorID INT IDENTITY(1,1) PRIMARY KEY,
    MajorCode NVARCHAR(20) UNIQUE NOT NULL,
    MajorName NVARCHAR(255) NOT NULL,
    MajorDescription NVARCHAR(255),
    InputRequirement NVARCHAR(255),
    OutputRequirement NVARCHAR(255),
    TotalSessions INT,
    BaseTuitionFee DECIMAL(19,2),
    StatusID INT,
    CONSTRAINT FK_Major_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Staff
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    StaffCode NVARCHAR(20) UNIQUE,
    FullName NVARCHAR(255) NOT NULL,
    Gender NVARCHAR(10),
    IDNumber NVARCHAR(50),
    BirthDate DATE,
    StaffAddress NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(255),
    SocialInsurance NVARCHAR(50),
    ContractType NVARCHAR(50),
    ContractID INT,
    DateJoined DATE,
    TaxCode NVARCHAR(50),
    BankBranch NVARCHAR(255),
    BankAccount NVARCHAR(100),
    BranchID INT,
    DepartmentID INT,
    DisplayName NVARCHAR(300),
    BaseSalary DECIMAL(19,2) DEFAULT 0,
    FixedDeductions DECIMAL(19,2) DEFAULT 0,
    StatusID INT,
    CONSTRAINT FK_Staff_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Staff_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Account
CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT UNIQUE,
    Username NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) UNIQUE,
    DisplayName NVARCHAR(100),
    StatusID INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME,
    FirstLoginChangePwd BIT DEFAULT 1,
    LastLogin DATETIME,
    WrongLoginCount INT DEFAULT 0,
    CONSTRAINT FK_Account_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Account_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Role
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255)
);
GO

-- Table: Permission
CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(100) NOT NULL,
    PermissionType NVARCHAR(50)
);
GO

-- Table: Role_Permission
CREATE TABLE Role_Permission (
    RoleID INT,
    PermissionID INT,
    PermissionValue NVARCHAR(50),
    PRIMARY KEY (RoleID, PermissionID),
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (PermissionID) REFERENCES Permission(PermissionID)
);
GO

-- Table: Staff_Role
CREATE TABLE Staff_Role (
    StaffID INT,
    RoleID INT,
    PRIMARY KEY (StaffID, RoleID),
    CONSTRAINT FK_StaffRole_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_StaffRole_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);
GO

-- Table: Student
CREATE TABLE Student (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentCode NVARCHAR(20) UNIQUE,
    FullName NVARCHAR(255) NOT NULL,
    Gender NVARCHAR(10),
    IDNumber NVARCHAR(50),
    BirthDate DATE,
    StudentAddress NVARCHAR(255),
    Phone NVARCHAR(20),
    Email NVARCHAR(255),
    BranchID INT,
    MajorID INT,
    ConsultantStaffID INT,
    EntryLevel NVARCHAR(20),
    ExitLevel NVARCHAR(20),
    StatusID INT,
    CONSTRAINT FK_Student_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Student_Major FOREIGN KEY (MajorID) REFERENCES Major(MajorID),
    CONSTRAINT FK_Student_Staff FOREIGN KEY (ConsultantStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Student_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Class
CREATE TABLE Class (
    ClassID INT IDENTITY(1,1) PRIMARY KEY,
    ClassCode NVARCHAR(30) UNIQUE,
    ClassName NVARCHAR(255) NOT NULL,
    MajorID INT,
    BranchID INT,
    MainTeacherID INT,
    AssistantID INT,
    Room NVARCHAR(50),
    StartDate DATE,
    ExpectedEndDate DATE,
    TrainingProgress NVARCHAR(255),
    StatusID INT,
    CONSTRAINT FK_Class_Major FOREIGN KEY (MajorID) REFERENCES Major(MajorID),
    CONSTRAINT FK_Class_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Class_MainTeacher FOREIGN KEY (MainTeacherID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Class_Assistant FOREIGN KEY (AssistantID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Class_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: ClassSchedule
CREATE TABLE ClassSchedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    ClassID INT,
    StudyDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Room NVARCHAR(50),
    CONSTRAINT FK_ClassSchedule_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
);
GO

-- Table: Registration
CREATE TABLE Registration (
    RegistrationID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT,
    ClassID INT,
    RegistrationDate DATE DEFAULT GETDATE(),
    StatusID INT,
    Note NVARCHAR(255),
    CONSTRAINT FK_Registration_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Registration_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT FK_Registration_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Attendance
CREATE TABLE Attendance (
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY,
    ScheduleID INT,
    StudentID INT,
    AttendanceStatus NVARCHAR(20),
    Note NVARCHAR(255),
    CONSTRAINT FK_Attendance_Schedule FOREIGN KEY (ScheduleID) REFERENCES ClassSchedule(ScheduleID),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);
GO

-- Table: StudentGrade
CREATE TABLE StudentGrade (
    GradeID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT,
    ClassID INT,
    TestName NVARCHAR(255),
    Score DECIMAL(5,2),
    GradingDate DATE DEFAULT GETDATE(),
    Note NVARCHAR(255),
    CONSTRAINT FK_StudentGrade_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_StudentGrade_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
);
GO

-- Table: DocumentType
CREATE TABLE DocumentType (
    DocumentTypeID INT IDENTITY(1,1) PRIMARY KEY,
    DocumentTypeName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255)
);
GO

-- Table: Document
CREATE TABLE Document (
    DocumentID INT IDENTITY(1,1) PRIMARY KEY,
    DocumentName NVARCHAR(255) NOT NULL,
    DepartmentID INT,
    DocumentTypeID INT,
    PhysicalLocation NVARCHAR(255),
    FilePath NVARCHAR(255),
    Description NVARCHAR(255),
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatorStaffID INT,
    LastModifiedDate DATETIME,
    LastModifierStaffID INT,
    StatusID INT,
    CONSTRAINT FK_Document_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Document_DocumentType FOREIGN KEY (DocumentTypeID) REFERENCES DocumentType(DocumentTypeID),
    CONSTRAINT FK_Document_Creator FOREIGN KEY (CreatorStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Document_Modifier FOREIGN KEY (LastModifierStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Document_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: DocumentVersion
CREATE TABLE DocumentVersion (
    DocumentVersionID INT IDENTITY(1,1) PRIMARY KEY,
    DocumentID INT,
    VersionNumber NVARCHAR(20),
    FilePath NVARCHAR(255),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    ModifierStaffID INT,
    VersionNote NVARCHAR(255),
    CONSTRAINT FK_DocumentVersion_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentVersion_Modifier FOREIGN KEY (ModifierStaffID) REFERENCES Staff(StaffID)
);
GO

-- Table: Tag
CREATE TABLE Tag (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Table: Document_Tag
CREATE TABLE Document_Tag (
    DocumentID INT,
    TagID INT,
    PRIMARY KEY (DocumentID, TagID),
    CONSTRAINT FK_DocumentTag_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentTag_Tag FOREIGN KEY (TagID) REFERENCES Tag(TagID)
);
GO

-- Table: DocumentAccess
CREATE TABLE DocumentAccess (
    DocumentID INT,
    StaffID INT,
    AccessType NVARCHAR(20),
    PRIMARY KEY (DocumentID, StaffID),
    CONSTRAINT FK_DocumentAccess_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentAccess_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
GO

-- Table: BudgetType
CREATE TABLE BudgetType (
    BudgetTypeID INT IDENTITY(1,1) PRIMARY KEY,
    BudgetTypeName NVARCHAR(100) NOT NULL
);
GO

-- Table: Budget
CREATE TABLE Budget (
    BudgetID INT IDENTITY(1,1) PRIMARY KEY,
    BranchID INT,
    BudgetTypeID INT,
    Amount DECIMAL(19,2) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    StatusID INT,
    CONSTRAINT FK_Budget_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Budget_BudgetType FOREIGN KEY (BudgetTypeID) REFERENCES BudgetType(BudgetTypeID),
    CONSTRAINT FK_Budget_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: PurchaseRequest
CREATE TABLE PurchaseRequest (
    PurchaseRequestID INT IDENTITY(1,1) PRIMARY KEY,
    BranchID INT,
    RequestDate DATE DEFAULT GETDATE(),
    RequestStaffID INT,
    Reason NVARCHAR(255),
    RequiredDate DATE,
    ApprovalDate DATE,
    ApproverStaffID INT,
    StatusID INT,
    CONSTRAINT FK_PurchaseRequest_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_PurchaseRequest_Staff FOREIGN KEY (RequestStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_PurchaseRequest_Approver FOREIGN KEY (ApproverStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_PurchaseRequest_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: PurchaseRequestDetail
CREATE TABLE PurchaseRequestDetail (
    PurchaseRequestDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseRequestID INT,
    ItemName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(19,2) NOT NULL,
    CONSTRAINT FK_PRDetail_PurchaseRequest FOREIGN KEY (PurchaseRequestID) REFERENCES PurchaseRequest(PurchaseRequestID)
);
GO

-- Table: TransactionType
CREATE TABLE TransactionType (
    TransactionTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TransactionTypeName NVARCHAR(100) NOT NULL,
    IsIncome BIT NOT NULL
);
GO

-- Table: Voucher
CREATE TABLE Voucher (
    VoucherID INT IDENTITY(1,1) PRIMARY KEY,
    VoucherCode NVARCHAR(50) UNIQUE NOT NULL,
    DiscountType NVARCHAR(20) NOT NULL,
    DiscountValue DECIMAL(19,2) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    UsageLimit INT DEFAULT -1,
    UsedCount INT DEFAULT 0,
    MinimumOrderAmount DECIMAL(19,2) DEFAULT 0,
    StatusID INT NOT NULL,
    LastModified DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Voucher_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: StudentTuition
CREATE TABLE StudentTuition (
    TuitionID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    ClassID INT NOT NULL,
    TotalFee DECIMAL(19,2) NOT NULL,
    VoucherID INT NULL,
    FinalFee AS (
        CASE
            WHEN VoucherID IS NOT NULL THEN
                CASE V.DiscountType
                    WHEN 'Percentage' THEN TotalFee * (1 - V.DiscountValue)
                    WHEN 'Amount' THEN TotalFee - V.DiscountValue
                    ELSE TotalFee
                END
            ELSE TotalFee
        END
    ),
    AmountPaid DECIMAL(19,2) DEFAULT 0,
    PaymentDate DATE NULL,
    PaymentMethod NVARCHAR(50) NULL,
    OutstandingBalance AS (
        CASE
            WHEN VoucherID IS NOT NULL THEN
                (TotalFee - (CASE V.DiscountType WHEN 'Percentage' THEN TotalFee * V.DiscountValue WHEN 'Amount' THEN V.DiscountValue ELSE 0 END)) - AmountPaid
            ELSE TotalFee - AmountPaid
        END
    ),
    DueDate DATE NULL,
    StatusID INT NOT NULL,
    LastModified DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_StudentTuition_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_StudentTuition_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT FK_StudentTuition_Voucher FOREIGN KEY (VoucherID) REFERENCES Voucher(VoucherID),
    CONSTRAINT FK_StudentTuition_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_StudentTuition_StudentClass UNIQUE (StudentID, ClassID)
);
GO

-- Table: FinancialTransaction
CREATE TABLE FinancialTransaction (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    BranchID INT,
    TransactionDate DATE DEFAULT GETDATE(),
    TransactionTypeID INT,
    Description NVARCHAR(255),
    Amount DECIMAL(19,2) NOT NULL,
    DueDate DATE,
    PaymentDate DATE,
    RelatedPurchaseRequestID INT,
    RelatedInvoiceID INT,
    RelatedTuitionID INT NULL,
    StatusID INT,
    CONSTRAINT FK_FinancialTransaction_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_FinancialTransaction_TransactionType FOREIGN KEY (TransactionTypeID) REFERENCES TransactionType(TransactionTypeID),
    CONSTRAINT FK_FinancialTransaction_PR FOREIGN KEY (RelatedPurchaseRequestID) REFERENCES PurchaseRequest(PurchaseRequestID),
    CONSTRAINT FK_FinancialTransaction_Tuition FOREIGN KEY (RelatedTuitionID) REFERENCES StudentTuition(TuitionID),
    CONSTRAINT FK_FinancialTransaction_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: ApprovalRequest
CREATE TABLE ApprovalRequest (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,
    RequestTitle NVARCHAR(255) NOT NULL,
    RequestContent NVARCHAR(MAX),
    RequesterID INT,
    CategoryID INT,
    StatusID INT,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastModifiedDate DATETIME,
    ApprovalDate DATETIME,
    ApproverStaffID INT,
    RelatedEntityType NVARCHAR(50),
    RelatedEntityID INT,
    ProposedChanges NVARCHAR(MAX),
    CONSTRAINT FK_ApprovalRequest_Requester FOREIGN KEY (RequesterID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_ApprovalRequest_Category FOREIGN KEY (CategoryID) REFERENCES RequestCategory(CategoryID),
    CONSTRAINT FK_ApprovalRequest_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT FK_ApprovalRequest_Approver FOREIGN KEY (ApproverStaffID) REFERENCES Staff(StaffID)
);
GO

-- Table: ApprovalLog
CREATE TABLE ApprovalLog (
    ApprovalLogID INT IDENTITY(1,1) PRIMARY KEY,
    RequestID INT,
    ApproverID INT,
    Action NVARCHAR(100),
    ActionDate DATETIME DEFAULT GETDATE(),
    Comment NVARCHAR(500),
    StatusID INT,
    CONSTRAINT FK_ApprovalLog_Request FOREIGN KEY (RequestID) REFERENCES ApprovalRequest(RequestID),
    CONSTRAINT FK_ApprovalLog_Approver FOREIGN KEY (ApproverID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_ApprovalLog_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Table: Timesheet
CREATE TABLE Timesheet (
    TimesheetID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    WorkDate DATE NOT NULL,
    CheckInTime TIME,
    CheckOutTime TIME,
    TotalWorkingHours DECIMAL(5,2),
    IsLate BIT DEFAULT 0,
    IsEarlyLeave BIT DEFAULT 0,
    OvertimeHours DECIMAL(5,2),
    NumberOfClasses INT DEFAULT 0,
    Note NVARCHAR(255),
    StatusID INT,
    CONSTRAINT FK_Timesheet_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Timesheet_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_Timesheet_StaffDate UNIQUE (StaffID, WorkDate)
);
GO

-- Table: DepartmentKPI
CREATE TABLE DepartmentKPI (
    KPIID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NULL,
    DepartmentID INT NULL,
    KPIMonth DATE NOT NULL,
    KPIType NVARCHAR(100) NOT NULL,
    KPIValue DECIMAL(19,2) NOT NULL,
    TargetValue DECIMAL(19,2) NULL,
    AchievedPercentage DECIMAL(5,2) NULL,
    CalculatedDate DATETIME DEFAULT GETDATE(),
    Note NVARCHAR(255),
    CONSTRAINT FK_DepartmentKPI_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_DepartmentKPI_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT UQ_DepartmentKPI_StaffDeptMonthType UNIQUE (StaffID, DepartmentID, KPIMonth, KPIType)
);
GO

-- Table: SalarySlip
CREATE TABLE SalarySlip (
    SalarySlipID INT IDENTITY(1,1) PRIMARY KEY,
    StaffID INT NOT NULL,
    SalaryMonth DATE NOT NULL,
    TotalWorkDays DECIMAL(5,2) NULL,
    TotalClassesTaught INT NULL,
    BaseSalary DECIMAL(19,2) NOT NULL,
    KPIBonus DECIMAL(19,2) DEFAULT 0,
    OtherEarnings DECIMAL(19,2) DEFAULT 0,
    FixedDeductions DECIMAL(19,2) DEFAULT 0,
    OtherDeductions DECIMAL(19,2) DEFAULT 0,
    GrossIncome DECIMAL(19,2) NOT NULL,
    NetIncome DECIMAL(19,2) NOT NULL,
    CalculatedDate DATETIME DEFAULT GETDATE(),
    EmailSentDate DATETIME NULL,
    StatusID INT,
    CONSTRAINT FK_SalarySlip_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_SalarySlip_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_SalarySlip_StaffMonth UNIQUE (StaffID, SalaryMonth)
);
GO

-- Additional indexes and constraints can be added as needed.

-- Stored procedures, functions, and triggers can be added similarly as in the original HHMS_Database.sql file.

-- This schema covers all major entities and relationships reflected in the UI files you uploaded.
