-- Tạo Database HHMS_Ngoaingu68 nếu chưa tồn tại
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'HHMS_Ngoaingu68')
BEGIN
    CREATE DATABASE HHMS_Ngoaingu68;
END
GO

-- Sử dụng Database HHMS_Ngoaingu68
USE HHMS_Ngoaingu68;
GO

--------------------------------------------------------------------------------
-- 1. Định nghĩa các bảng (Tables)
--    Các bảng này là xương sống của hệ thống, lưu trữ tất cả dữ liệu cơ bản.
--------------------------------------------------------------------------------

-- Bảng GeneralStatus: Lưu trữ các trạng thái chung cho nhiều đối tượng khác nhau (ví dụ: Active, Inactive, Approved, Pending).
CREATE TABLE GeneralStatus (
    StatusID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho trạng thái, tự động tăng
    StatusName NVARCHAR(100) NOT NULL,      -- Tên trạng thái (ví dụ: 'Hoạt động', 'Chờ duyệt', 'Đã duyệt')
    StatusType NVARCHAR(50),                -- Loại trạng thái áp dụng cho đối tượng nào (ví dụ: 'Chi nhánh', 'Nhân viên', 'Học viên')
    DisplayOrder INT,                       -- Thứ tự hiển thị các trạng thái
    IsActive BIT DEFAULT 1                  -- Trạng thái có đang được sử dụng không (1: Có, 0: Không)
);
GO

-- Bảng RequestCategory: Phân loại các loại yêu cầu (ví dụ: Yêu cầu mua hàng, Yêu cầu nghỉ phép).
CREATE TABLE RequestCategory (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho danh mục yêu cầu
    CategoryName NVARCHAR(100) NOT NULL,    -- Tên danh mục (ví dụ: 'Yêu cầu mua hàng', 'Yêu cầu nghỉ phép')
    Description NVARCHAR(255)               -- Mô tả chi tiết về danh mục
);
GO

-- Bảng Branch: Thông tin về các chi nhánh của trung tâm.
CREATE TABLE Branch (
    BranchID INT IDENTITY(1,1) PRIMARY KEY,   -- ID duy nhất cho chi nhánh
    BranchCode NVARCHAR(20) UNIQUE NOT NULL,  -- Mã chi nhánh (ví dụ: 'HN01', 'HCM02'), là duy nhất
    BranchName NVARCHAR(255) NOT NULL,        -- Tên đầy đủ của chi nhánh
    BranchAddress NVARCHAR(255),              -- Địa chỉ chi nhánh
    BranchLicense NVARCHAR(255),              -- Giấy phép kinh doanh của chi nhánh
    BranchDirector NVARCHAR(255),             -- Giám đốc chi nhánh
    BranchTotalStaff INT DEFAULT 0,           -- Tổng số nhân viên tại chi nhánh (có thể cập nhật tự động)
    BranchTotalStudent INT DEFAULT 0,         -- Tổng số học viên tại chi nhánh (có thể cập nhật tự động)
    BranchTotalActiveClass INT DEFAULT 0,     -- Tổng số lớp đang hoạt động tại chi nhánh (có thể cập nhật tự động)
    StatusID INT,                             -- Trạng thái của chi nhánh (liên kết với GeneralStatus)
    LastModified DATETIME DEFAULT GETDATE(),  -- Thời gian cập nhật cuối cùng
    CONSTRAINT FK_Branch_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Department: Thông tin về các phòng ban trong trung tâm.
CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho phòng ban
    DepartmentCode NVARCHAR(20) UNIQUE NOT NULL, -- Mã phòng ban (ví dụ: 'KD', 'HCNS'), là duy nhất
    DepartmentName NVARCHAR(255) NOT NULL,       -- Tên đầy đủ của phòng ban
    ManagerStaffName NVARCHAR(255),              -- Tên quản lý phòng ban (có thể liên kết tới StaffID sau này)
    StaffQuota INT,                              -- Định mức nhân sự cho phòng ban
    StatusID INT,                                -- Trạng thái của phòng ban (liên kết với GeneralStatus)
    CONSTRAINT FK_Department_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Major: Thông tin về các chuyên ngành đào tạo.
CREATE TABLE Major (
    MajorID INT IDENTITY(1,1) PRIMARY KEY,   -- ID duy nhất cho chuyên ngành
    MajorCode NVARCHAR(20) UNIQUE NOT NULL,  -- Mã chuyên ngành (ví dụ: 'ENGG', 'IELTS'), là duy nhất
    MajorName NVARCHAR(255) NOT NULL,        -- Tên chuyên ngành (ví dụ: 'Tiếng Anh Giao tiếp', 'Luyện thi IELTS')
    MajorDescription NVARCHAR(255),          -- Mô tả về chuyên ngành
    InputRequirement NVARCHAR(255),          -- Yêu cầu đầu vào của chuyên ngành
    OutputRequirement NVARCHAR(255),         -- Yêu cầu đầu ra của chuyên ngành
    TotalSessions INT,                       -- Tổng số buổi học của chuyên ngành
    BaseTuitionFee DECIMAL(19, 2),           -- Học phí cơ bản của chuyên ngành
    StatusID INT,                            -- Trạng thái của chuyên ngành (liên kết với GeneralStatus)
    CONSTRAINT FK_Major_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Staff: Thông tin chi tiết về nhân viên.
CREATE TABLE Staff (
    StaffID INT IDENTITY(1,1) PRIMARY KEY,    -- ID duy nhất cho nhân viên
    StaffCode NVARCHAR(20) UNIQUE,            -- Mã nhân viên (tự động sinh), là duy nhất
    FullName NVARCHAR(255) NOT NULL,          -- Họ và tên đầy đủ của nhân viên
    Gender NVARCHAR(10),                      -- Giới tính
    IDNumber NVARCHAR(50),                    -- Số CMND/CCCD
    BirthDate DATE,                           -- Ngày sinh
    StaffAddress NVARCHAR(255),               -- Địa chỉ liên hệ
    Phone NVARCHAR(20),                       -- Số điện thoại
    Email NVARCHAR(255),                      -- Địa chỉ Email
    SocialInsurance NVARCHAR(50),             -- Mã số bảo hiểm xã hội
    ContractType NVARCHAR(50),                -- Loại hợp đồng (ví dụ: 'Full-time', 'Part-time', 'Thử việc')
    ContractID INT,                           -- ID hợp đồng (có thể liên kết tới bảng hợp đồng chi tiết nếu có)
    DateJoined DATE,                          -- Ngày gia nhập công ty
    TaxCode NVARCHAR(50) NULL,                -- Mã số thuế
    BankBranch NVARCHAR(255),                 -- Chi nhánh ngân hàng
    BankAccount NVARCHAR(100),                -- Số tài khoản ngân hàng
    BranchID INT,                             -- Chi nhánh nơi nhân viên làm việc (liên kết với Branch)
    DepartmentID INT,                         -- Phòng ban nơi nhân viên làm việc (liên kết với Department)
    DisplayName NVARCHAR(300),                -- Tên hiển thị của nhân viên (tự động sinh)
    BaseSalary DECIMAL(19,2) DEFAULT 0,       -- Lương cơ bản hàng tháng
    FixedDeductions DECIMAL(19,2) DEFAULT 0,  -- Các khoản khấu trừ cố định hàng tháng
    StatusID INT,                             -- Trạng thái của nhân viên (liên kết với GeneralStatus)
    CONSTRAINT FK_Staff_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Staff_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Staff_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Staff_Log: Ghi lại các thay đổi của nhân viên (Insert, Update, Delete).
CREATE TABLE Staff_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,    -- ID duy nhất cho log
    StaffID INT,                            -- ID của nhân viên bị ảnh hưởng
    Action NVARCHAR(50),                    -- Hành động (ví dụ: 'INSERT', 'UPDATE', 'DELETE')
    ActionDate DATETIME DEFAULT GETDATE()   -- Thời gian xảy ra hành động
);
GO

-- Bảng Account: Tài khoản đăng nhập của nhân viên.
CREATE TABLE Account (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,  -- ID duy nhất cho tài khoản
    StaffID INT UNIQUE,                       -- ID nhân viên sở hữu tài khoản (liên kết với Staff, là duy nhất)
    Username NVARCHAR(100) UNIQUE NOT NULL,   -- Tên đăng nhập, là duy nhất
    PasswordHash NVARCHAR(255) NOT NULL,      -- Mật khẩu đã được mã hóa
    Email NVARCHAR(255) UNIQUE,               -- Email liên kết với tài khoản, là duy nhất
    DisplayName NVARCHAR(100),                -- Tên hiển thị của tài khoản
    StatusID INT,                             -- Trạng thái tài khoản (liên kết với GeneralStatus)
    CreatedAt DATETIME DEFAULT GETDATE(),     -- Thời gian tạo tài khoản
    UpdatedAt DATETIME,                       -- Thời gian cập nhật cuối cùng
    FirstLoginChangePwd BIT DEFAULT 1,        -- Cờ yêu cầu đổi mật khẩu lần đầu (1: Cần đổi, 0: Đã đổi)
    LastLogin DATETIME,                       -- Thời gian đăng nhập cuối cùng
    WrongLoginCount INT DEFAULT 0,            -- Số lần đăng nhập sai liên tiếp
    CONSTRAINT FK_Account_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Account_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Role: Định nghĩa các vai trò trong hệ thống (ví dụ: Admin, Giáo viên, Kế toán).
CREATE TABLE Role (
    RoleID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho vai trò
    RoleName NVARCHAR(50) NOT NULL,       -- Tên vai trò (ví dụ: 'Quản trị viên', 'Giáo viên')
    Description NVARCHAR(255)             -- Mô tả về vai trò
);
GO

-- Bảng Permission: Định nghĩa các quyền cụ thể (ví dụ: đọc tài liệu, chỉnh sửa thông tin học viên).
CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho quyền
    PermissionName NVARCHAR(100) NOT NULL,      -- Tên quyền (ví dụ: 'Đọc tài liệu', 'Sửa thông tin học viên')
    PermissionType NVARCHAR(50)                 -- Loại quyền (ví dụ: 'Data', 'Module', 'Report')
);
GO

-- Bảng Role_Permission: Gán quyền cho các vai trò (một vai trò có nhiều quyền).
CREATE TABLE Role_Permission (
    RoleID INT,             -- ID của vai trò (liên kết với Role)
    PermissionID INT,       -- ID của quyền (liên kết với Permission)
    PermissionValue NVARCHAR(50), -- Giá trị của quyền (ví dụ: 'Read', 'Write', 'FullControl')
    PRIMARY KEY (RoleID, PermissionID), -- Khóa chính kép
    CONSTRAINT FK_RolePermission_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    CONSTRAINT FK_RolePermission_Permission FOREIGN KEY (PermissionID) REFERENCES Permission(PermissionID)
);
GO

-- Bảng Staff_Role: Gán vai trò cho nhân viên (một nhân viên có thể có nhiều vai trò).
CREATE TABLE Staff_Role (
    StaffID INT,    -- ID của nhân viên (liên kết với Staff)
    RoleID INT,     -- ID của vai trò (liên kết với Role)
    PRIMARY KEY (StaffID, RoleID), -- Khóa chính kép
    CONSTRAINT FK_StaffRole_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_StaffRole_Role FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);
GO

-- Bảng Student: Thông tin chi tiết về học viên.
CREATE TABLE Student (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,    -- ID duy nhất cho học viên
    StudentCode NVARCHAR(20) UNIQUE,            -- Mã học viên (tự động sinh), là duy nhất
    FullName NVARCHAR(255) NOT NULL,            -- Họ và tên đầy đủ của học viên
    Gender NVARCHAR(10),                        -- Giới tính
    IDNumber NVARCHAR(50),                    -- Số CMND/CCCD
    BirthDate DATE,                           -- Ngày sinh
    StudentAddress NVARCHAR(255),               -- Địa chỉ liên hệ
    Phone NVARCHAR(20),                         -- Số điện thoại
    Email NVARCHAR(255),                        -- Địa chỉ Email
    BranchID INT,                               -- Chi nhánh học viên đăng ký (liên kết với Branch)
    MajorID INT,                                -- Chuyên ngành học viên đăng ký (liên kết với Major)
    ConsultantStaffID INT,                      -- Nhân viên tư vấn cho học viên này (liên kết với Staff)
    EntryLevel NVARCHAR(20),                    -- Trình độ đầu vào (ví dụ: A1, A2)
    ExitLevel NVARCHAR(20),                     -- Trình độ đầu ra mục tiêu
    StatusID INT,                               -- Trạng thái của học viên (liên kết với GeneralStatus)
    CONSTRAINT FK_Student_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Student_Major FOREIGN KEY (MajorID) REFERENCES Major(MajorID),
    CONSTRAINT FK_Student_Staff FOREIGN KEY (ConsultantStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Student_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Class: Thông tin về các lớp học.
CREATE TABLE Class (
    ClassID INT IDENTITY(1,1) PRIMARY KEY,        -- ID duy nhất cho lớp học
    ClassCode NVARCHAR(30) UNIQUE,                -- Mã lớp học (tự động sinh), là duy nhất
    ClassName NVARCHAR(255) NOT NULL,             -- Tên đầy đủ của lớp học
    MajorID INT,                                  -- Chuyên ngành mà lớp này thuộc về (liên kết với Major)
    BranchID INT,                                 -- Chi nhánh tổ chức lớp học (liên kết với Branch)
    MainTeacherID INT,                            -- Giáo viên chính của lớp (liên kết với Staff)
    AssistantID INT,                              -- Trợ giảng của lớp (liên kết với Staff)
    Room NVARCHAR(50),                            -- Phòng học
    StartDate DATE,                               -- Ngày bắt đầu khóa học
    ExpectedEndDate DATE,                         -- Ngày dự kiến kết thúc khóa học
    TrainingProgress NVARCHAR(255),               -- Tiến độ đào tạo của lớp (ví dụ: 'Đang học', 'Hoàn thành')
    StatusID INT,                                 -- Trạng thái của lớp (liên kết với GeneralStatus)
    CONSTRAINT FK_Class_Major FOREIGN KEY (MajorID) REFERENCES Major(MajorID),
    CONSTRAINT FK_Class_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Class_MainTeacher FOREIGN KEY (MainTeacherID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Class_Assistant FOREIGN KEY (AssistantID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Class_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng ClassSchedule: Lịch học chi tiết của từng lớp.
CREATE TABLE ClassSchedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho buổi học
    ClassID INT,                              -- ID của lớp học (liên kết với Class)
    StudyDate DATE NOT NULL,                  -- Ngày diễn ra buổi học
    StartTime TIME NOT NULL,                  -- Thời gian bắt đầu buổi học
    EndTime TIME NOT NULL,                    -- Thời gian kết thúc buổi học
    Room NVARCHAR(50),                        -- Phòng học cụ thể cho buổi này (có thể khác với phòng mặc định của lớp)
    CONSTRAINT FK_ClassSchedule_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
);
GO

-- Bảng Registration: Quản lý việc đăng ký lớp học của học viên.
CREATE TABLE Registration (
    RegistrationID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho lượt đăng ký
    StudentID INT,                                -- ID của học viên đăng ký (liên kết với Student)
    ClassID INT,                                  -- ID của lớp học được đăng ký (liên kết với Class)
    RegistrationDate DATE DEFAULT GETDATE(),      -- Ngày đăng ký
    StatusID INT,                                 -- Trạng thái đăng ký (ví dụ: 'Đã đăng ký', 'Đã hủy')
    Note NVARCHAR(255),                           -- Ghi chú về lượt đăng ký
    CONSTRAINT FK_Registration_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_Registration_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT FK_Registration_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Attendance: Ghi nhận điểm danh học viên theo từng buổi học.
CREATE TABLE Attendance (
    AttendanceID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho lần điểm danh
    ScheduleID INT,                             -- ID của buổi học (liên kết với ClassSchedule)
    StudentID INT,                              -- ID của học viên (liên kết với Student)
    AttendanceStatus NVARCHAR(20),              -- Trạng thái điểm danh ('Present': Có mặt, 'Absent': Vắng mặt, 'Late': Đi muộn)
    Note NVARCHAR(255),                         -- Ghi chú về việc điểm danh
    CONSTRAINT FK_Attendance_Schedule FOREIGN KEY (ScheduleID) REFERENCES ClassSchedule(ScheduleID),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);
GO

-- Bảng StudentGrade: Lưu trữ điểm số của học viên trong các bài kiểm tra.
CREATE TABLE StudentGrade (
    GradeID INT IDENTITY(1,1) PRIMARY KEY,  -- ID duy nhất cho điểm số
    StudentID INT,                          -- ID của học viên (liên kết với Student)
    ClassID INT,                            -- ID của lớp học (liên kết với Class)
    TestName NVARCHAR(255),                 -- Tên bài kiểm tra (ví dụ: 'Bài giữa kỳ', 'Bài cuối kỳ')
    Score DECIMAL(5, 2),                    -- Điểm số (ví dụ: 8.5, 9.0)
    GradingDate DATE DEFAULT GETDATE(),     -- Ngày chấm điểm
    Note NVARCHAR(255),                     -- Ghi chú về điểm số
    CONSTRAINT FK_StudentGrade_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_StudentGrade_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID)
);
GO

-- Bảng DocumentType: Phân loại các loại tài liệu.
CREATE TABLE DocumentType (
    DocumentTypeID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho loại tài liệu
    DocumentTypeName NVARCHAR(100) NOT NULL,      -- Tên loại tài liệu (ví dụ: 'Hợp đồng', 'Quy định nội bộ')
    Description NVARCHAR(255)                     -- Mô tả loại tài liệu
);
GO

-- Bảng Document: Thông tin về các tài liệu trong hệ thống.
CREATE TABLE Document (
    DocumentID INT IDENTITY(1,1) PRIMARY KEY,     -- ID duy nhất cho tài liệu
    DocumentName NVARCHAR(255) NOT NULL,          -- Tên tài liệu
    DepartmentID INT,                             -- Phòng ban sở hữu tài liệu (liên kết với Department)
    DocumentTypeID INT,                           -- Loại tài liệu (liên kết với DocumentType)
    PhysicalLocation NVARCHAR(255),               -- Vị trí lưu trữ vật lý (nếu có)
    FilePath NVARCHAR(255),                       -- Đường dẫn file trên hệ thống
    Description NVARCHAR(255),                    -- Mô tả tài liệu
    CreatedDate DATETIME DEFAULT GETDATE(),       -- Ngày tạo tài liệu
    CreatorStaffID INT,                           -- Nhân viên tạo tài liệu (liên kết với Staff)
    LastModifiedDate DATETIME,                    -- Ngày chỉnh sửa cuối cùng
    LastModifierStaffID INT,                      -- Nhân viên chỉnh sửa cuối cùng (liên kết với Staff)
    StatusID INT,                                 -- Trạng thái của tài liệu (liên kết với GeneralStatus)
    CONSTRAINT FK_Document_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT FK_Document_DocumentType FOREIGN KEY (DocumentTypeID) REFERENCES DocumentType(DocumentTypeID),
    CONSTRAINT FK_Document_Creator FOREIGN KEY (CreatorStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Document_Modifier FOREIGN KEY (LastModifierStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Document_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng DocumentVersion: Lịch sử các phiên bản của tài liệu.
CREATE TABLE DocumentVersion (
    DocumentVersionID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho phiên bản tài liệu
    DocumentID INT,                                  -- ID của tài liệu (liên kết với Document)
    VersionNumber NVARCHAR(20),                      -- Số phiên bản (ví dụ: '1.0', '1.1')
    FilePath NVARCHAR(255),                          -- Đường dẫn file của phiên bản cụ thể này
    ModifiedDate DATETIME DEFAULT GETDATE(),         -- Ngày chỉnh sửa phiên bản
    ModifierStaffID INT,                             -- Nhân viên chỉnh sửa phiên bản (liên kết với Staff)
    VersionNote NVARCHAR(255),                       -- Ghi chú về phiên bản
    CONSTRAINT FK_DocumentVersion_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentVersion_Modifier FOREIGN KEY (ModifierStaffID) REFERENCES Staff(StaffID)
);
GO

-- Bảng Tag: Thẻ (nhãn) để phân loại tài liệu hoặc các đối tượng khác.
CREATE TABLE Tag (
    TagID INT IDENTITY(1,1) PRIMARY KEY,  -- ID duy nhất cho thẻ
    TagName NVARCHAR(100) NOT NULL UNIQUE -- Tên thẻ (ví dụ: 'Hợp đồng', 'Tài liệu đào tạo'), là duy nhất
);
GO

-- Bảng Document_Tag: Ánh xạ nhiều-nhiều giữa Document và Tag (một tài liệu có nhiều thẻ, một thẻ áp dụng cho nhiều tài liệu).
CREATE TABLE Document_Tag (
    DocumentID INT, -- ID tài liệu (liên kết với Document)
    TagID INT,      -- ID thẻ (liên kết với Tag)
    PRIMARY KEY (DocumentID, TagID), -- Khóa chính kép
    CONSTRAINT FK_DocumentTag_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentTag_Tag FOREIGN KEY (TagID) REFERENCES Tag(TagID)
);
GO

-- Bảng DocumentAccess: Quyền truy cập tài liệu cho từng nhân viên.
-- AccessType: 'Read' (Xem), 'Write' (Ghi/Tải lên), 'FullControl' (Toàn quyền)
CREATE TABLE DocumentAccess (
    DocumentID INT,                 -- ID tài liệu (liên kết với Document)
    StaffID INT,                    -- ID nhân viên (liên kết với Staff)
    AccessType NVARCHAR(20),        -- Loại quyền truy cập ('Read': Đọc, 'Write': Ghi/Tải lên, 'FullControl': Toàn quyền)
    PRIMARY KEY (DocumentID, StaffID), -- Khóa chính kép
    CONSTRAINT FK_DocumentAccess_Document FOREIGN KEY (DocumentID) REFERENCES Document(DocumentID),
    CONSTRAINT FK_DocumentAccess_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
GO

-- Bảng BudgetType: Loại ngân sách (ví dụ: Ngân sách hoạt động, Ngân sách Marketing).
CREATE TABLE BudgetType (
    BudgetTypeID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho loại ngân sách
    BudgetTypeName NVARCHAR(100) NOT NULL       -- Tên loại ngân sách
);
GO

-- Bảng Budget: Ngân sách được phân bổ cho từng chi nhánh theo loại.
CREATE TABLE Budget (
    BudgetID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho khoản ngân sách
    BranchID INT,                           -- Chi nhánh được phân bổ ngân sách (liên kết với Branch)
    BudgetTypeID INT,                       -- Loại ngân sách (liên kết với BudgetType)
    Amount DECIMAL(19, 2) NOT NULL,         -- Số tiền ngân sách
    StartDate DATE,                         -- Ngày bắt đầu kỳ ngân sách
    EndDate DATE,                           -- Ngày kết thúc kỳ ngân sách
    StatusID INT,                           -- Trạng thái ngân sách (liên kết với GeneralStatus)
    CONSTRAINT FK_Budget_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_Budget_BudgetType FOREIGN KEY (BudgetTypeID) REFERENCES BudgetType(BudgetTypeID),
    CONSTRAINT FK_Budget_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng PurchaseRequest: Yêu cầu mua hàng.
CREATE TABLE PurchaseRequest (
    PurchaseRequestID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho yêu cầu mua hàng
    BranchID INT,                                    -- Chi nhánh tạo yêu cầu (liên kết với Branch)
    RequestDate DATE DEFAULT GETDATE(),              -- Ngày tạo yêu cầu
    RequestStaffID INT,                              -- Nhân viên tạo yêu cầu (liên kết với Staff)
    Reason NVARCHAR(255),                            -- Lý do yêu cầu mua hàng
    RequiredDate DATE,                               -- Ngày cần hàng
    ApprovalDate DATE,                               -- Ngày được phê duyệt
    ApproverStaffID INT,                             -- Nhân viên phê duyệt (liên kết với Staff)
    StatusID INT,                                    -- Trạng thái yêu cầu (liên kết với GeneralStatus)
    CONSTRAINT FK_PurchaseRequest_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_PurchaseRequest_Staff FOREIGN KEY (RequestStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_PurchaseRequest_Approver FOREIGN KEY (ApproverStaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_PurchaseRequest_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng PurchaseRequestDetail: Chi tiết các mặt hàng trong yêu cầu mua hàng.
CREATE TABLE PurchaseRequestDetail (
    PurchaseRequestDetailID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho chi tiết yêu cầu
    PurchaseRequestID INT,                                 -- ID yêu cầu mua hàng (liên kết với PurchaseRequest)
    ItemName NVARCHAR(255) NOT NULL,                       -- Tên mặt hàng
    Description NVARCHAR(255),                             -- Mô tả mặt hàng
    Quantity INT NOT NULL,                                 -- Số lượng
    UnitPrice DECIMAL(19, 2) NOT NULL,                     -- Đơn giá
    CONSTRAINT FK_PRDetail_PurchaseRequest FOREIGN KEY (PurchaseRequestID) REFERENCES PurchaseRequest(PurchaseRequestID)
);
GO
-- Thêm cột tính toán TotalAmount tự động
ALTER TABLE PurchaseRequestDetail ADD TotalAmount AS (Quantity * UnitPrice);
GO

-- Bảng TransactionType: Loại giao dịch tài chính (Thu nhập hay Chi phí).
CREATE TABLE TransactionType (
    TransactionTypeID INT IDENTITY(1,1) PRIMARY KEY, -- ID duy nhất cho loại giao dịch
    TransactionTypeName NVARCHAR(100) NOT NULL,      -- Tên loại giao dịch (ví dụ: 'Thu học phí', 'Chi lương')
    IsIncome BIT NOT NULL                           -- Là giao dịch thu nhập (1: Có, 0: Không)
);
GO

-- Bảng Voucher: Lưu trữ thông tin về các mã giảm giá (voucher).
CREATE TABLE Voucher (
    VoucherID INT IDENTITY(1,1) PRIMARY KEY,    -- ID duy nhất cho voucher
    VoucherCode NVARCHAR(50) UNIQUE NOT NULL,   -- Mã voucher (ví dụ: 'SUMMER2025', 'WELCOME10'), là duy nhất
    DiscountType NVARCHAR(20) NOT NULL,         -- Loại giảm giá ('Percentage' hoặc 'Amount')
    DiscountValue DECIMAL(19, 2) NOT NULL,      -- Giá trị giảm giá (ví dụ: 0.10 cho 10%, hoặc 500000 cho 500k VNĐ)
    ValidFrom DATE NOT NULL,                    -- Ngày bắt đầu hiệu lực
    ValidTo DATE NOT NULL,                      -- Ngày kết thúc hiệu lực
    UsageLimit INT DEFAULT -1,                  -- Giới hạn số lần sử dụng (-1 cho không giới hạn)
    UsedCount INT DEFAULT 0,                    -- Số lần đã được sử dụng
    MinimumOrderAmount DECIMAL(19, 2) DEFAULT 0, -- Giá trị đơn hàng tối thiểu để áp dụng voucher
    StatusID INT NOT NULL,                      -- Trạng thái của voucher (liên kết với GeneralStatus: 'Hoạt động', 'Hết hạn', 'Đã dùng hết')
    LastModified DATETIME DEFAULT GETDATE(),    -- Thời gian cập nhật cuối cùng
    CONSTRAINT FK_Voucher_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng StudentTuition: Bảng quản lý học phí của từng học viên cho mỗi lớp học.
CREATE TABLE StudentTuition (
    TuitionID INT IDENTITY(1,1) PRIMARY KEY,        -- ID duy nhất cho khoản học phí
    StudentID INT NOT NULL,                         -- ID học viên (liên kết với Student)
    ClassID INT NOT NULL,                           -- ID lớp học (liên kết với Class)
    TotalFee DECIMAL(19, 2) NOT NULL,               -- Tổng học phí gốc của lớp (lấy từ Major.BaseTuitionFee)
    VoucherID INT NULL,                             -- ID Voucher được áp dụng (liên kết với Voucher)
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
    ),                                              -- Học phí cuối cùng sau khi áp dụng voucher (tự động tính)
    AmountPaid DECIMAL(19, 2) DEFAULT 0,            -- Số tiền đã đóng
    PaymentDate DATE NULL,                          -- Ngày đóng tiền gần nhất
    PaymentMethod NVARCHAR(50) NULL,                -- Hình thức thanh toán (ví dụ: 'Tiền mặt', 'Chuyển khoản')
    OutstandingBalance AS (
        CASE
            WHEN VoucherID IS NOT NULL THEN
                (TotalFee - (CASE V.DiscountType WHEN 'Percentage' THEN TotalFee * V.DiscountValue WHEN 'Amount' THEN V.DiscountValue ELSE 0 END)) - AmountPaid
            ELSE TotalFee - AmountPaid
        END
    ),                                              -- Số tiền còn thiếu (tự động tính)
    DueDate DATE NULL,                              -- Ngày hẹn hoàn thiện thanh toán
    StatusID INT NOT NULL,                          -- Trạng thái học phí (liên kết với GeneralStatus: 'Đã thanh toán', 'Chưa thanh toán', 'Thanh toán một phần', 'Quá hạn')
    LastModified DATETIME DEFAULT GETDATE(),        -- Thời gian cập nhật cuối cùng
    CONSTRAINT FK_StudentTuition_Student FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    CONSTRAINT FK_StudentTuition_Class FOREIGN KEY (ClassID) REFERENCES Class(ClassID),
    CONSTRAINT FK_StudentTuition_Voucher FOREIGN KEY (VoucherID) REFERENCES Voucher(VoucherID),
    CONSTRAINT FK_StudentTuition_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_StudentTuition_StudentClass UNIQUE (StudentID, ClassID) -- Đảm bảo mỗi học viên chỉ có 1 khoản học phí cho mỗi lớp
);
GO

-- Bảng FinancialTransaction: Các giao dịch tài chính phát sinh.
CREATE TABLE FinancialTransaction (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,     -- ID duy nhất cho giao dịch
    BranchID INT,                                    -- Chi nhánh phát sinh giao dịch (liên kết với Branch)
    TransactionDate DATE DEFAULT GETDATE(),          -- Ngày giao dịch
    TransactionTypeID INT,                           -- Loại giao dịch (liên kết với TransactionType)
    Description NVARCHAR(255),                       -- Mô tả giao dịch
    Amount DECIMAL(19, 2) NOT NULL,                  -- Số tiền giao dịch
    DueDate DATE,                                    -- Ngày đáo hạn (nếu là khoản phải thu/phải trả)
    PaymentDate DATE,                                -- Ngày thanh toán thực tế
    RelatedPurchaseRequestID INT,                    -- Liên kết với yêu cầu mua hàng nếu có (liên kết với PurchaseRequest)
    RelatedInvoiceID INT,                            -- Liên kết với hóa đơn nếu có (có thể là một bảng Invoice riêng nếu cần)
    RelatedTuitionID INT NULL,                       -- Liên kết với khoản học phí nếu là giao dịch thu học phí
    StatusID INT,                                    -- Trạng thái giao dịch (liên kết với GeneralStatus)
    CONSTRAINT FK_FinancialTransaction_Branch FOREIGN KEY (BranchID) REFERENCES Branch(BranchID),
    CONSTRAINT FK_FinancialTransaction_TransactionType FOREIGN KEY (TransactionTypeID) REFERENCES TransactionType(TransactionTypeID),
    CONSTRAINT FK_FinancialTransaction_PR FOREIGN KEY (RelatedPurchaseRequestID) REFERENCES PurchaseRequest(PurchaseRequestID),
    CONSTRAINT FK_FinancialTransaction_Tuition FOREIGN KEY (RelatedTuitionID) REFERENCES StudentTuition(TuitionID),
    CONSTRAINT FK_FinancialTransaction_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng ApprovalRequest: Yêu cầu phê duyệt trong các quy trình.
CREATE TABLE ApprovalRequest (
    RequestID INT IDENTITY(1,1) PRIMARY KEY,      -- ID duy nhất cho yêu cầu phê duyệt
    RequestTitle NVARCHAR(255) NOT NULL,          -- Tiêu đề yêu cầu
    RequestContent NVARCHAR(MAX),                 -- Nội dung chi tiết yêu cầu
    RequesterID INT,                              -- Nhân viên tạo yêu cầu (liên kết với Staff)
    CategoryID INT,                               -- Danh mục yêu cầu (liên kết với RequestCategory)
    StatusID INT,                                 -- Trạng thái yêu cầu (ví dụ: 'Đang chờ', 'Đã duyệt', 'Từ chối')
    CreatedDate DATETIME DEFAULT GETDATE(),       -- Ngày tạo yêu cầu
    LastModifiedDate DATETIME,                    -- Ngày cập nhật cuối cùng
    ApprovalDate DATETIME,                        -- Ngày phê duyệt
    ApproverStaffID INT,                          -- Nhân viên phê duyệt
    -- Thêm các cột mới để hỗ trợ luồng phê duyệt
    RelatedEntityType NVARCHAR(50),               -- Loại đối tượng liên quan (ví dụ: 'Staff', 'Student', 'Permission', 'Class', 'Major', 'Branch', 'Department', 'Document', 'StudentTuition', 'Voucher', etc.)
    RelatedEntityID INT,                          -- ID của đối tượng liên quan (NULL nếu là thêm mới)
    ProposedChanges NVARCHAR(MAX),                -- Dữ liệu thay đổi đề xuất (dạng JSON)
    CONSTRAINT FK_ApprovalRequest_Requester FOREIGN KEY (RequesterID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_ApprovalRequest_Category FOREIGN KEY (CategoryID) REFERENCES RequestCategory(CategoryID),
    CONSTRAINT FK_ApprovalRequest_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT FK_ApprovalRequest_Approver FOREIGN KEY (ApproverStaffID) REFERENCES Staff(StaffID)
);
GO

-- Bảng ApprovalLog: Nhật ký phê duyệt cho từng yêu cầu.
CREATE TABLE ApprovalLog (
    ApprovalLogID INT IDENTITY(1,1) PRIMARY KEY,  -- ID duy nhất cho bản ghi nhật ký
    RequestID INT,                                -- ID của yêu cầu phê duyệt (liên kết với ApprovalRequest)
    ApproverID INT,                               -- Nhân viên thực hiện hành động phê duyệt (liên kết với Staff)
    Action NVARCHAR(100),                         -- Hành động ('Submitted': Đã gửi, 'Approved': Đã duyệt, 'Rejected': Từ chối, 'Commented': Bình luận)
    ActionDate DATETIME DEFAULT GETDATE(),        -- Ngày và giờ hành động
    Comment NVARCHAR(500),                        -- Bình luận chi tiết về hành động
    StatusID INT,                                 -- Trạng thái của yêu cầu sau hành động (liên kết với GeneralStatus)
    CONSTRAINT FK_ApprovalLog_Request FOREIGN KEY (RequestID) REFERENCES ApprovalRequest(RequestID),
    CONSTRAINT FK_ApprovalLog_Approver FOREIGN KEY (ApproverID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_ApprovalLog_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID)
);
GO

-- Bảng Timesheet: Lưu trữ dữ liệu chấm công hàng ngày cho nhân viên.
-- Đây là bảng mới được thêm vào để quản lý chấm công.
CREATE TABLE Timesheet (
    TimesheetID INT IDENTITY(1,1) PRIMARY KEY,  -- ID duy nhất cho bản ghi chấm công
    StaffID INT NOT NULL,                       -- ID của nhân viên (liên kết với Staff)
    WorkDate DATE NOT NULL,                     -- Ngày chấm công
    CheckInTime TIME,                           -- Giờ vào
    CheckOutTime TIME,                          -- Giờ ra
    TotalWorkingHours DECIMAL(5,2),             -- Tổng số giờ làm việc (tính toán)
    IsLate BIT DEFAULT 0,                       -- Có đi muộn không (1: Có, 0: Không)
    IsEarlyLeave BIT DEFAULT 0,                 -- Có về sớm không (1: Có, 0: Không)
    OvertimeHours DECIMAL(5,2),                 -- Số giờ làm thêm (nếu có)
    NumberOfClasses INT DEFAULT 0,              -- Số ca dạy trong ngày (tính toán cho giáo viên)
    Note NVARCHAR(255),                         -- Ghi chú (ví dụ: 'Nghỉ phép', 'Công tác')
    StatusID INT,                               -- Trạng thái chấm công (ví dụ: 'Đã duyệt', 'Chờ duyệt', 'Vắng mặt')
    CONSTRAINT FK_Timesheet_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Timesheet_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_Timesheet_StaffDate UNIQUE (StaffID, WorkDate) -- Đảm bảo mỗi nhân viên chỉ có 1 bản ghi chấm công mỗi ngày
);
GO

-- Bảng DepartmentKPI: Lưu trữ các chỉ số KPI được tính toán cho từng phòng ban hoặc nhân viên.
-- Đây là bảng mới để lưu trữ kết quả KPI.
CREATE TABLE DepartmentKPI (
    KPIID INT IDENTITY(1,1) PRIMARY KEY,        -- ID duy nhất cho bản ghi KPI
    StaffID INT NULL,                           -- ID nhân viên (nếu KPI là cá nhân, ví dụ: giáo viên)
    DepartmentID INT NULL,                      -- ID phòng ban (nếu KPI là của phòng ban, ví dụ: HR)
    KPIMonth DATE NOT NULL,                     -- Tháng tính KPI (ví dụ: '2025-07-01')
    KPIType NVARCHAR(100) NOT NULL,             -- Loại KPI (ví dụ: 'HR_TotalTuitionRevenue', 'Teacher_FulltimeAttendanceRate', 'Teacher_ParttimeHighAttendanceDays')
    KPIValue DECIMAL(19,2) NOT NULL,            -- Giá trị KPI đạt được
    TargetValue DECIMAL(19,2) NULL,             -- Giá trị mục tiêu (có thể có)
    AchievedPercentage DECIMAL(5,2) NULL,       -- Phần trăm đạt được mục tiêu (KPIValue / TargetValue * 100)
    CalculatedDate DATETIME DEFAULT GETDATE(),  -- Ngày tính toán KPI
    Note NVARCHAR(255),                         -- Ghi chú về KPI
    CONSTRAINT FK_DepartmentKPI_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_DepartmentKPI_Department FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT UQ_DepartmentKPI_StaffDeptMonthType UNIQUE (StaffID, DepartmentID, KPIMonth, KPIType) -- Đảm bảo duy nhất cho mỗi KPI
);
GO

-- Bảng SalarySlip: Lưu trữ chi tiết bảng lương của từng nhân viên theo tháng.
-- Đây là bảng mới để lưu trữ dữ liệu bảng lương.
CREATE TABLE SalarySlip (
    SalarySlipID INT IDENTITY(1,1) PRIMARY KEY,     -- ID duy nhất cho bảng lương
    StaffID INT NOT NULL,                           -- ID nhân viên (liên kết với Staff)
    SalaryMonth DATE NOT NULL,                      -- Tháng của bảng lương (ví dụ: '2025-07-01')
    TotalWorkDays DECIMAL(5,2) NULL,                -- Tổng ngày công (chỉ cho Full-time)
    TotalClassesTaught INT NULL,                    -- Tổng số ca dạy
    BaseSalary DECIMAL(19,2) NOT NULL,              -- Lương cơ bản
    KPIBonus DECIMAL(19,2) DEFAULT 0,               -- Thưởng KPI
    OtherEarnings DECIMAL(19,2) DEFAULT 0,          -- Các khoản thu nhập khác (ví dụ: phụ cấp)
    FixedDeductions DECIMAL(19,2) DEFAULT 0,        -- Các khoản khấu trừ cố định (ví dụ: bảo hiểm)
    OtherDeductions DECIMAL(19,2) DEFAULT 0,        -- Các khoản khấu trừ khác (ví dụ: phạt)
    GrossIncome DECIMAL(19,2) NOT NULL,             -- Tổng thu nhập (trước thuế/khấu trừ)
    NetIncome DECIMAL(19,2) NOT NULL,               -- Thu nhập thực lĩnh
    CalculatedDate DATETIME DEFAULT GETDATE(),      -- Ngày tính toán bảng lương
    EmailSentDate DATETIME NULL,                    -- Ngày gửi email bảng lương
    StatusID INT,                                   -- Trạng thái bảng lương (liên kết với GeneralStatus, ví dụ: 'Đã gửi', 'Chưa gửi')
    CONSTRAINT FK_SalarySlip_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_SalarySlip_Status FOREIGN KEY (StatusID) REFERENCES GeneralStatus(StatusID),
    CONSTRAINT UQ_SalarySlip_StaffMonth UNIQUE (StaffID, SalaryMonth) -- Đảm bảo mỗi nhân viên chỉ có 1 bảng lương mỗi tháng
);
GO

--------------------------------------------------------------------------------
-- 2. Các bảng hỗ trợ sinh mã (Sequence Tables)
--    Các bảng này giúp quản lý và sinh các mã code tự động, duy nhất.
--------------------------------------------------------------------------------

-- Bảng StaffCodeSequence: Lưu trữ số thứ tự cuối cùng để sinh StaffCode theo năm.
CREATE TABLE StaffCodeSequence (
    CodeYear NVARCHAR(4) PRIMARY KEY, -- Năm (ví dụ: '2025')
    LastNumber INT NOT NULL           -- Số thứ tự cuối cùng đã được cấp trong năm đó
);
GO

-- Bảng StudentCodeSequence: Lưu trữ số thứ tự cuối cùng để sinh StudentCode theo MajorCode.
CREATE TABLE StudentCodeSequence (
    MajorCode NVARCHAR(20) PRIMARY KEY, -- Mã chuyên ngành (ví dụ: 'ENGG', 'IELTS')
    LastNumber INT NOT NULL             -- Số thứ tự cuối cùng đã được cấp cho chuyên ngành đó
);
GO

--------------------------------------------------------------------------------
-- 3. Views
--    Các View cung cấp cái nhìn tổng hợp dữ liệu từ nhiều bảng, phục vụ báo cáo.
--------------------------------------------------------------------------------

-- View vw_StatusByType: Hiển thị các trạng thái đang hoạt động, có thể lọc theo loại.
CREATE VIEW vw_StatusByType AS
SELECT
    StatusID,
    StatusName,
    StatusType,
    DisplayOrder
FROM
    GeneralStatus
WHERE
    IsActive = 1; -- Chỉ lấy các trạng thái đang hoạt động
GO

-- View vw_RevenueReport: Báo cáo tổng hợp doanh thu và chi phí theo ngày và chi nhánh.
CREATE VIEW vw_RevenueReport AS
SELECT
    CAST(FT.TransactionDate AS DATE) AS ReportDate, -- Ngày báo cáo
    B.BranchID,                                     -- ID chi nhánh
    B.BranchName,                                   -- Tên chi nhánh
    SUM(CASE WHEN TT.IsIncome = 1 THEN FT.Amount ELSE 0 END) AS TotalRevenue, -- Tổng doanh thu
    SUM(CASE WHEN TT.IsIncome = 0 THEN FT.Amount ELSE 0 END) AS TotalCost,    -- Tổng chi phí
    SUM(CASE WHEN TT.IsIncome = 1 THEN FT.Amount ELSE 0 END) - SUM(CASE WHEN TT.IsIncome = 0 THEN FT.Amount ELSE 0 END) AS NetProfit -- Lợi nhuận ròng
FROM
    FinancialTransaction FT
JOIN
    Branch B ON FT.BranchID = B.BranchID
JOIN
    TransactionType TT ON FT.TransactionTypeID = TT.TransactionTypeID
GROUP BY
    CAST(FT.TransactionDate AS DATE), B.BranchID, B.BranchName;
GO

-- View vw_StudentProgress: Theo dõi tiến độ học tập của học viên (tỷ lệ chuyên cần, điểm trung bình).
CREATE VIEW vw_StudentProgress AS
SELECT
    S.StudentID,
    S.FullName,
    C.ClassID,
    C.ClassName,
    COUNT(CS.ScheduleID) AS TotalSessions, -- Tổng số buổi học của lớp
    SUM(CASE WHEN A.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) AS SessionsAttended, -- Số buổi đã tham gia
    (100.0 * SUM(CASE WHEN A.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) / NULLIF(COUNT(CS.ScheduleID), 0)) AS AttendanceRate, -- Tỷ lệ chuyên cần
    AVG(CAST(G.Score AS FLOAT)) AS AverageScore -- Điểm trung bình các bài kiểm tra
FROM
    Student S
JOIN
    Registration R ON S.StudentID = R.StudentID
JOIN
    Class C ON R.ClassID = C.ClassID
LEFT JOIN
    ClassSchedule CS ON C.ClassID = CS.ClassID
LEFT JOIN
    Attendance A ON CS.ScheduleID = A.ScheduleID AND S.StudentID = A.StudentID
LEFT JOIN
    StudentGrade G ON S.StudentID = G.StudentID AND C.ClassID = G.ClassID
GROUP BY
    S.StudentID, S.FullName, C.ClassID, C.ClassName;
GO

-- View vw_StaffTimesheetSummary: Tổng hợp dữ liệu chấm công theo tháng cho từng nhân viên.
CREATE VIEW vw_StaffTimesheetSummary AS
SELECT
    TS.StaffID,
    S.FullName,
    S.ContractType,
    YEAR(TS.WorkDate) AS WorkYear,
    MONTH(TS.WorkDate) AS WorkMonth,
    COUNT(DISTINCT TS.WorkDate) AS TotalWorkDays,
    SUM(TS.TotalWorkingHours) AS TotalHoursWorked,
    SUM(TS.OvertimeHours) AS TotalOvertimeHours,
    SUM(TS.NumberOfClasses) AS TotalClassesTaught,
    SUM(CASE WHEN TS.IsLate = 1 THEN 1 ELSE 0 END) AS TotalLateDays,
    SUM(CASE WHEN TS.IsEarlyLeave = 1 THEN 1 ELSE 0 END) AS TotalEarlyLeaveDays,
    COUNT(CASE WHEN TS.StatusID = (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Vắng mặt' AND StatusType = N'Timesheet') THEN 1 ELSE NULL END) AS TotalAbsentDays
FROM
    Timesheet TS
JOIN
    Staff S ON TS.StaffID = S.StaffID
GROUP BY
    TS.StaffID, S.FullName, S.ContractType, YEAR(TS.WorkDate), MONTH(TS.WorkDate);
GO


--------------------------------------------------------------------------------
-- 4. Hàm tự động (Functions)
--    Các hàm này được sử dụng để sinh các mã định danh hoặc giá trị tự động.
--------------------------------------------------------------------------------

-- Hàm dbo.GenerateStaffCode(): Sinh mã nhân viên theo định dạng NN68 + năm + 5 số thứ tự.
-- Ví dụ: NN68202500001
CREATE OR ALTER FUNCTION dbo.GenerateStaffCode()
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Year NVARCHAR(4) = CAST(YEAR(GETDATE()) AS NVARCHAR(4)); -- Lấy năm hiện tại
    DECLARE @Seq INT;

    -- Sử dụng MERGE để cập nhật hoặc thêm số thứ tự vào bảng StaffCodeSequence
    MERGE StaffCodeSequence AS T
    USING (VALUES (@Year)) AS S (CodeYear)
    ON T.CodeYear = S.CodeYear
    WHEN MATCHED THEN -- Nếu năm đã tồn tại, tăng số thứ tự lên 1
        UPDATE SET LastNumber = T.LastNumber + 1
    WHEN NOT MATCHED THEN -- Nếu năm chưa tồn tại, thêm mới với số thứ tự là 1
        INSERT (CodeYear, LastNumber) VALUES (@Year, 1);

    SELECT @Seq = LastNumber FROM StaffCodeSequence WHERE CodeYear = @Year; -- Lấy số thứ tự mới nhất
    RETURN 'NN68' + @Year + RIGHT('00000' + CAST(@Seq AS NVARCHAR), 5); -- Ghép chuỗi tạo mã
END;
GO

-- Hàm dbo.GenerateStudentCode(@MajorID INT): Sinh mã học viên theo định dạng NN68 + MajorCode + 5 số thứ tự.
-- Ví dụ: NN68ENGG00001
CREATE OR ALTER FUNCTION dbo.GenerateStudentCode(@MajorID INT)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @MajorCode NVARCHAR(20);
    SELECT @MajorCode = MajorCode FROM Major WHERE MajorID = @MajorID; -- Lấy mã chuyên ngành từ MajorID

    IF @MajorCode IS NULL
        RETURN NULL; -- Trả về NULL nếu MajorID không hợp lệ

    DECLARE @Seq INT;

    -- Sử dụng MERGE để cập nhật hoặc thêm số thứ tự vào bảng StudentCodeSequence
    MERGE StudentCodeSequence AS T
    USING (VALUES (@MajorCode)) AS S (MajorCode)
    ON T.MajorCode = S.MajorCode
    WHEN MATCHED THEN -- Nếu MajorCode đã tồn tại, tăng số thứ tự lên 1
        UPDATE SET LastNumber = T.LastNumber + 1
    WHEN NOT MATCHED THEN -- Nếu MajorCode chưa tồn tại, thêm mới với số thứ tự là 1
        INSERT (MajorCode, LastNumber) VALUES (@MajorCode, 1);

    SELECT @Seq = LastNumber FROM StudentCodeSequence WHERE MajorCode = @MajorCode; -- Lấy số thứ tự mới nhất
    RETURN 'NN68' + @MajorCode + RIGHT('00000' + CAST(@Seq AS NVARCHAR), 5); -- Ghép chuỗi tạo mã
END;
GO

-- Hàm dbo.GenerateClassCode(@BranchID INT, @MajorID INT): Sinh mã lớp học theo định dạng NN68 + BranchCode + MajorCode.
-- Ví dụ: NN68HN01ENGG (không có số thứ tự ở đây, chỉ là mã nhận diện)
CREATE OR ALTER FUNCTION dbo.GenerateClassCode(@BranchID INT, @MajorID INT)
RETURNS NVARCHAR(30)
AS
BEGIN
    DECLARE @BranchCode NVARCHAR(20);
    DECLARE @MajorCode NVARCHAR(20);

    SELECT @BranchCode = BranchCode FROM Branch WHERE BranchID = @BranchID;     -- Lấy mã chi nhánh
    SELECT @MajorCode = MajorCode FROM Major WHERE MajorID = @MajorID;     -- Lấy mã chuyên ngành

    IF @BranchCode IS NULL OR @MajorCode IS NULL
        RETURN NULL; -- Trả về NULL nếu BranchID hoặc MajorID không hợp lệ

    RETURN 'NN68' + @BranchCode + @MajorCode; -- Ghép chuỗi tạo mã lớp
END;
GO

-- Hàm dbo.GenerateStaffDisplayName(): Sinh tên hiển thị cho nhân viên.
-- Ví dụ: Nguyễn Văn A (NN68-HN01-HCNS)
CREATE OR ALTER FUNCTION dbo.GenerateStaffDisplayName(
    @FullName NVARCHAR(255),
    @BranchID INT,
    @DepartmentID INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @BranchCode NVARCHAR(20);
    DECLARE @DepartmentCode NVARCHAR(20);

    SELECT @BranchCode = BranchCode FROM Branch WHERE BranchID = @BranchID;     -- Lấy mã chi nhánh
    SELECT @DepartmentCode = DepartmentCode FROM Department WHERE DepartmentID = @DepartmentID; -- Lấy mã phòng ban

    RETURN @FullName + N' (NN68-' + ISNULL(@BranchCode, 'UnknownBranch') + N'-' + ISNULL(@DepartmentCode, 'UnknownDept') + N')';
END;
GO

-- Hàm dbo.GenerateRandomPassword(): Sinh mật khẩu ngẫu nhiên 8 ký tự (chữ hoa, chữ thường, số, ký tự đặc biệt)
CREATE OR ALTER FUNCTION dbo.GenerateRandomPassword()
RETURNS NVARCHAR(8)
AS
BEGIN
    DECLARE @Password NVARCHAR(8) = '';
    DECLARE @CharSetUpper NVARCHAR(26) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    DECLARE @CharSetLower NVARCHAR(26) = 'abcdefghijklmnopqrstuvwxyz';
    DECLARE @CharSetDigit NVARCHAR(10) = '0123456789';
    DECLARE @CharSetSpecial NVARCHAR(10) = '!@#$%^&*()';
    DECLARE @AllCharSet NVARCHAR(72) = @CharSetUpper + @CharSetLower + @CharSetDigit + @CharSetSpecial;
    DECLARE @i INT = 1;

    -- Đảm bảo có ít nhất 1 ký tự từ mỗi loại
    SET @Password = @Password + SUBSTRING(@CharSetUpper, CAST(RAND(CHECKSUM(NEWID())) * LEN(@CharSetUpper) + 1 AS INT), 1);
    SET @Password = @Password + SUBSTRING(@CharSetLower, CAST(RAND(CHECKSUM(NEWID())) * LEN(@CharSetLower) + 1 AS INT), 1);
    SET @Password = @Password + SUBSTRING(@CharSetDigit, CAST(RAND(CHECKSUM(NEWID())) * LEN(@CharSetDigit) + 1 AS INT), 1);
    SET @Password = @Password + SUBSTRING(@CharSetSpecial, CAST(RAND(CHECKSUM(NEWID())) * LEN(@CharSetSpecial) + 1 AS INT), 1);

    -- Thêm các ký tự còn lại cho đủ 8 ký tự
    WHILE @i <= 4
    BEGIN
        SET @Password = @Password + SUBSTRING(@AllCharSet, CAST(RAND(CHECKSUM(NEWID())) * LEN(@AllCharSet) + 1 AS INT), 1);
        SET @i = @i + 1;
    END;

    -- Đảo trộn các ký tự để tăng tính ngẫu nhiên
    -- Sử dụng một bảng tạm để đảo trộn hiệu quả hơn
    DECLARE @ShuffledPassword TABLE (ID INT IDENTITY(1,1), CharVal NCHAR(1));
    DECLARE @TempPassword NVARCHAR(8) = @Password;
    DECLARE @TempLen INT = LEN(@TempPassword);

    WHILE @TempLen > 0
    BEGIN
        DECLARE @RandomIndex INT = CAST(RAND(CHECKSUM(NEWID())) * @TempLen + 1 AS INT);
        INSERT INTO @ShuffledPassword (CharVal) VALUES (SUBSTRING(@TempPassword, @RandomIndex, 1));
        SET @TempPassword = STUFF(@TempPassword, @RandomIndex, 1, '');
        SET @TempLen = LEN(@TempPassword);
    END;

    SET @Password = (SELECT STRING_AGG(CharVal, '') FROM @ShuffledPassword);

    RETURN SUBSTRING(@Password, 1, 8); -- Đảm bảo chỉ 8 ký tự sau khi đảo trộn
END;
GO

--------------------------------------------------------------------------------
-- 5. Thủ tục (Stored Procedure)
--    Thủ tục này cung cấp một cách chung để cập nhật trạng thái của bất kỳ bảng nào,
--    và các thủ tục tìm kiếm, cập nhật dữ liệu.
--------------------------------------------------------------------------------

-- Thủ tục UpdateStatus: Cập nhật StatusID cho một bản ghi trong bất kỳ bảng nào.
-- Ví dụ: EXEC UpdateStatus 'Branch', 1, 2 (cập nhật chi nhánh có ID 1 sang StatusID 2)
CREATE PROCEDURE UpdateStatus
    @TableName NVARCHAR(128),  -- Tên bảng cần cập nhật (ví dụ: 'Branch', 'Staff')
    @RecordID INT,             -- ID của bản ghi cần cập nhật
    @NewStatusID INT           -- StatusID mới
AS
BEGIN
    SET NOCOUNT ON; -- Tắt thông báo số lượng hàng bị ảnh hưởng

    DECLARE @SQL NVARCHAR(MAX);
    -- Xây dựng câu lệnh SQL động để cập nhật trạng thái
    SET @SQL = N'UPDATE ' + QUOTENAME(@TableName) + N' SET StatusID = @NewStatusID WHERE ' + QUOTENAME(@TableName + 'ID') + N' = @RecordID;';
    
    -- Thực thi câu lệnh SQL động
    EXEC sp_executesql @SQL, N'@NewStatusID INT, @RecordID INT', @NewStatusID = @NewStatusID, @RecordID = @RecordID;
END;
GO

-- Thủ tục SP_SearchDataInTable: Tìm kiếm dữ liệu trong bất kỳ bảng nào theo một giá trị và trường cụ thể.
-- Lưu ý: Thủ tục này là cơ bản, để tìm kiếm phức tạp hơn cần truyền vào nhiều tham số hơn và logic phức tạp hơn.
-- Ví dụ: EXEC SP_SearchDataInTable 'Staff', 'FullName', N'Nguyễn Văn A'
-- Hoặc: EXEC SP_SearchDataInTable 'Student', 'Phone', '0912345678'
CREATE OR ALTER PROCEDURE SP_SearchDataInTable
    @TableName NVARCHAR(128),   -- Tên bảng cần tìm kiếm
    @ColumnName NVARCHAR(128),  -- Tên cột cần tìm kiếm (chỉ 1 cột cho đơn giản)
    @SearchValue NVARCHAR(4000) -- Giá trị cần tìm kiếm
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem bảng và cột có tồn tại không để tránh lỗi SQL Injection cơ bản
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = @TableName)
    BEGIN
        RAISERROR(N'Bảng ''%s'' không tồn tại.', 16, 1, @TableName);
        RETURN;
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(@TableName) AND name = @ColumnName)
    BEGIN
        RAISERROR(N'Cột ''%s'' không tồn tại trong bảng ''%s''.', 16, 1, @ColumnName, @TableName);
        RETURN;
    END

    DECLARE @SQL NVARCHAR(MAX);
    -- Tạo câu lệnh SELECT động. Sử dụng LIKE để tìm kiếm gần đúng và QUOTENAME để bảo vệ tên bảng/cột.
    -- CONCAT với '%' để tìm kiếm chuỗi con.
    SET @SQL = N'SELECT * FROM ' + QUOTENAME(@TableName) + N' WHERE ' + QUOTENAME(@ColumnName) + N' LIKE N''%' + REPLACE(@SearchValue, '''', '''''') + N'%''';

    EXEC sp_executesql @SQL;
END;
GO

-- Ví dụ về Stored Procedure để cập nhật dữ liệu của Staff (từ UI gọi).
-- Mỗi bảng/module sẽ có các SP cập nhật riêng theo nghiệp vụ.
-- Ví dụ: EXEC SP_UpdateStaffInfo 1, N'Nguyễn Văn B', 'Nam', '0987654321', 'b.nguyen@example.com', 1, 3, 1;
CREATE OR ALTER PROCEDURE SP_UpdateStaffInfo
    @StaffID INT,
    @FullName NVARCHAR(255) = NULL,
    @Gender NVARCHAR(10) = NULL,
    @Phone NVARCHAR(20) = NULL,
    @Email NVARCHAR(255) = NULL,
    @BranchID INT = NULL,
    @DepartmentID INT = NULL,
    @ContractType NVARCHAR(50) = NULL, -- Thêm tham số ContractType
    @BaseSalary DECIMAL(19,2) = NULL,   -- Thêm tham số Lương cơ bản
    @FixedDeductions DECIMAL(19,2) = NULL, -- Thêm tham số Khấu trừ cố định
    @StatusID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra sự tồn tại của StaffID
    IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @StaffID)
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với StaffID = %d.', 16, 1, @StaffID);
        RETURN;
    END

    -- Bắt đầu giao dịch để đảm bảo tính toàn vẹn
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Staff
        SET
            FullName = ISNULL(@FullName, FullName),
            Gender = ISNULL(@Gender, Gender),
            Phone = ISNULL(@Phone, Phone),
            Email = ISNULL(@Email, Email),
            BranchID = ISNULL(@BranchID, BranchID),
            DepartmentID = ISNULL(@DepartmentID, DepartmentID),
            ContractType = ISNULL(@ContractType, ContractType), -- Cập nhật ContractType
            BaseSalary = ISNULL(@BaseSalary, BaseSalary),       -- Cập nhật BaseSalary
            FixedDeductions = ISNULL(@FixedDeductions, FixedDeductions), -- Cập nhật FixedDeductions
            StatusID = ISNULL(@StatusID, StatusID),
            LastModified = GETDATE() -- Cập nhật thời gian chỉnh sửa
        WHERE StaffID = @StaffID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; -- Ném lại lỗi để ứng dụng bắt
    END CATCH
END;
GO

-- Thủ tục SP_RecordTimesheet: Ghi nhận chấm công hàng ngày cho nhân viên.
-- Tự động tính toán giờ làm, đi muộn, về sớm dựa trên loại hợp đồng.
-- Hợp đồng Full-time: 8h-17h (9 tiếng bao gồm 1 tiếng nghỉ trưa), làm 6 ngày/tuần
-- Hợp đồng Part-time: Chỉ ghi nhận giờ vào/ra, không tính giờ hành chính, chỉ tính ca dạy.
-- Ví dụ:
-- Chấm công Full-time vào đúng giờ: EXEC SP_RecordTimesheet N'NN68202500001', '2025-07-12', '08:00:00', '17:00:00', N'Đi làm bình thường';
-- Chấm công Full-time đi muộn: EXEC SP_RecordTimesheet N'NN68202500001', '2025-07-13', '08:15:00', '17:00:00', N'Đi muộn 15p';
-- Chấm công Part-time: EXEC SP_RecordTimesheet N'NN68202500002', '2025-07-12', '09:00:00', '12:00:00', N'Dạy ca sáng';
CREATE OR ALTER PROCEDURE SP_RecordTimesheet
    @StaffCode NVARCHAR(20),            -- Mã nhân viên thay vì ID
    @WorkDate DATE,                     -- Ngày chấm công
    @CheckInTime TIME = NULL,           -- Giờ vào
    @CheckOutTime TIME = NULL,          -- Giờ ra
    @Note NVARCHAR(255) = NULL,         -- Ghi chú (ví dụ: 'Nghỉ phép', 'Công tác')
    @StatusName NVARCHAR(100) = N'Đã duyệt' -- Trạng thái mặc định là "Đã duyệt"
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StaffID INT;
    DECLARE @ContractType NVARCHAR(50);
    DECLARE @StatusID INT;
    DECLARE @CurrentTimesheetID INT;

    -- Lấy StaffID và ContractType từ StaffCode
    SELECT @StaffID = StaffID, @ContractType = ContractType FROM Staff WHERE StaffCode = @StaffCode;

    IF @StaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
        RETURN;
    END

    -- Lấy StatusID từ GeneralStatus
    SELECT @StatusID = StatusID FROM GeneralStatus WHERE StatusName = @StatusName AND StatusType = N'Timesheet';

    IF @StatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái chấm công không hợp lệ: %s. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1, @StatusName);
        RETURN;
    END

    -- Kiểm tra xem đã có bản ghi chấm công cho ngày này chưa
    SELECT @CurrentTimesheetID = TimesheetID
    FROM Timesheet
    WHERE StaffID = @StaffID AND WorkDate = @WorkDate;

    -- Nếu đã có bản ghi, cập nhật
    IF @CurrentTimesheetID IS NOT NULL
    BEGIN
        UPDATE Timesheet
        SET
            CheckInTime = ISNULL(@CheckInTime, CheckInTime),
            CheckOutTime = ISNULL(@CheckOutTime, CheckOutTime),
            Note = ISNULL(@Note, Note),
            StatusID = @StatusID
        WHERE TimesheetID = @CurrentTimesheetID;
    END
    ELSE -- Nếu chưa có, thêm mới
    BEGIN
        INSERT INTO Timesheet (StaffID, WorkDate, CheckInTime, CheckOutTime, Note, StatusID)
        VALUES (@StaffID, @WorkDate, @CheckInTime, @CheckOutTime, @Note, @StatusID);

        SELECT @CurrentTimesheetID = SCOPE_IDENTITY(); -- Lấy ID của bản ghi vừa thêm
    END

    -- Gọi SP để tính số ca dạy. Logic tính toán giờ làm sẽ được xử lý bởi Trigger.
    EXEC SP_CalculateClassesTaught @TimesheetID = @CurrentTimesheetID;

    PRINT N'Ghi nhận chấm công thành công cho StaffCode ' + @StaffCode + N' ngày ' + CAST(@WorkDate AS NVARCHAR(10));
END;
GO

-- Thủ tục SP_CalculateClassesTaught: Tính số ca dạy của giáo viên trong một ngày cụ thể.
-- Có thể được gọi bởi SP_RecordTimesheet hoặc tự chạy định kỳ.
-- Ví dụ: EXEC SP_CalculateClassesTaught @TimesheetID = 5; -- Tính cho TimesheetID 5 (được gọi từ SP_RecordTimesheet)
-- Hoặc: EXEC SP_CalculateClassesTaught @StaffCode = N'NN68202500001', @WorkDate = '2025-07-12'; -- Tính lại cho StaffCode, ngày cụ thể
CREATE OR ALTER PROCEDURE SP_CalculateClassesTaught
    @TimesheetID INT = NULL,            -- Nếu truyền vào TimesheetID, sẽ cập nhật đúng bản ghi đó
    @StaffCode NVARCHAR(20) = NULL,     -- Mã nhân viên (dùng khi TimesheetID là NULL)
    @WorkDate DATE = NULL               -- Ngày làm việc (dùng khi TimesheetID là NULL)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetStaffID INT;
    DECLARE @TargetWorkDate DATE;

    -- Xác định StaffID và WorkDate từ TimesheetID hoặc từ tham số StaffCode/WorkDate
    IF @TimesheetID IS NOT NULL
    BEGIN
        SELECT @TargetStaffID = StaffID, @TargetWorkDate = WorkDate
        FROM Timesheet
        WHERE TimesheetID = @TimesheetID;
    END
    ELSE IF @StaffCode IS NOT NULL AND @WorkDate IS NOT NULL
    BEGIN
        SELECT @TargetStaffID = StaffID FROM Staff WHERE StaffCode = @StaffCode;
        SET @TargetWorkDate = @WorkDate;
        
        IF @TargetStaffID IS NULL
        BEGIN
            RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
            RETURN;
        END
    END
    ELSE
    BEGIN
        RAISERROR(N'Vui lòng cung cấp TimesheetID hoặc cả StaffCode và WorkDate.', 16, 1);
        RETURN;
    END

    -- Kiểm tra xem nhân viên có phải là giáo viên chính hoặc trợ giảng không
    IF NOT EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @TargetStaffID AND R.RoleName IN (N'Giáo viên', N'Trợ giảng'))
    BEGIN
        -- Nếu không phải giáo viên/trợ giảng, số ca dạy luôn là 0
        UPDATE Timesheet
        SET NumberOfClasses = 0
        WHERE StaffID = @TargetStaffID AND WorkDate = @TargetWorkDate;
        RETURN;
    END

    -- Tính số ca dạy mà giáo viên này phụ trách trong ngày đó
    DECLARE @ClassesTaught INT;
    SELECT @ClassesTaught = COUNT(DISTINCT CS.ClassID)
    FROM ClassSchedule CS
    JOIN Class C ON CS.ClassID = C.ClassID
    WHERE CS.StudyDate = @TargetWorkDate
      AND (C.MainTeacherID = @TargetStaffID OR C.AssistantID = @TargetStaffID);

    -- Cập nhật số ca dạy vào bảng Timesheet
    UPDATE Timesheet
    SET NumberOfClasses = ISNULL(@ClassesTaught, 0)
    WHERE StaffID = @TargetStaffID AND WorkDate = @TargetWorkDate;

    -- PRINT N'Đã cập nhật số ca dạy cho StaffCode ' + (SELECT StaffCode FROM Staff WHERE StaffID = @TargetStaffID) + N' ngày ' + CAST(@TargetWorkDate AS NVARCHAR(10)) + N': ' + CAST(ISNULL(@ClassesTaught, 0) AS NVARCHAR(10));
END;
GO

-- Thủ tục SP_CalculateHRKPI: Tính KPI cho nhân viên HR (tuyển sinh) dựa trên tổng học phí cơ bản từ học viên họ tư vấn.
-- Ví dụ: EXEC SP_CalculateHRKPI N'NN68202500003', '2025-07-01', 100000000; -- Tính KPI cho HR staff trong tháng 7 với mục tiêu 100 triệu
CREATE OR ALTER PROCEDURE SP_CalculateHRKPI
    @StaffCode NVARCHAR(20),            -- Mã nhân viên HR (tuyển sinh)
    @KPIMonth DATE,                     -- Tháng tính KPI (ví dụ: 'YYYY-MM-01')
    @TargetValue DECIMAL(19,2) = NULL   -- Giá trị mục tiêu (tùy chọn)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StaffID INT;
    DECLARE @DepartmentID INT;
    DECLARE @CalculatedKPIValue DECIMAL(19,2);
    DECLARE @AchievedPercentage DECIMAL(5,2) = NULL;

    -- Lấy StaffID và DepartmentID của nhân viên HR
    SELECT @StaffID = StaffID, @DepartmentID = DepartmentID
    FROM Staff
    WHERE StaffCode = @StaffCode;

    IF @StaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
        RETURN;
    END

    -- Kiểm tra xem nhân viên có thuộc phòng ban HR (tuyển sinh) không
    IF NOT EXISTS (SELECT 1 FROM Department WHERE DepartmentID = @DepartmentID AND DepartmentName LIKE N'%Nhân sự%')
    BEGIN
        RAISERROR(N'Nhân viên này không thuộc phòng ban Nhân sự (Tuyển sinh).', 16, 1);
        RETURN;
    END

    -- Tính tổng học phí cơ bản từ các học viên mà nhân viên này đã tư vấn/tuyển sinh thành công trong tháng
    SELECT @CalculatedKPIValue = SUM(M.BaseTuitionFee)
    FROM Student S
    JOIN Registration R ON S.StudentID = R.StudentID
    JOIN Class C ON R.ClassID = C.ClassID
    JOIN Major M ON C.MajorID = M.MajorID
    WHERE S.ConsultantStaffID = @StaffID
      AND R.RegistrationDate >= @KPIMonth
      AND R.RegistrationDate < DATEADD(month, 1, @KPIMonth)
      AND R.StatusID = (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Đã đăng ký' AND StatusType = N'Registration'); -- Giả định trạng thái 'Đã đăng ký' là thành công

    SET @CalculatedKPIValue = ISNULL(@CalculatedKPIValue, 0);

    -- Tính phần trăm đạt được mục tiêu
    IF @TargetValue IS NOT NULL AND @TargetValue <> 0
    BEGIN
        SET @AchievedPercentage = (@CalculatedKPIValue / @TargetValue) * 100.0;
    END

    -- Lưu hoặc cập nhật KPI vào bảng DepartmentKPI
    MERGE DepartmentKPI AS T
    USING (VALUES (@StaffID, @DepartmentID, @KPIMonth, N'HR_TotalTuitionRevenue', @CalculatedKPIValue, @TargetValue, @AchievedPercentage))
           AS S (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
    ON T.StaffID = S.StaffID AND T.KPIMonth = S.KPIMonth AND T.KPIType = S.KPIType
    WHEN MATCHED THEN
        UPDATE SET KPIValue = S.KPIValue, TargetValue = S.TargetValue, AchievedPercentage = S.AchievedPercentage, CalculatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
        VALUES (S.StaffID, S.DepartmentID, S.KPIMonth, S.KPIType, S.KPIValue, S.TargetValue, S.AchievedPercentage);

    PRINT N'Đã tính KPI cho nhân viên HR (Tuyển sinh) ' + @StaffCode + N' tháng ' + FORMAT(@KPIMonth, 'MM/yyyy') + N'. Tổng học phí: ' + CAST(@CalculatedKPIValue AS NVARCHAR(50));
END;
GO

-- Thủ tục SP_CalculateTeacherKPI_Fulltime: Tính KPI cho giáo viên/trợ giảng Full-time (tỷ lệ chuyên cần của lớp).
-- Ví dụ: EXEC SP_CalculateTeacherKPI_Fulltime N'NN68202500004', '2025-07-01', 90.0; -- Mục tiêu 90% chuyên cần
CREATE OR ALTER PROCEDURE SP_CalculateTeacherKPI_Fulltime
    @StaffCode NVARCHAR(20),            -- Mã nhân viên giáo viên/trợ giảng
    @KPIMonth DATE,                     -- Tháng tính KPI
    @TargetValue DECIMAL(5,2) = NULL    -- Tỷ lệ chuyên cần mục tiêu (ví dụ: 90.0)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StaffID INT;
    DECLARE @CalculatedKPIValue DECIMAL(5,2); -- Tỷ lệ chuyên cần
    DECLARE @AchievedPercentage DECIMAL(5,2) = NULL;

    SELECT @StaffID = StaffID FROM Staff WHERE StaffCode = @StaffCode;

    IF @StaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
        RETURN;
    END

    -- Kiểm tra xem nhân viên có vai trò giáo viên/trợ giảng full-time không
    IF NOT EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @StaffID AND R.RoleName IN (N'Giáo viên', N'Trợ giảng'))
    BEGIN
        RAISERROR(N'Nhân viên này không phải giáo viên hoặc trợ giảng.', 16, 1);
        RETURN;
    END

    IF (SELECT ContractType FROM Staff WHERE StaffID = @StaffID) <> N'Full-time'
    BEGIN
        RAISERROR(N'Nhân viên này không phải hợp đồng Full-time.', 16, 1);
        RETURN;
    END

    -- Tính tổng số buổi học và số buổi có mặt cho các lớp mà giáo viên này phụ trách trong tháng
    SELECT
        @CalculatedKPIValue =
            (SUM(CASE WHEN A.AttendanceStatus = 'Present' THEN 1 ELSE 0 END) * 100.0) / NULLIF(COUNT(CS.ScheduleID), 0)
    FROM
        Class C
    JOIN
        ClassSchedule CS ON C.ClassID = CS.ClassID
    JOIN
        Attendance A ON CS.ScheduleID = A.ScheduleID
    WHERE
        (C.MainTeacherID = @StaffID OR C.AssistantID = @StaffID)
        AND CS.StudyDate >= @KPIMonth
        AND CS.StudyDate < DATEADD(month, 1, @KPIMonth);

    SET @CalculatedKPIValue = ISNULL(@CalculatedKPIValue, 0);

    -- Tính phần trăm đạt được mục tiêu
    IF @TargetValue IS NOT NULL AND @TargetValue <> 0
    BEGIN
        SET @AchievedPercentage = (@CalculatedKPIValue / @TargetValue) * 100.0;
    END

    -- Lưu hoặc cập nhật KPI
    MERGE DepartmentKPI AS T
    USING (VALUES (@StaffID, NULL, @KPIMonth, N'Teacher_FulltimeAttendanceRate', @CalculatedKPIValue, @TargetValue, @AchievedPercentage))
           AS S (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
    ON T.StaffID = S.StaffID AND T.KPIMonth = S.KPIMonth AND T.KPIType = S.KPIType
    WHEN MATCHED THEN
        UPDATE SET KPIValue = S.KPIValue, TargetValue = S.TargetValue, AchievedPercentage = S.AchievedPercentage, CalculatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
        VALUES (S.StaffID, S.DepartmentID, S.KPIMonth, S.KPIType, S.KPIValue, S.TargetValue, S.AchievedPercentage);

    PRINT N'Đã tính KPI chuyên cần cho giáo viên Full-time ' + @StaffCode + N' tháng ' + FORMAT(@KPIMonth, 'MM/yyyy') + N'. Tỷ lệ: ' + CAST(@CalculatedKPIValue AS NVARCHAR(50)) + N'%';
END;
GO

-- Thủ tục SP_CalculateTeacherKPI_Parttime: Tính KPI cho giáo viên/trợ giảng Part-time (số ngày lớp có sĩ số > 15).
-- Ví dụ: EXEC SP_CalculateTeacherKPI_Parttime N'NN68202500005', '2025-07-01', 15; -- Mục tiêu 15 ngày lớp đông
CREATE OR ALTER PROCEDURE SP_CalculateTeacherKPI_Parttime
    @StaffCode NVARCHAR(20),            -- Mã nhân viên giáo viên/trợ giảng
    @KPIMonth DATE,                     -- Tháng tính KPI
    @TargetValue DECIMAL(19,2) = NULL   -- Số ngày lớp đông mục tiêu
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StaffID INT;
    DECLARE @CalculatedKPIValue DECIMAL(19,2); -- Số ngày lớp có sĩ số > 15
    DECLARE @AchievedPercentage DECIMAL(5,2) = NULL;

    SELECT @StaffID = StaffID FROM Staff WHERE StaffCode = @StaffCode;

    IF @StaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
        RETURN;
    END

    -- Kiểm tra xem nhân viên có vai trò giáo viên/trợ giảng part-time không
    IF NOT EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @StaffID AND R.RoleName IN (N'Giáo viên', N'Trợ giảng'))
    BEGIN
        RAISERROR(N'Nhân viên này không phải giáo viên hoặc trợ giảng.', 16, 1);
        RETURN;
    END

    IF (SELECT ContractType FROM Staff WHERE StaffID = @StaffID) <> N'Part-time'
    BEGIN
        RAISERROR(N'Nhân viên này không phải hợp đồng Part-time.', 16, 1);
        RETURN;
    END

    -- Tính số ngày mà lớp có sĩ số đi học trên 15 người
    SELECT @CalculatedKPIValue = COUNT(DISTINCT StudyDate)
    FROM (
        SELECT
            CS.StudyDate,
            COUNT(CASE WHEN A.AttendanceStatus = 'Present' THEN A.StudentID ELSE NULL END) AS PresentStudents
        FROM
            Class C
        JOIN
            ClassSchedule CS ON C.ClassID = CS.ClassID
        LEFT JOIN
            Attendance A ON CS.ScheduleID = A.ScheduleID
        WHERE
            (C.MainTeacherID = @StaffID OR C.AssistantID = @StaffID)
            AND CS.StudyDate >= @KPIMonth
            AND CS.StudyDate < DATEADD(month, 1, @KPIMonth)
        GROUP BY
            CS.StudyDate, CS.ClassID -- Group by ClassID as well to count for each class
        HAVING
            COUNT(CASE WHEN A.AttendanceStatus = 'Present' THEN A.StudentID ELSE NULL END) > 15
    ) AS HighAttendanceDays;

    SET @CalculatedKPIValue = ISNULL(@CalculatedKPIValue, 0);

    -- Tính phần trăm đạt được mục tiêu
    IF @TargetValue IS NOT NULL AND @TargetValue <> 0
    BEGIN
        SET @AchievedPercentage = (@CalculatedKPIValue / @TargetValue) * 100.0;
    END

    -- Lưu hoặc cập nhật KPI
    MERGE DepartmentKPI AS T
    USING (VALUES (@StaffID, NULL, @KPIMonth, N'Teacher_ParttimeHighAttendanceDays', @CalculatedKPIValue, @TargetValue, @AchievedPercentage))
           AS S (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
    ON T.StaffID = S.StaffID AND T.KPIMonth = S.KPIMonth AND T.KPIType = S.KPIType
    WHEN MATCHED THEN
        UPDATE SET KPIValue = S.KPIValue, TargetValue = S.TargetValue, AchievedPercentage = S.AchievedPercentage, CalculatedDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (StaffID, DepartmentID, KPIMonth, KPIType, KPIValue, TargetValue, AchievedPercentage)
        VALUES (S.StaffID, S.DepartmentID, S.KPIMonth, S.KPIType, S.KPIValue, S.TargetValue, S.AchievedPercentage);

    PRINT N'Đã tính KPI lớp đông cho giáo viên Part-time ' + @StaffCode + N' tháng ' + FORMAT(@KPIMonth, 'MM/yyyy') + N'. Số ngày: ' + CAST(@CalculatedKPIValue AS NVARCHAR(50));
END;
GO

-- Thủ tục SP_CalculateAndSendSalarySlip: Tính toán bảng lương và gửi email cho từng nhân viên.
-- Ví dụ: EXEC SP_CalculateAndSendSalarySlip N'NN68202500001', '2025-07-01', 'HHMS_Mail_Profile';
CREATE OR ALTER PROCEDURE SP_CalculateAndSendSalarySlip
    @StaffCode NVARCHAR(20),            -- Mã nhân viên
    @SalaryMonth DATE,                  -- Tháng tính lương (ví dụ: 'YYYY-MM-01')
    @MailProfileName NVARCHAR(128)      -- Tên Profile Database Mail đã cấu hình
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StaffID INT;
    DECLARE @FullName NVARCHAR(255);
    DECLARE @Email NVARCHAR(255);
    DECLARE @ContractType NVARCHAR(50);
    DECLARE @BaseSalary DECIMAL(19,2);
    DECLARE @FixedDeductions DECIMAL(19,2);
    DECLARE @TotalWorkDays DECIMAL(5,2);
    DECLARE @TotalClassesTaught INT;
    DECLARE @KPIBonus DECIMAL(19,2) = 0;
    DECLARE @OtherEarnings DECIMAL(19,2) = 0; -- Có thể thêm logic để tính toán các khoản này
    DECLARE @OtherDeductions DECIMAL(19,2) = 0; -- Có thể thêm logic để tính toán các khoản này
    DECLARE @GrossIncome DECIMAL(19,2);
    DECLARE @NetIncome DECIMAL(19,2);
    DECLARE @SalarySlipStatusID INT;
    DECLARE @EmailBody NVARCHAR(MAX);
    DECLARE @EmailSubject NVARCHAR(255);

    -- Lấy thông tin nhân viên
    SELECT
        @StaffID = S.StaffID,
        @FullName = S.FullName,
        @Email = S.Email,
        @ContractType = S.ContractType,
        @BaseSalary = S.BaseSalary,
        @FixedDeductions = S.FixedDeductions
    FROM Staff S
    WHERE S.StaffCode = @StaffCode;

    IF @StaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @StaffCode);
        RETURN;
    END

    IF @Email IS NULL OR @Email = ''
    BEGIN
        PRINT N'Không có địa chỉ email cho nhân viên ' + @FullName + N'. Bảng lương không thể gửi.';
        RETURN;
    END

    -- Lấy tổng hợp ngày công và ca dạy từ vw_StaffTimesheetSummary
    SELECT
        @TotalWorkDays = TotalWorkDays,
        @TotalClassesTaught = TotalClassesTaught
    FROM vw_StaffTimesheetSummary
    WHERE StaffID = @StaffID
      AND WorkYear = YEAR(@SalaryMonth)
      AND WorkMonth = MONTH(@SalaryMonth);

    SET @TotalWorkDays = ISNULL(@TotalWorkDays, 0);
    SET @TotalClassesTaught = ISNULL(@TotalClassesTaught, 0);

    -- Lấy thông tin KPI và tính thưởng KPI (nếu có)
    -- Giả định thưởng KPI là 10% của KPIValue nếu đạt từ 100% mục tiêu trở lên
    DECLARE @KPIValue DECIMAL(19,2);
    DECLARE @AchievedPercentage DECIMAL(5,2);
    DECLARE @KPIType NVARCHAR(100);

    SELECT TOP 1 -- Lấy KPI phù hợp nhất cho nhân viên này
        @KPIValue = KPIValue,
        @AchievedPercentage = AchievedPercentage,
        @KPIType = KPIType
    FROM DepartmentKPI
    WHERE StaffID = @StaffID
      AND KPIMonth = @SalaryMonth
    ORDER BY KPIType; -- Hoặc một thứ tự ưu tiên khác nếu có nhiều loại KPI

    IF @AchievedPercentage >= 100.0 -- Nếu đạt hoặc vượt mục tiêu
    BEGIN
        -- Tùy chỉnh logic thưởng KPI theo từng loại KPI hoặc theo quy định công ty
        IF @KPIType = N'HR_TotalTuitionRevenue'
        BEGIN
            -- KPI HR: Thưởng 5% trên tổng học phí tuyển sinh nếu đạt mục tiêu
            SET @KPIBonus = @KPIValue * 0.05;
        END
        ELSE IF @KPIType = N'Teacher_FulltimeAttendanceRate'
        BEGIN
            -- KPI Giáo viên Full-time: Thưởng 10% của BaseSalary nếu đạt chuyên cần 100%, giảm dần nếu thấp hơn
            SET @KPIBonus = @BaseSalary * 0.10 * (@AchievedPercentage / 100.0);
        END
        ELSE IF @KPIType = N'Teacher_ParttimeHighAttendanceDays'
        BEGIN
            -- KPI Giáo viên Part-time: Thưởng cố định cho mỗi ngày lớp đông vượt mục tiêu
            -- Giả định mục tiêu là 15 ngày, thưởng 500,000 VNĐ cho mỗi ngày vượt
            DECLARE @TargetDays INT = 15;
            IF @KPIValue > @TargetDays
                SET @KPIBonus = (@KPIValue - @TargetDays) * 500000;
            ELSE
                SET @KPIBonus = 0;
        END
    END
    ELSE
    BEGIN
        SET @KPIBonus = 0; -- Không thưởng nếu không đạt mục tiêu
    END;

    SET @KPIBonus = ISNULL(@KPIBonus, 0);

    -- Tính tổng thu nhập và thu nhập thực lĩnh
    SET @GrossIncome = @BaseSalary + @KPIBonus + @OtherEarnings;
    SET @NetIncome = @GrossIncome - @FixedDeductions - @OtherDeductions;

    -- Lấy StatusID cho SalarySlip
    SELECT @SalarySlipStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đã gửi' AND StatusType = N'SalarySlip';
    IF @SalarySlipStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái SalarySlip không hợp lệ. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    -- Lưu bảng lương vào bảng SalarySlip
    MERGE SalarySlip AS T
    USING (VALUES (@StaffID, @SalaryMonth, @TotalWorkDays, @TotalClassesTaught, @BaseSalary, @KPIBonus, @OtherEarnings, @FixedDeductions, @OtherDeductions, @GrossIncome, @NetIncome, GETDATE(), @SalarySlipStatusID))
           AS S (StaffID, SalaryMonth, TotalWorkDays, TotalClassesTaught, BaseSalary, KPIBonus, OtherEarnings, FixedDeductions, OtherDeductions, GrossIncome, NetIncome, CalculatedDate, StatusID)
    ON T.StaffID = S.StaffID AND T.SalaryMonth = S.SalaryMonth
    WHEN MATCHED THEN
        UPDATE SET
            TotalWorkDays = S.TotalWorkDays,
            TotalClassesTaught = S.TotalClassesTaught,
            BaseSalary = S.BaseSalary,
            KPIBonus = S.KPIBonus,
            OtherEarnings = S.OtherEarnings,
            FixedDeductions = S.FixedDeductions,
            OtherDeductions = S.OtherDeductions,
            GrossIncome = S.GrossIncome,
            NetIncome = S.NetIncome,
            CalculatedDate = S.CalculatedDate,
            StatusID = S.StatusID,
            EmailSentDate = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (StaffID, SalaryMonth, TotalWorkDays, TotalClassesTaught, BaseSalary, KPIBonus, OtherEarnings, FixedDeductions, OtherDeductions, GrossIncome, NetIncome, CalculatedDate, StatusID, EmailSentDate)
        VALUES (S.StaffID, S.SalaryMonth, S.TotalWorkDays, S.TotalClassesTaught, S.BaseSalary, S.KPIBonus, S.OtherEarnings, S.FixedDeductions, S.OtherDeductions, S.GrossIncome, S.NetIncome, S.CalculatedDate, S.StatusID, GETDATE());

    -- Chuẩn bị nội dung email HTML
    SET @EmailSubject = N'Bảng lương tháng ' + FORMAT(@SalaryMonth, 'MM/yyyy') + N' - ' + @FullName;
    SET @EmailBody = N'
    <html>
    <head>
        <style>
            body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; color: #333; }
            .container { width: 100%; max-width: 700px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
            h2 { color: #0A2463; border-bottom: 2px solid #3E8989; padding-bottom: 10px; margin-bottom: 20px; }
            table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
            th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
            th { background-color: #f2f2f2; color: #0A2463; }
            .total-row td { font-weight: bold; background-color: #e0e0e0; }
            .net-income-row td { font-weight: bold; background-color: #FFC43D; color: #0A2463; font-size: 16px; }
            .note { margin-top: 20px; font-style: italic; color: #666; }
            .footer { margin-top: 30px; padding-top: 15px; border-top: 1px solid #eee; text-align: center; font-size: 12px; color: #999; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2>Bảng Lương Chi Tiết Tháng ' + FORMAT(@SalaryMonth, 'MM/yyyy') + N'</h2>
            <p>Kính gửi: <strong>' + @FullName + N'</strong></p>
            <p>Mã nhân viên: <strong>' + @StaffCode + N'</strong></p>
            <p>Loại hợp đồng: <strong>' + @ContractType + N'</strong></p>
            <p>Ngày tính lương: <strong>' + FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm') + N'</strong></p>
            <br>
            <table>
                <thead>
                    <tr>
                        <th>Khoản mục</th>
                        <th>Chi tiết</th>
                        <th>Số tiền (VNĐ)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>Lương cơ bản</td>
                        <td></td>
                        <td>' + FORMAT(@BaseSalary, '#,##0') + N'</td>
                    </tr>';
    
    IF @ContractType = N'Full-time'
    BEGIN
        SET @EmailBody = @EmailBody + N'
                    <tr>
                        <td>Tổng ngày công</td>
                        <td>' + CAST(@TotalWorkDays AS NVARCHAR(10)) + N' ngày</td>
                        <td></td>
                    </tr>';
    END;

    IF @TotalClassesTaught > 0
    BEGIN
        SET @EmailBody = @EmailBody + N'
                    <tr>
                        <td>Tổng số ca dạy</td>
                        <td>' + CAST(@TotalClassesTaught AS NVARCHAR(10)) + N' ca</td>
                        <td></td>
                    </tr>';
    END;

    SET @EmailBody = @EmailBody + N'
                    <tr>
                        <td>Thưởng KPI</td>
                        <td>' + CASE WHEN @KPIBonus > 0 THEN N'Đạt mục tiêu' ELSE N'Không đạt mục tiêu' END + N'</td>
                        <td>' + FORMAT(@KPIBonus, '#,##0') + N'</td>
                    </tr>
                    <tr>
                        <td>Các khoản thu nhập khác</td>
                        <td></td>
                        <td>' + FORMAT(@OtherEarnings, '#,##0') + N'</td>
                    </tr>
                    <tr class="total-row">
                        <td colspan="2">Tổng thu nhập (Gross Income)</td>
                        <td>' + FORMAT(@GrossIncome, '#,##0') + N'</td>
                    </tr>
                    <tr>
                        <td>Khấu trừ cố định</td>
                        <td></td>
                        <td>-' + FORMAT(@FixedDeductions, '#,##0') + N'</td>
                    </tr>
                    <tr>
                        <td>Các khoản khấu trừ khác</td>
                        <td></td>
                        <td>-' + FORMAT(@OtherDeductions, '#,##0') + N'</td>
                    </tr>
                    <tr class="net-income-row">
                        <td colspan="2">THU NHẬP THỰC LĨNH</td>
                        <td>' + FORMAT(@NetIncome, '#,##0') + N'</td>
                    </tr>
                </tbody>
            </table>
            <p class="note"><i>Lưu ý: Đây là bảng lương chi tiết mang tính chất tham khảo. Mọi thắc mắc vui lòng liên hệ phòng Nhân sự.</i></p>
            <div class="footer">
                <p>&copy; ' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)) + N' HHMS Ngoaingu68. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>';

    -- Gửi email
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = @MailProfileName, -- Tên profile Database Mail của bạn
        @recipients = @Email,
        @subject = @EmailSubject,
        @body = @EmailBody,
        @body_format = 'HTML';

    PRINT N'Bảng lương tháng ' + FORMAT(@SalaryMonth, 'MM/yyyy') + N' cho nhân viên ' + @FullName + N' đã được gửi thành công đến ' + @Email + N'.';

END;
GO

-- Thủ tục SP_CreateStaffAccount: Tạo tài khoản đăng nhập cho nhân viên mới và gửi email chào mừng.
-- Được gọi tự động từ SP_ApproveRequest khi yêu cầu thêm nhân viên được phê duyệt.
-- Ví dụ: EXEC SP_CreateStaffAccount @StaffID = 1, @StaffEmail = 'test@example.com', @MailProfileName = 'HHMS_Mail_Profile';
CREATE OR ALTER PROCEDURE SP_CreateStaffAccount
    @StaffID INT,
    @StaffEmail NVARCHAR(255),
    @MailProfileName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Username NVARCHAR(100);
    DECLARE @GeneratedPassword NVARCHAR(8);
    DECLARE @PasswordHash NVARCHAR(255);
    DECLARE @DisplayName NVARCHAR(100);
    DECLARE @AccountStatusID INT;

    -- Lấy phần đầu email làm tên đăng nhập
    SET @Username = LEFT(@StaffEmail, CHARINDEX('@', @StaffEmail) - 1);

    -- Lấy DisplayName của nhân viên
    SELECT @DisplayName = FullName FROM Staff WHERE StaffID = @StaffID;

    -- Sinh mật khẩu ngẫu nhiên
    SET @GeneratedPassword = dbo.GenerateRandomPassword();
    SET @PasswordHash = HASHBYTES('SHA2_256', @GeneratedPassword);

    -- Lấy StatusID cho tài khoản (ví dụ: 'Hoạt động')
    SELECT @AccountStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Account';

    IF @AccountStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái tài khoản không hợp lệ. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    -- Chèn hoặc cập nhật tài khoản
    MERGE Account AS T
    USING (VALUES (@StaffID, @Username, @PasswordHash, @StaffEmail, @DisplayName, @AccountStatusID, GETDATE(), 1))
           AS S (StaffID, Username, PasswordHash, Email, DisplayName, StatusID, CreatedAt, FirstLoginChangePwd)
    ON T.StaffID = S.StaffID
    WHEN MATCHED THEN
        UPDATE SET
            Username = S.Username,
            PasswordHash = S.PasswordHash,
            Email = S.Email,
            DisplayName = S.DisplayName,
            StatusID = S.StatusID,
            UpdatedAt = GETDATE(),
            FirstLoginChangePwd = S.FirstLoginChangePwd,
            WrongLoginCount = 0 -- Reset nếu tài khoản đã tồn tại và được cập nhật
    WHEN NOT MATCHED THEN
        INSERT (StaffID, Username, PasswordHash, Email, DisplayName, StatusID, CreatedAt, FirstLoginChangePwd)
        VALUES (S.StaffID, S.Username, S.PasswordHash, S.Email, S.DisplayName, S.StatusID, S.CreatedAt, S.FirstLoginChangePwd);

    -- Chuẩn bị và gửi email chào mừng
    DECLARE @EmailSubject NVARCHAR(255) = N'Chào mừng bạn đến với Hệ thống HHMS Ngoaingu68 - Thông tin đăng nhập của bạn';
    DECLARE @EmailBody NVARCHAR(MAX) = N'
    <html>
    <head>
        <style>
            body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; color: #333; }
            .container { width: 100%; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
            h2 { color: #0A2463; border-bottom: 2px solid #3E8989; padding-bottom: 10px; margin-bottom: 20px; }
            p { margin-bottom: 10px; }
            .highlight { background-color: #f0f8ff; padding: 10px; border-left: 4px solid #3E8989; margin-bottom: 15px; }
            .important { font-weight: bold; color: #D8315B; }
            .footer { margin-top: 30px; padding-top: 15px; border-top: 1px solid #eee; text-align: center; font-size: 12px; color: #999; }
        </style>
    </head>
    <body>
        <div class="container">
            <h2>Chào mừng bạn đến với Hệ thống HHMS Ngoaingu68!</h2>
            <p>Kính gửi <strong>' + @DisplayName + N'</strong>,</p>
            <p>Chúng tôi rất vui mừng chào đón bạn gia nhập đội ngũ của HHMS Ngoaingu68.</p>
            <p>Dưới đây là thông tin đăng nhập của bạn:</p>
            <div class="highlight">
                <p>Tên đăng nhập: <strong style="color: #0A2463;">' + @Username + N'</strong></p>
                <p>Mật khẩu tạm thời: <strong style="color: #0A2463;">' + @GeneratedPassword + N'</strong></p>
            </div>
            <p class="important">Lưu ý quan trọng:</p>
            <p>Vì lý do bảo mật, bạn sẽ được yêu cầu đổi mật khẩu ngay trong lần đăng nhập đầu tiên.</p>
            <p>Vui lòng truy cập hệ thống tại: [Địa chỉ liên kết hệ thống của bạn]</p>
            <p>Nếu có bất kỳ thắc mắc nào, vui lòng liên hệ phòng Nhân sự.</p>
            <div class="footer">
                <p>&copy; ' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)) + N' HHMS Ngoaingu68. All rights reserved.</p>
            </div>
        </div>
    </body>
    </html>';

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = @MailProfileName,
        @recipients = @StaffEmail,
        @subject = @EmailSubject,
        @body = @EmailBody,
        @body_format = 'HTML';

    PRINT N'Tài khoản đã được tạo và thông tin đăng nhập đã gửi đến ' + @StaffEmail + N'.';
END;
GO

-- Thủ tục SP_ChangePassword: Thay đổi mật khẩu cho tài khoản.
-- Sẽ được gọi khi nhân viên đổi mật khẩu lần đầu hoặc bất kỳ lúc nào.
-- Ví dụ: EXEC SP_ChangePassword N'john.doe', 'OldPass123!', 'NewPass456#';
CREATE OR ALTER PROCEDURE SP_ChangePassword
    @Username NVARCHAR(100),
    @OldPassword NVARCHAR(255) = NULL, -- NULL nếu là lần đầu đổi mật khẩu (không cần mật khẩu cũ)
    @NewPassword NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AccountID INT;
    DECLARE @CurrentPasswordHash NVARCHAR(255);
    DECLARE @NewPasswordHash NVARCHAR(255);
    DECLARE @FirstLoginChange BIT;

    -- Lấy thông tin tài khoản
    SELECT
        @AccountID = AccountID,
        @CurrentPasswordHash = PasswordHash,
        @FirstLoginChange = FirstLoginChangePwd
    FROM Account
    WHERE Username = @Username;

    IF @AccountID IS NULL
    BEGIN
        RAISERROR(N'Tên đăng nhập không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra mật khẩu cũ nếu không phải lần đầu đổi
    IF @FirstLoginChange = 0 AND @OldPassword IS NOT NULL
    BEGIN
        IF HASHBYTES('SHA2_256', @OldPassword) <> @CurrentPasswordHash
        BEGIN
            RAISERROR(N'Mật khẩu cũ không đúng.', 16, 1);
            RETURN;
        END
    END
    ELSE IF @FirstLoginChange = 0 AND @OldPassword IS NULL
    BEGIN
        RAISERROR(N'Vui lòng cung cấp mật khẩu cũ để đổi mật khẩu.', 16, 1);
        RETURN;
    END

    -- Kiểm tra cấu trúc mật khẩu mới (8 ký tự, bao gồm chữ hoa, chữ thường, số, ký tự đặc biệt)
    IF LEN(@NewPassword) < 8
        OR @NewPassword NOT LIKE '%[A-Z]%'
        OR @NewPassword NOT LIKE '%[a-z]%'
        OR @NewPassword NOT LIKE '%[0-9]%'
        OR @NewPassword NOT LIKE '%[!@#$%^&*()]%'
    BEGIN
        RAISERROR(N'Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.', 16, 1);
        RETURN;
    END

    -- Mã hóa mật khẩu mới
    SET @NewPasswordHash = HASHBYTES('SHA2_256', @NewPassword);

    -- Cập nhật mật khẩu
    UPDATE Account
    SET
        PasswordHash = @NewPasswordHash,
        UpdatedAt = GETDATE(),
        FirstLoginChangePwd = 0, -- Đặt lại cờ sau khi đổi mật khẩu lần đầu
        WrongLoginCount = 0      -- Reset số lần đăng nhập sai
    WHERE AccountID = @AccountID;

    PRINT N'Mật khẩu đã được thay đổi thành công cho tài khoản ' + @Username + N'.';
END;
GO

-- Thủ tục SP_RequestPasswordReset: Tạo yêu cầu đặt lại mật khẩu.
-- Thủ tục này chỉ tạo một yêu cầu và chờ phê duyệt.
-- Ví dụ: EXEC SP_RequestPasswordReset N'NN68202500001', 1; -- Yêu cầu đặt lại mật khẩu cho nhân viên có StaffCode 'NN68202500001' do RequesterStaffID 1 thực hiện
CREATE OR ALTER PROCEDURE SP_RequestPasswordReset
    @TargetStaffCode NVARCHAR(20),      -- Mã nhân viên cần đặt lại mật khẩu
    @RequesterStaffID INT               -- ID của nhân viên tạo yêu cầu đặt lại mật khẩu
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TargetStaffID INT;
    DECLARE @TargetStaffFullName NVARCHAR(255);
    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);

    -- Lấy StaffID và FullName của nhân viên mục tiêu
    SELECT @TargetStaffID = StaffID, @TargetStaffFullName = FullName
    FROM Staff
    WHERE StaffCode = @TargetStaffCode;

    IF @TargetStaffID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên với mã: %s.', 16, 1, @TargetStaffCode);
        RETURN;
    END

    -- Lấy CategoryID cho yêu cầu đặt lại mật khẩu
    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu đặt lại mật khẩu';
    IF @RequestCategoryID IS NULL
    BEGIN
        -- Nếu chưa có, thêm mới Category
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu đặt lại mật khẩu', N'Yêu cầu đặt lại mật khẩu hệ thống cho nhân viên.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu đặt lại mật khẩu".';
    END

    -- Lấy StatusID cho trạng thái "Đang chờ"
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu đặt lại mật khẩu cho nhân viên: ' + @TargetStaffFullName + N' (' + @TargetStaffCode + N')';
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' yêu cầu đặt lại mật khẩu cho tài khoản của ' + @TargetStaffFullName + N' (Mã: ' + @TargetStaffCode + N').';

    -- Tạo yêu cầu phê duyệt
    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Account', @TargetStaffID, NULL); -- ProposedChanges NULL vì mật khẩu sẽ được sinh khi phê duyệt

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    -- Ghi log yêu cầu
    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu đặt lại mật khẩu đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu đặt lại mật khẩu cho nhân viên ' + @TargetStaffFullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestAddStaff: Tạo yêu cầu thêm mới nhân viên.
-- Thay vì INSERT trực tiếp vào Staff, giờ đây tạo một yêu cầu phê duyệt.
-- Ví dụ: EXEC SP_RequestAddStaff 1, N'{"FullName": "Nguyễn Văn Test", "Gender": "Nam", "Email": "test@example.com", "BranchID": 1, "DepartmentID": 2, "ContractType": "Full-time", "BaseSalary": 10000000}';
CREATE OR ALTER PROCEDURE SP_RequestAddStaff
    @RequesterStaffID INT,
    @StaffData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @FullName NVARCHAR(255) = JSON_VALUE(@StaffData, '$.FullName');

    -- Lấy CategoryID cho yêu cầu thêm nhân viên
    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu thêm nhân viên';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu thêm nhân viên', N'Yêu cầu thêm một nhân viên mới vào hệ thống.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu thêm nhân viên".';
    END

    -- Lấy StatusID cho trạng thái "Đang chờ"
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu thêm nhân viên mới: ' + @FullName;
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu thêm nhân viên mới: ' + @FullName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Staff', NULL, @StaffData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu thêm nhân viên đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu thêm nhân viên ' + @FullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestEditStaff: Tạo yêu cầu sửa thông tin nhân viên.
-- Ví dụ: EXEC SP_RequestEditStaff 1, 10, N'{"Phone": "0987654321", "Email": "new.email@example.com"}';
CREATE OR ALTER PROCEDURE SP_RequestEditStaff
    @RequesterStaffID INT,
    @TargetStaffID INT,
    @StaffData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @TargetStaffFullName NVARCHAR(255) = (SELECT FullName FROM Staff WHERE StaffID = @TargetStaffID);

    IF @TargetStaffFullName IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên mục tiêu với StaffID = %d.', 16, 1, @TargetStaffID);
        RETURN;
    END

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu sửa thông tin nhân viên';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu sửa thông tin nhân viên', N'Yêu cầu sửa đổi thông tin của một nhân viên hiện có.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu sửa thông tin nhân viên".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu sửa thông tin nhân viên: ' + @TargetStaffFullName + N' (ID: ' + CAST(@TargetStaffID AS NVARCHAR(10)) + N')';
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu sửa thông tin nhân viên ' + @TargetStaffFullName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Staff', @TargetStaffID, @StaffData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu sửa thông tin nhân viên đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu sửa thông tin nhân viên ' + @TargetStaffFullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestAddStudent: Tạo yêu cầu thêm mới học viên.
-- Ví dụ: EXEC SP_RequestAddStudent 1, N'{"FullName": "Trần Thị Học Viên", "Gender": "Nữ", "Email": "student@example.com", "BranchID": 1, "MajorID": 1, "ConsultantStaffID": 1}';
CREATE OR ALTER PROCEDURE SP_RequestAddStudent
    @RequesterStaffID INT,
    @StudentData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @FullName NVARCHAR(255) = JSON_VALUE(@StudentData, '$.FullName');

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu thêm học viên';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu thêm học viên', N'Yêu cầu thêm một học viên mới vào hệ thống.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu thêm học viên".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu thêm học viên mới: ' + @FullName;
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu thêm học viên mới: ' + @FullName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Student', NULL, @StudentData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu thêm học viên đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu thêm học viên ' + @FullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestEditStudent: Tạo yêu cầu sửa thông tin học viên.
-- Ví dụ: EXEC SP_RequestEditStudent 1, 5, N'{"Phone": "0123456789", "EntryLevel": "B1"}';
CREATE OR ALTER PROCEDURE SP_RequestEditStudent
    @RequesterStaffID INT,
    @TargetStudentID INT,
    @StudentData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @TargetStudentFullName NVARCHAR(255) = (SELECT FullName FROM Student WHERE StudentID = @TargetStudentID);

    IF @TargetStudentFullName IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy học viên mục tiêu với StudentID = %d.', 16, 1, @TargetStudentID);
        RETURN;
    END

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu sửa thông tin học viên';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu sửa thông tin học viên', N'Yêu cầu sửa đổi thông tin của một học viên hiện có.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu sửa thông tin học viên".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu sửa thông tin học viên: ' + @TargetStudentFullName + N' (ID: ' + CAST(@TargetStudentID AS NVARCHAR(10)) + N')';
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu sửa thông tin học viên ' + @TargetStudentFullName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Student', @TargetStudentID, @StudentData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu sửa thông tin học viên đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu sửa thông tin học viên ' + @TargetStudentFullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestAddClass: Tạo yêu cầu thêm mới lớp học.
-- Ví dụ: EXEC SP_RequestAddClass 1, N'{"ClassName": "Tiếng Anh Giao tiếp A1 - HN01", "MajorID": 1, "BranchID": 1, "MainTeacherID": 3, "StartDate": "2025-08-01", "ExpectedEndDate": "2025-10-31"}';
CREATE OR ALTER PROCEDURE SP_RequestAddClass
    @RequesterStaffID INT,
    @ClassData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @ClassName NVARCHAR(255) = JSON_VALUE(@ClassData, '$.ClassName');

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu tạo lớp học';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu tạo lớp học', N'Yêu cầu tạo một lớp học mới.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu tạo lớp học".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu tạo lớp học mới: ' + @ClassName;
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu tạo lớp học mới: ' + @ClassName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Class', NULL, @ClassData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu tạo lớp học đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu tạo lớp học ' + @ClassName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestAddMajor: Tạo yêu cầu thêm mới chuyên ngành.
-- Ví dụ: EXEC SP_RequestAddMajor 1, N'{"MajorCode": "TOEIC", "MajorName": "Luyện thi TOEIC", "TotalSessions": 20, "BaseTuitionFee": 5000000}';
CREATE OR ALTER PROCEDURE SP_RequestAddMajor
    @RequesterStaffID INT,
    @MajorData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @MajorName NVARCHAR(255) = JSON_VALUE(@MajorData, '$.MajorName');

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu tạo chuyên ngành';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu tạo chuyên ngành', N'Yêu cầu tạo một chuyên ngành đào tạo mới.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu tạo chuyên ngành".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu tạo chuyên ngành mới: ' + @MajorName;
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu tạo chuyên ngành mới: ' + @MajorName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Major', NULL, @MajorData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu tạo chuyên ngành đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu tạo chuyên ngành ' + @MajorName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestEditGenericData: Tạo yêu cầu sửa đổi thông tin hoặc trạng thái cho bất kỳ bảng dữ liệu nào (trừ Staff và Student).
-- Ví dụ: EXEC SP_RequestEditGenericData 1, N'Branch', 1, N'{"BranchName": "Chi nhánh Hà Nội Mới", "BranchAddress": "Số 100, Đường ABC"}';
-- Ví dụ: EXEC SP_RequestEditGenericData 1, N'Department', 2, N'{"StatusID": 2}'; -- Thay đổi trạng thái
CREATE OR ALTER PROCEDURE SP_RequestEditGenericData
    @RequesterStaffID INT,
    @TableName NVARCHAR(128),
    @RecordID INT,
    @ProposedChanges JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @RecordName NVARCHAR(255); -- Tên của bản ghi bị ảnh hưởng

    -- Lấy CategoryID cho yêu cầu sửa đổi thông tin chung
    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu sửa đổi thông tin chung';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu sửa đổi thông tin chung', N'Yêu cầu sửa đổi thông tin hoặc trạng thái của các bản ghi dữ liệu khác.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu sửa đổi thông tin chung".';
    END

    -- Lấy StatusID cho trạng thái "Đang chờ"
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    -- Lấy tên của bản ghi bị ảnh hưởng (ví dụ: BranchName, DepartmentName, MajorName, ClassName)
    -- Đây là một phần phức tạp vì mỗi bảng có cột tên khác nhau. Cần một cách linh hoạt hơn.
    -- Tạm thời, tôi sẽ cố gắng lấy các cột tên phổ biến.
    SET @RecordName = NULL;
    IF @TableName = N'Branch' SELECT @RecordName = BranchName FROM Branch WHERE BranchID = @RecordID;
    ELSE IF @TableName = N'Department' SELECT @RecordName = DepartmentName FROM Department WHERE DepartmentID = @RecordID;
    ELSE IF @TableName = N'Major' SELECT @RecordName = MajorName FROM Major WHERE MajorID = @RecordID;
    ELSE IF @TableName = N'Class' SELECT @RecordName = ClassName FROM Class WHERE ClassID = @RecordID;
    ELSE IF @TableName = N'Document' SELECT @RecordName = DocumentName FROM Document WHERE DocumentID = @RecordID;
    ELSE IF @TableName = N'Voucher' SELECT @RecordName = VoucherCode FROM Voucher WHERE VoucherID = @RecordID;
    -- Thêm các bảng khác nếu cần

    SET @RequestTitle = N'Yêu cầu sửa đổi thông tin: ' + @TableName + N' - ID ' + CAST(@RecordID AS NVARCHAR(10)) + ISNULL(N' (' + @RecordName + N')', '');
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu sửa đổi thông tin cho bảng ' + @TableName + N', bản ghi ID ' + CAST(@RecordID AS NVARCHAR(10)) + N'. Chi tiết thay đổi: ' + @ProposedChanges;

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), @TableName, @RecordID, @ProposedChanges);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu sửa đổi thông tin chung đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu sửa đổi thông tin chung cho bảng ' + @TableName + N' (ID: ' + CAST(@RecordID AS NVARCHAR(10)) + N') đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO


-- Thủ tục SP_RequestGrantPermission: Tạo yêu cầu cấp quyền/vai trò.
-- Ví dụ: EXEC SP_RequestGrantPermission 1, 10, N'Giáo viên'; -- Yêu cầu cấp vai trò 'Giáo viên' cho StaffID 10
CREATE OR ALTER PROCEDURE SP_RequestGrantPermission
    @RequesterStaffID INT,
    @TargetStaffID INT,
    @RoleName NVARCHAR(50) = NULL,
    @PermissionName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @TargetStaffFullName NVARCHAR(255) = (SELECT FullName FROM Staff WHERE StaffID = @TargetStaffID);
    DECLARE @ProposedChanges JSON;

    IF @TargetStaffFullName IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy nhân viên mục tiêu với StaffID = %d.', 16, 1, @TargetStaffID);
        RETURN;
    END

    IF @RoleName IS NULL AND @PermissionName IS NULL
    BEGIN
        RAISERROR(N'Vui lòng cung cấp RoleName hoặc PermissionName để yêu cầu cấp quyền.', 16, 1);
        RETURN;
    END

    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu cấp quyền truy cập';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu cấp quyền truy cập', N'Yêu cầu cấp thêm vai trò hoặc quyền cụ thể cho nhân viên.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu cấp quyền truy cập".';
    END

    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu cấp quyền truy cập cho nhân viên: ' + @TargetStaffFullName + N' (ID: ' + CAST(@TargetStaffID AS NVARCHAR(10)) + N')';
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu cấp quyền truy cập cho ' + @TargetStaffFullName + N'. ';

    SET @ProposedChanges = JSON_OBJECT('TargetStaffID': @TargetStaffID, 'RoleName': @RoleName, 'PermissionName': @PermissionName);

    IF @RoleName IS NOT NULL
        SET @RequestContent = @RequestContent + N'Vai trò đề xuất: ' + @RoleName + N'.';
    IF @PermissionName IS NOT NULL
        SET @RequestContent = @RequestContent + N'Quyền đề xuất: ' + @PermissionName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Permission', @TargetStaffID, @ProposedChanges);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu cấp quyền truy cập đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu cấp quyền truy cập cho nhân viên ' + @TargetStaffFullName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_RequestUploadDocument: Tạo yêu cầu phê duyệt để tải lên tài liệu mới.
-- Ví dụ: EXEC SP_RequestUploadDocument 1, N'{"DocumentName": "Báo cáo tài chính Q2 2025", "DepartmentID": 1, "DocumentTypeID": 1, "FilePath": "/documents/finance/Q2_2025_Report.pdf", "Description": "Báo cáo tài chính quý 2 năm 2025", "CreatorStaffID": 1}';
CREATE OR ALTER PROCEDURE SP_RequestUploadDocument
    @RequesterStaffID INT,
    @DocumentData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @DocumentName NVARCHAR(255) = JSON_VALUE(@DocumentData, '$.DocumentName');

    -- Lấy CategoryID cho yêu cầu tải lên tài liệu
    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu tải lên tài liệu';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu tải lên tài liệu', N'Yêu cầu phê duyệt để tải lên tài liệu mới vào hệ thống.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu tải lên tài liệu".';
    END

    -- Lấy StatusID cho trạng thái "Đang chờ"
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu tải lên tài liệu mới: ' + @DocumentName;
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu tải lên tài liệu mới: ' + @DocumentName + N'.';

    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'Document', NULL, @DocumentData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu tải lên tài liệu đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu tải lên tài liệu ' + @DocumentName + N' đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- Thủ tục SP_ApproveRequest: Phê duyệt một yêu cầu và thực hiện hành động tương ứng.
-- Bao gồm logic phân luồng phê duyệt.
-- Ví dụ: EXEC SP_ApproveRequest 1, 2, 'HHMS_Mail_Profile';
CREATE OR ALTER PROCEDURE SP_ApproveRequest
    @RequestID INT,                 -- ID của yêu cầu phê duyệt
    @ApproverStaffID INT,           -- ID của nhân viên phê duyệt
    @MailProfileName NVARCHAR(128)  -- Tên Profile Database Mail đã cấu hình
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @RequestStatusID INT;
    DECLARE @RelatedEntityType NVARCHAR(50);
    DECLARE @RelatedEntityID INT;
    DECLARE @ProposedChanges NVARCHAR(MAX);
    DECLARE @ApprovedStatusID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequesterBranchID INT;
    DECLARE @ApproverBranchID INT;
    DECLARE @IsBranchDirector BIT = 0;
    DECLARE @IsCentralBOM BIT = 0;
    DECLARE @TargetStaffID INT; -- Dùng cho các trường hợp liên quan đến Staff/Account/Permission
    DECLARE @TargetStudentID INT; -- Dùng cho các trường hợp liên quan đến Student
    DECLARE @CategoryName NVARCHAR(100);

    -- Lấy thông tin yêu cầu
    SELECT
        @RequestCategoryID = CategoryID,
        @RequestStatusID = StatusID,
        @RelatedEntityType = RelatedEntityType,
        @RelatedEntityID = RelatedEntityID,
        @ProposedChanges = ProposedChanges
    FROM ApprovalRequest
    WHERE RequestID = @RequestID;

    IF @RequestCategoryID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy yêu cầu phê duyệt với ID: %d.', 16, 1, @RequestID);
        RETURN;
    END

    -- Lấy StatusID cho trạng thái "Đã duyệt" và "Đang chờ"
    SELECT @ApprovedStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đã duyệt' AND StatusType = N'ApprovalRequest';
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';

    IF @ApprovedStatusID IS NULL OR @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy trạng thái phê duyệt hợp lệ. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    -- Kiểm tra trạng thái yêu cầu
    IF @RequestStatusID <> @PendingStatusID
    BEGIN
        RAISERROR(N'Yêu cầu này không ở trạng thái "Đang chờ" để phê duyệt.', 16, 1);
        RETURN;
    END

    -- Xác định vai trò của người phê duyệt
    IF EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @ApproverStaffID AND R.RoleName = N'Giám đốc chi nhánh')
    BEGIN
        SET @IsBranchDirector = 1;
        SELECT @ApproverBranchID = BranchID FROM Staff WHERE StaffID = @ApproverStaffID;
    END

    IF EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @ApproverStaffID AND R.RoleName = N'BMTW')
    BEGIN
        SET @IsCentralBOM = 1;
    END
    ELSE IF EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @ApproverStaffID AND R.RoleName = N'Quản trị viên cấp cao')
    BEGIN
        SET @IsCentralBOM = 1;
    END

    SELECT @CategoryName = CategoryName FROM RequestCategory WHERE CategoryID = @RequestCategoryID;

    -- Bắt đầu giao dịch để đảm bảo tính toàn vẹn
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Logic phân luồng phê duyệt
        DECLARE @CanApprove BIT = 0;
        
        -- Rule 1: Student-related changes (Add/Edit Student, Add/Edit StudentTuition) - Branch Director approval
        IF @RelatedEntityType IN (N'Student', N'StudentTuition') AND @CategoryName IN (N'Yêu cầu thêm học viên', N'Yêu cầu sửa thông tin học viên', N'Yêu cầu quản lý học phí')
        BEGIN
            IF @IsBranchDirector = 1
            BEGIN
                -- Determine the relevant BranchID for the student
                IF @RelatedEntityType = N'Student'
                BEGIN
                    IF @RelatedEntityID IS NOT NULL -- Edit Student
                    BEGIN
                        SELECT @TargetStudentID = @RelatedEntityID;
                        SELECT @RequesterBranchID = BranchID FROM Student WHERE StudentID = @TargetStudentID;
                    END
                    ELSE -- Add Student
                    BEGIN
                        SELECT @RequesterBranchID = JSON_VALUE(@ProposedChanges, '$.BranchID');
                    END
                END
                ELSE IF @RelatedEntityType = N'StudentTuition'
                BEGIN
                    DECLARE @TempStudentID INT;
                    IF @RelatedEntityID IS NOT NULL -- Edit StudentTuition
                    BEGIN
                        SELECT @TempStudentID = StudentID FROM StudentTuition WHERE TuitionID = @RelatedEntityID;
                        SELECT @RequesterBranchID = BranchID FROM Student WHERE StudentID = @TempStudentID;
                    END
                    ELSE -- Add StudentTuition
                    BEGIN
                        SELECT @TempStudentID = JSON_VALUE(@ProposedChanges, '$.StudentID');
                        SELECT @RequesterBranchID = BranchID FROM Student WHERE StudentID = @TempStudentID;
                    END
                END

                IF @RequesterBranchID IS NOT NULL AND @ApproverBranchID = @RequesterBranchID
                BEGIN
                    SET @CanApprove = 1;
                END
            END
        END
        -- Rule 2: All other changes (Staff, Account, Permission, Class, Major, Document, Voucher, and Generic Data) - Central BOM approval
        ELSE IF @RelatedEntityType IN (N'Staff', N'Account', N'Permission', N'Class', N'Major', N'Document', N'Voucher') OR @CategoryName = N'Yêu cầu sửa đổi thông tin chung' OR @CategoryName = N'Yêu cầu tải lên tài liệu'
        BEGIN
            IF @IsCentralBOM = 1
            BEGIN
                SET @CanApprove = 1;
            END
        END

        IF @CanApprove = 0
        BEGIN
            RAISERROR(N'Bạn không có quyền phê duyệt yêu cầu này hoặc yêu cầu không thuộc thẩm quyền của bạn.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Cập nhật trạng thái yêu cầu phê duyệt
        UPDATE ApprovalRequest
        SET StatusID = @ApprovedStatusID,
            ApprovalDate = GETDATE(),
            ApproverStaffID = @ApproverStaffID,
            LastModifiedDate = GETDATE()
        WHERE RequestID = @RequestID;

        -- Ghi log phê duyệt
        INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
        VALUES (@RequestID, @ApproverStaffID, N'Approved', GETDATE(), N'Yêu cầu đã được phê duyệt.', @ApprovedStatusID);

        -- Thực hiện hành động dựa trên loại yêu cầu
        IF @RelatedEntityType = N'Staff' AND @CategoryName = N'Yêu cầu thêm nhân viên'
        BEGIN
            INSERT INTO Staff (FullName, Gender, IDNumber, BirthDate, StaffAddress, Phone, Email, SocialInsurance, ContractType, DateJoined, TaxCode, BankBranch, BankAccount, BranchID, DepartmentID, BaseSalary, FixedDeductions, StatusID)
            SELECT
                JSON_VALUE(@ProposedChanges, '$.FullName'),
                JSON_VALUE(@ProposedChanges, '$.Gender'),
                JSON_VALUE(@ProposedChanges, '$.IDNumber'),
                JSON_VALUE(@ProposedChanges, '$.BirthDate'),
                JSON_VALUE(@ProposedChanges, '$.StaffAddress'),
                JSON_VALUE(@ProposedChanges, '$.Phone'),
                JSON_VALUE(@ProposedChanges, '$.Email'),
                JSON_VALUE(@ProposedChanges, '$.SocialInsurance'),
                JSON_VALUE(@ProposedChanges, '$.ContractType'),
                JSON_VALUE(@ProposedChanges, '$.DateJoined'),
                JSON_VALUE(@ProposedChanges, '$.TaxCode'),
                JSON_VALUE(@ProposedChanges, '$.BankBranch'),
                JSON_VALUE(@ProposedChanges, '$.BankAccount'),
                JSON_VALUE(@ProposedChanges, '$.BranchID'),
                JSON_VALUE(@ProposedChanges, '$.DepartmentID'),
                JSON_VALUE(@ProposedChanges, '$.BaseSalary'),
                JSON_VALUE(@ProposedChanges, '$.FixedDeductions'),
                (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Staff')
            ;
            UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;

            DECLARE @NewStaffID INT = SCOPE_IDENTITY();
            DECLARE @NewStaffEmail NVARCHAR(255) = JSON_VALUE(@ProposedChanges, '$.Email');
            EXEC SP_CreateStaffAccount @NewStaffID, @NewStaffEmail, @MailProfileName;

            PRINT N'Đã thêm nhân viên mới và tạo tài khoản thành công.';
        END
        ELSE IF @RelatedEntityType = N'Staff' AND @CategoryName = N'Yêu cầu sửa thông tin nhân viên'
        BEGIN
            SET @TargetStaffID = @RelatedEntityID;
            UPDATE Staff
            SET
                FullName = ISNULL(JSON_VALUE(@ProposedChanges, '$.FullName'), FullName),
                Gender = ISNULL(JSON_VALUE(@ProposedChanges, '$.Gender'), Gender),
                IDNumber = ISNULL(JSON_VALUE(@ProposedChanges, '$.IDNumber'), IDNumber),
                BirthDate = ISNULL(JSON_VALUE(@ProposedChanges, '$.BirthDate'), BirthDate),
                StaffAddress = ISNULL(JSON_VALUE(@ProposedChanges, '$.StaffAddress'), StaffAddress),
                Phone = ISNULL(JSON_VALUE(@ProposedChanges, '$.Phone'), Phone),
                Email = ISNULL(JSON_VALUE(@ProposedChanges, '$.Email'), Email),
                SocialInsurance = ISNULL(JSON_VALUE(@ProposedChanges, '$.SocialInsurance'), SocialInsurance),
                ContractType = ISNULL(JSON_VALUE(@ProposedChanges, '$.ContractType'), ContractType),
                DateJoined = ISNULL(JSON_VALUE(@ProposedChanges, '$.DateJoined'), DateJoined),
                TaxCode = ISNULL(JSON_VALUE(@ProposedChanges, '$.TaxCode'), TaxCode),
                BankBranch = ISNULL(JSON_VALUE(@ProposedChanges, '$.BankBranch'), BankBranch),
                BankAccount = ISNULL(JSON_VALUE(@ProposedChanges, '$.BankAccount'), BankAccount),
                BranchID = ISNULL(JSON_VALUE(@ProposedChanges, '$.BranchID'), BranchID),
                DepartmentID = ISNULL(JSON_VALUE(@ProposedChanges, '$.DepartmentID'), DepartmentID),
                BaseSalary = ISNULL(JSON_VALUE(@ProposedChanges, '$.BaseSalary'), BaseSalary),
                FixedDeductions = ISNULL(JSON_VALUE(@ProposedChanges, '$.FixedDeductions'), FixedDeductions),
                StatusID = ISNULL(JSON_VALUE(@ProposedChanges, '$.StatusID'), StatusID),
                LastModified = GETDATE()
            WHERE StaffID = @TargetStaffID;
            PRINT N'Đã cập nhật thông tin nhân viên thành công.';
        END
        ELSE IF @RelatedEntityType = N'Student' AND @CategoryName = N'Yêu cầu thêm học viên'
        BEGIN
            INSERT INTO Student (FullName, Gender, IDNumber, BirthDate, StudentAddress, Phone, Email, BranchID, MajorID, ConsultantStaffID, EntryLevel, ExitLevel, StatusID)
            SELECT
                JSON_VALUE(@ProposedChanges, '$.FullName'),
                JSON_VALUE(@ProposedChanges, '$.Gender'),
                JSON_VALUE(@ProposedChanges, '$.IDNumber'),
                JSON_VALUE(@ProposedChanges, '$.BirthDate'),
                JSON_VALUE(@ProposedChanges, '$.StudentAddress'),
                JSON_VALUE(@ProposedChanges, '$.Phone'),
                JSON_VALUE(@ProposedChanges, '$.Email'),
                JSON_VALUE(@ProposedChanges, '$.BranchID'),
                JSON_VALUE(@ProposedChanges, '$.MajorID'),
                JSON_VALUE(@ProposedChanges, '$.ConsultantStaffID'),
                JSON_VALUE(@ProposedChanges, '$.EntryLevel'),
                JSON_VALUE(@ProposedChanges, '$.ExitLevel'),
                (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Student')
            ;
            UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;
            PRINT N'Đã thêm học viên mới thành công.';
        END
        ELSE IF @RelatedEntityType = N'Student' AND @CategoryName = N'Yêu cầu sửa thông tin học viên'
        BEGIN
            SET @TargetStudentID = @RelatedEntityID;
            UPDATE Student
            SET
                FullName = ISNULL(JSON_VALUE(@ProposedChanges, '$.FullName'), FullName),
                Gender = ISNULL(JSON_VALUE(@ProposedChanges, '$.Gender'), Gender),
                IDNumber = ISNULL(JSON_VALUE(@ProposedChanges, '$.IDNumber'), IDNumber),
                BirthDate = ISNULL(JSON_VALUE(@ProposedChanges, '$.BirthDate'), BirthDate),
                StudentAddress = ISNULL(JSON_VALUE(@ProposedChanges, '$.StudentAddress'), StudentAddress),
                Phone = ISNULL(JSON_VALUE(@ProposedChanges, '$.Phone'), Phone),
                Email = ISNULL(JSON_VALUE(@ProposedChanges, '$.Email'), Email),
                BranchID = ISNULL(JSON_VALUE(@ProposedChanges, '$.BranchID'), BranchID),
                MajorID = ISNULL(JSON_VALUE(@ProposedChanges, '$.MajorID'), MajorID),
                ConsultantStaffID = ISNULL(JSON_VALUE(@ProposedChanges, '$.ConsultantStaffID'), ConsultantStaffID),
                EntryLevel = ISNULL(JSON_VALUE(@ProposedChanges, '$.EntryLevel'), EntryLevel),
                ExitLevel = ISNULL(JSON_VALUE(@ProposedChanges, '$.ExitLevel'), ExitLevel),
                StatusID = ISNULL(JSON_VALUE(@ProposedChanges, '$.StatusID'), StatusID)
            WHERE StudentID = @TargetStudentID;
            PRINT N'Đã cập nhật thông tin học viên thành công.';
        END
        ELSE IF @RelatedEntityType = N'StudentTuition' AND @CategoryName = N'Yêu cầu quản lý học phí'
        BEGIN
            -- Add or update StudentTuition record
            DECLARE @CurrentTuitionID INT;
            DECLARE @ProposedStudentID INT = JSON_VALUE(@ProposedChanges, '$.StudentID');
            DECLARE @ProposedClassID INT = JSON_VALUE(@ProposedChanges, '$.ClassID');
            DECLARE @ProposedVoucherID INT = JSON_VALUE(@ProposedChanges, '$.VoucherID');
            DECLARE @ProposedAmountPaid DECIMAL(19,2) = JSON_VALUE(@ProposedChanges, '$.AmountPaid');
            DECLARE @ProposedPaymentDate DATE = JSON_VALUE(@ProposedChanges, '$.PaymentDate');
            DECLARE @ProposedPaymentMethod NVARCHAR(50) = JSON_VALUE(@ProposedChanges, '$.PaymentMethod');
            DECLARE @ProposedDueDate DATE = JSON_VALUE(@ProposedChanges, '$.DueDate');
            DECLARE @ProposedStatusID INT = JSON_VALUE(@ProposedChanges, '$.StatusID');
            DECLARE @CalculatedTotalFee DECIMAL(19,2); -- To store BaseTuitionFee from Major

            -- Get BaseTuitionFee from Major based on ClassID
            SELECT @CalculatedTotalFee = M.BaseTuitionFee
            FROM Class C
            JOIN Major M ON C.MajorID = M.MajorID
            WHERE C.ClassID = @ProposedClassID;

            IF @CalculatedTotalFee IS NULL
            BEGIN
                RAISERROR(N'Không tìm thấy học phí cơ bản cho lớp ID %d. Vui lòng kiểm tra Major và Class.', 16, 1, @ProposedClassID);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Check if a tuition record already exists for this student and class
            SELECT @CurrentTuitionID = TuitionID
            FROM StudentTuition
            WHERE StudentID = @ProposedStudentID AND ClassID = @ProposedClassID;

            IF @CurrentTuitionID IS NOT NULL -- Update existing record
            BEGIN
                UPDATE StudentTuition
                SET
                    TotalFee = ISNULL(@CalculatedTotalFee, TotalFee), -- Always update TotalFee from Major
                    VoucherID = ISNULL(@ProposedVoucherID, VoucherID),
                    AmountPaid = ISNULL(@ProposedAmountPaid, AmountPaid),
                    PaymentDate = ISNULL(@ProposedPaymentDate, PaymentDate),
                    PaymentMethod = ISNULL(@ProposedPaymentMethod, PaymentMethod),
                    DueDate = ISNULL(@ProposedDueDate, DueDate),
                    StatusID = ISNULL(@ProposedStatusID, StatusID),
                    LastModified = GETDATE()
                WHERE TuitionID = @CurrentTuitionID;
                PRINT N'Đã cập nhật thông tin học phí cho học viên ID ' + CAST(@ProposedStudentID AS NVARCHAR(10)) + N' và lớp ID ' + CAST(@ProposedClassID AS NVARCHAR(10)) + N'.';
            END
            ELSE -- Insert new record
            BEGIN
                INSERT INTO StudentTuition (StudentID, ClassID, TotalFee, VoucherID, AmountPaid, PaymentDate, PaymentMethod, DueDate, StatusID)
                VALUES (
                    @ProposedStudentID,
                    @ProposedClassID,
                    @CalculatedTotalFee, -- Use calculated TotalFee
                    @ProposedVoucherID,
                    @ProposedAmountPaid,
                    @ProposedPaymentDate,
                    @ProposedPaymentMethod,
                    @ProposedDueDate,
                    @ProposedStatusID
                );
                UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;
                SELECT @CurrentTuitionID = SCOPE_IDENTITY(); -- Get the newly inserted TuitionID
                PRINT N'Đã thêm khoản học phí mới cho học viên ID ' + CAST(@ProposedStudentID AS NVARCHAR(10)) + N' và lớp ID ' + CAST(@ProposedClassID AS NVARCHAR(10)) + N'.';
            END

            -- If a voucher was applied, increment its UsedCount
            IF @ProposedVoucherID IS NOT NULL
            BEGIN
                UPDATE Voucher
                SET UsedCount = UsedCount + 1,
                    StatusID = CASE WHEN UsageLimit <> -1 AND UsedCount + 1 >= UsageLimit THEN (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Đã dùng hết' AND StatusType = N'Voucher') ELSE StatusID END,
                    LastModified = GETDATE()
                WHERE VoucherID = @ProposedVoucherID;
                PRINT N'Đã tăng số lượt sử dụng của voucher ID ' + CAST(@ProposedVoucherID AS NVARCHAR(10)) + N'.';
            END
        END
        ELSE IF @RelatedEntityType = N'Class' AND @CategoryName = N'Yêu cầu tạo lớp học'
        BEGIN
            INSERT INTO Class (ClassName, MajorID, BranchID, MainTeacherID, AssistantID, Room, StartDate, ExpectedEndDate, TrainingProgress, StatusID)
            SELECT
                JSON_VALUE(@ProposedChanges, '$.ClassName'),
                JSON_VALUE(@ProposedChanges, '$.MajorID'),
                JSON_VALUE(@ProposedChanges, '$.BranchID'),
                JSON_VALUE(@ProposedChanges, '$.MainTeacherID'),
                JSON_VALUE(@ProposedChanges, '$.AssistantID'),
                JSON_VALUE(@ProposedChanges, '$.Room'),
                JSON_VALUE(@ProposedChanges, '$.StartDate'),
                JSON_VALUE(@ProposedChanges, '$.ExpectedEndDate'),
                ISNULL(JSON_VALUE(@ProposedChanges, '$.TrainingProgress'), N'Chưa bắt đầu'),
                (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Class')
            ;
            UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;
            PRINT N'Đã tạo lớp học mới thành công.';
        END
        ELSE IF @RelatedEntityType = N'Major' AND @CategoryName = N'Yêu cầu tạo chuyên ngành'
        BEGIN
            INSERT INTO Major (MajorCode, MajorName, MajorDescription, InputRequirement, OutputRequirement, TotalSessions, BaseTuitionFee, StatusID)
            SELECT
                JSON_VALUE(@ProposedChanges, '$.MajorCode'),
                JSON_VALUE(@ProposedChanges, '$.MajorName'),
                JSON_VALUE(@ProposedChanges, '$.MajorDescription'),
                JSON_VALUE(@ProposedChanges, '$.InputRequirement'),
                JSON_VALUE(@ProposedChanges, '$.OutputRequirement'),
                JSON_VALUE(@ProposedChanges, '$.TotalSessions'),
                JSON_VALUE(@ProposedChanges, '$.BaseTuitionFee'),
                (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Major')
            ;
            UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;
            PRINT N'Đã tạo chuyên ngành mới thành công.';
        END
        ELSE IF @RelatedEntityType = N'Permission' AND @CategoryName = N'Yêu cầu cấp quyền truy cập'
        BEGIN
            SET @TargetStaffID = JSON_VALUE(@ProposedChanges, '$.TargetStaffID');
            DECLARE @RoleToGrant NVARCHAR(50) = JSON_VALUE(@ProposedChanges, '$.RoleName');
            DECLARE @PermissionToGrant NVARCHAR(100) = JSON_VALUE(@ProposedChanges, '$.PermissionName');

            IF @RoleToGrant IS NOT NULL
            BEGIN
                DECLARE @RoleID INT;
                SELECT @RoleID = RoleID FROM Role WHERE RoleName = @RoleToGrant;
                IF @RoleID IS NOT NULL
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM Staff_Role WHERE StaffID = @TargetStaffID AND RoleID = @RoleID)
                    BEGIN
                        INSERT INTO Staff_Role (StaffID, RoleID) VALUES (@TargetStaffID, @RoleID);
                        PRINT N'Đã cấp vai trò "' + @RoleToGrant + N'" cho nhân viên ID: ' + CAST(@TargetStaffID AS NVARCHAR(10)) + N'.';
                    END
                    ELSE
                    BEGIN
                        PRINT N'Nhân viên ID: ' + CAST(@TargetStaffID AS NVARCHAR(10)) + N' đã có vai trò "' + @RoleToGrant + N'".';
                    END
                END
                ELSE
                BEGIN
                    PRINT N'Vai trò "' + @RoleToGrant + N'" không tồn tại.';
                END
            END

            IF @PermissionToGrant IS NOT NULL
            BEGIN
                DECLARE @PermissionID INT;
                SELECT @PermissionID = PermissionID FROM Permission WHERE PermissionName = @PermissionToGrant;
                IF @PermissionID IS NOT NULL
                BEGIN
                    PRINT N'Cần triển khai logic cấp quyền trực tiếp cho quyền "' + @PermissionToGrant + N'". Hiện tại chỉ hỗ trợ cấp vai trò.';
                END
                ELSE
                BEGIN
                    PRINT N'Quyền "' + @PermissionToGrant + N'" không tồn tại.';
                END
            END
        END
        ELSE IF @RelatedEntityType = N'Account' AND @CategoryName = N'Yêu cầu đặt lại mật khẩu'
        BEGIN
            DECLARE @TargetStaffEmail NVARCHAR(255);
            DECLARE @TargetStaffUsername NVARCHAR(100);
            DECLARE @TargetStaffFullName NVARCHAR(255);
            
            SELECT
                @TargetStaffEmail = S.Email,
                @TargetStaffUsername = A.Username,
                @TargetStaffFullName = S.FullName
            FROM Staff S
            JOIN Account A ON S.StaffID = A.StaffID
            WHERE S.StaffID = @RelatedEntityID;

            DECLARE @NewPassword NVARCHAR(8);
            SET @NewPassword = dbo.GenerateRandomPassword();
            
            UPDATE Account SET PasswordHash = HASHBYTES('SHA2_256', @NewPassword), UpdatedAt = GETDATE(), FirstLoginChangePwd = 1 WHERE StaffID = @RelatedEntityID;

            DECLARE @EmailSubject NVARCHAR(255) = N'Thông báo đặt lại mật khẩu hệ thống HHMS Ngoaingu68';
            DECLARE @EmailBody NVARCHAR(MAX) = N'
            <html>
            <head>
                <style>
                    body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; font-size: 14px; color: #333; }
                    .container { width: 100%; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
                    h2 { color: #0A2463; border-bottom: 2px solid #3E8989; padding-bottom: 10px; margin-bottom: 20px; }
                    p { margin-bottom: 10px; }
                    .highlight { background-color: #f0f8ff; padding: 10px; border-left: 4px solid #3E8989; margin-bottom: 15px; }
                    .important { font-weight: bold; color: #D8315B; }
                    .footer { margin-top: 30px; padding-top: 15px; border-top: 1px solid #eee; text-align: center; font-size: 12px; color: #999; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h2>Thông báo đặt lại mật khẩu</h2>
                    <p>Kính gửi <strong>' + @TargetStaffFullName + N'</strong>,</p>
                    <p>Yêu cầu đặt lại mật khẩu cho tài khoản của bạn trên hệ thống HHMS Ngoaingu68 đã được phê duyệt và thực hiện.</p>
                    <p>Thông tin đăng nhập mới của bạn là:</p>
                    <div class="highlight">
                        <p>Tên đăng nhập: <strong style="color: #0A2463;">' + @TargetStaffUsername + N'</strong></p>
                        <p>Mật khẩu mới: <strong style="color: #0A2463;">' + @NewPassword + N'</strong></p>
                    </div>
                    <p class="important">Lưu ý quan trọng:</p>
                    <p>Vì lý do bảo mật, bạn <span class="important">bắt buộc</span> phải đổi mật khẩu này ngay trong lần đăng nhập đầu tiên.</p>
                    <p>Vui lòng truy cập hệ thống tại: [Địa chỉ liên kết hệ thống của bạn]</p>
                    <p>Nếu bạn không yêu cầu đặt lại mật khẩu này, vui lòng liên hệ ngay với phòng Nhân sự.</p>
                    <div class="footer">
                        <p>&copy; ' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)) + N' HHMS Ngoaingu68. All rights reserved.</p>
                    </div>
                </div>
            </body>
            </html>';

            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = @MailProfileName,
                @recipients = @TargetStaffEmail,
                @subject = @EmailSubject,
                @body = @EmailBody,
                @body_format = 'HTML';

            PRINT N'Mật khẩu đã được đặt lại và thông tin đăng nhập mới đã gửi đến ' + @TargetStaffEmail + N'.';
        END
        ELSE IF @RelatedEntityType = N'Document' AND @CategoryName = N'Yêu cầu tải lên tài liệu'
        BEGIN
            -- Insert the new document into the Document table
            INSERT INTO Document (DocumentName, DepartmentID, DocumentTypeID, PhysicalLocation, FilePath, Description, CreatedDate, CreatorStaffID, LastModifiedDate, LastModifierStaffID, StatusID)
            SELECT
                JSON_VALUE(@ProposedChanges, '$.DocumentName'),
                JSON_VALUE(@ProposedChanges, '$.DepartmentID'),
                JSON_VALUE(@ProposedChanges, '$.DocumentTypeID'),
                JSON_VALUE(@ProposedChanges, '$.PhysicalLocation'),
                JSON_VALUE(@ProposedChanges, '$.FilePath'),
                JSON_VALUE(@ProposedChanges, '$.Description'),
                GETDATE(), -- CreatedDate
                JSON_VALUE(@ProposedChanges, '$.CreatorStaffID'),
                GETDATE(), -- LastModifiedDate
                @ApproverStaffID, -- LastModifierStaffID (who approved it)
                (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Document') -- Set status to 'Hoạt động'
            ;
            UPDATE ApprovalRequest SET RelatedEntityID = SCOPE_IDENTITY() WHERE RequestID = @RequestID;
            PRINT N'Đã tải lên tài liệu mới thành công.';
        END
        ELSE IF @CategoryName = N'Yêu cầu sửa đổi thông tin chung'
        BEGIN
            -- Handle generic data update for other tables
            DECLARE @SQLUpdate NVARCHAR(MAX);
            DECLARE @SetClause NVARCHAR(MAX) = N'';
            
            -- Iterate through JSON keys and values to build the SET clause
            SELECT @SetClause = STRING_AGG(
                QUOTENAME([key]) + N' = ' + 
                CASE 
                    WHEN JSON_TYPE(@ProposedChanges, '$.' + [key]) = 'string' THEN N'N' + QUOTENAME(CAST([value] AS NVARCHAR(MAX)), '''')
                    WHEN JSON_TYPE(@ProposedChanges, '$.' + [key]) = 'boolean' THEN CAST(CAST([value] AS BIT) AS NVARCHAR(1))
                    ELSE CAST([value] AS NVARCHAR(MAX))
                END,
                N', '
            ) WITHIN GROUP (ORDER BY [key])
            FROM OPENJSON(@ProposedChanges);

            IF @SetClause IS NULL OR @SetClause = ''
            BEGIN
                RAISERROR(N'Không có thay đổi nào được đề xuất trong yêu cầu.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END

            SET @SQLUpdate = N'UPDATE ' + QUOTENAME(@RelatedEntityType) + N' SET ' + @SetClause + N' WHERE ' + QUOTENAME(@RelatedEntityType + 'ID') + N' = ' + CAST(@RelatedEntityID AS NVARCHAR(10)) + N';';
            
            -- Add LastModified for tables that have it
            IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(QUOTENAME(@RelatedEntityType)) AND name = 'LastModified')
            BEGIN
                SET @SQLUpdate = REPLACE(@SQLUpdate, N' WHERE ', N', LastModified = GETDATE() WHERE ');
            END

            EXEC sp_executesql @SQLUpdate;
            PRINT N'Đã cập nhật thông tin cho bảng ' + @RelatedEntityType + N' (ID: ' + CAST(@RelatedEntityID AS NVARCHAR(10)) + N') thành công.';
        END
        ELSE
        BEGIN
            PRINT N'Loại yêu cầu phê duyệt không xác định hoặc chưa được hỗ trợ: ' + @RelatedEntityType + N' - ' + @CategoryName + N'.';
        END;

        COMMIT TRANSACTION;
        PRINT N'Yêu cầu phê duyệt ID: ' + CAST(@RequestID AS NVARCHAR(10)) + N' đã được xử lý thành công.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; -- Re-throw the error to the calling application
    END CATCH
END;
GO

-- Thủ tục SP_RejectRequest: Từ chối một yêu cầu phê duyệt.
-- Ví dụ: EXEC SP_RejectRequest 1, 2, N'Yêu cầu không đủ thông tin.';
CREATE OR ALTER PROCEDURE SP_RejectRequest
    @RequestID INT,                 -- ID của yêu cầu phê duyệt
    @ApproverStaffID INT,           -- ID của nhân viên thực hiện từ chối
    @Comment NVARCHAR(500) = NULL   -- Lý do từ chối
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RejectedStatusID INT;
    DECLARE @RequestStatusID INT;
    DECLARE @PendingStatusID INT;

    -- Lấy StatusID cho trạng thái "Từ chối" và "Đang chờ"
    SELECT @RejectedStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Từ chối' AND StatusType = N'ApprovalRequest';
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';

    IF @RejectedStatusID IS NULL OR @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy trạng thái phê duyệt hợp lệ. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    -- Lấy trạng thái hiện tại của yêu cầu
    SELECT @RequestStatusID = StatusID FROM ApprovalRequest WHERE RequestID = @RequestID;

    IF @RequestStatusID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy yêu cầu phê duyệt với ID: %d.', 16, 1, @RequestID);
        RETURN;
    END

    IF @RequestStatusID <> @PendingStatusID
    BEGIN
        RAISERROR(N'Yêu cầu này không ở trạng thái "Đang chờ" để từ chối.', 16, 1);
        RETURN;
    END

    -- Bắt đầu giao dịch
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Cập nhật trạng thái yêu cầu phê duyệt
        UPDATE ApprovalRequest
        SET StatusID = @RejectedStatusID,
            ApprovalDate = GETDATE(),
            ApproverStaffID = @ApproverStaffID,
            LastModifiedDate = GETDATE()
        WHERE RequestID = @RequestID;

        -- Ghi log từ chối
        INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
        VALUES (@RequestID, @ApproverStaffID, N'Rejected', GETDATE(), ISNULL(@Comment, N'Yêu cầu đã bị từ chối.'), @RejectedStatusID);

        COMMIT TRANSACTION;
        PRINT N'Yêu cầu phê duyệt ID: ' + CAST(@RequestID AS NVARCHAR(10)) + N' đã bị từ chối.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW; -- Ném lại lỗi để ứng dụng bắt
    END CATCH
END;
GO

-- Thủ tục SP_CalculateAllMonthlyKPIs: Thực thi tính toán tất cả các KPI hàng tháng.
-- Thủ tục này sẽ được gọi định kỳ (ví dụ: vào đầu mỗi tháng mới) để tính toán KPI cho tháng trước.
-- Ví dụ: EXEC SP_CalculateAllMonthlyKPIs '2025-07-01'; -- Tính KPI cho tháng 7 (dữ liệu tháng 7)
CREATE OR ALTER PROCEDURE SP_CalculateAllMonthlyKPIs
    @KPIMonth DATE -- Tháng cần tính KPI (nên là ngày đầu tiên của tháng, ví dụ 'YYYY-MM-01')
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'Bắt đầu tính toán KPI cho tháng: ' + FORMAT(@KPIMonth, 'MM/yyyy');

    -- Tính KPI cho nhân viên HR (Tuyển sinh)
    DECLARE @HRStaffCode NVARCHAR(20);
    DECLARE @HRTarget DECIMAL(19,2) = 100000000; -- Ví dụ mục tiêu tổng học phí cho HR là 100 triệu VNĐ

    DECLARE curHR CURSOR FOR
    SELECT S.StaffCode
    FROM Staff S
    JOIN Department D ON S.DepartmentID = D.DepartmentID
    WHERE D.DepartmentName LIKE N'%Nhân sự%'; -- Giả định tên phòng ban HR có chứa 'Nhân sự'

    OPEN curHR;
    FETCH NEXT FROM curHR INTO @HRStaffCode;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SP_CalculateHRKPI @HRStaffCode, @KPIMonth, @HRTarget;
        FETCH NEXT FROM curHR INTO @HRStaffCode;
    END;
    CLOSE curHR;
    DEALLOCATE curHR;

    -- Tính KPI cho giáo viên/trợ giảng Full-time
    DECLARE @FTTeacherStaffCode NVARCHAR(20);
    DECLARE @FTTeacherTarget DECIMAL(5,2) = 90.0; -- Ví dụ mục tiêu chuyên cần 90%

    DECLARE curFTTeacher CURSOR FOR
    SELECT S.StaffCode
    FROM Staff S
    JOIN Staff_Role SR ON S.StaffID = SR.StaffID
    JOIN Role R ON SR.RoleID = R.RoleID
    WHERE S.ContractType = N'Full-time' AND R.RoleName IN (N'Giáo viên', N'Trợ giảng');

    OPEN curFTTeacher;
    FETCH NEXT FROM curFTTeacher INTO @FTTeacherStaffCode;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SP_CalculateTeacherKPI_Fulltime @FTTeacherStaffCode, @KPIMonth, @FTTeacherTarget;
        FETCH NEXT FROM curFTTeacher INTO @FTTeacherStaffCode;
    END;
    CLOSE curFTTeacher;
    DEALLOCATE curFTTeacher;

    -- Tính KPI cho giáo viên/trợ giảng Part-time
    DECLARE @PTTeacherStaffCode NVARCHAR(20);
    DECLARE @PTTeacherTarget DECIMAL(19,2) = 15; -- Ví dụ mục tiêu 15 ngày lớp đông

    DECLARE curPTTeacher CURSOR FOR
    SELECT S.StaffCode
    FROM Staff S
    JOIN Staff_Role SR ON S.StaffID = SR.StaffID
    JOIN Role R ON SR.RoleID = R.RoleID
    WHERE S.ContractType = N'Part-time' AND R.RoleName IN (N'Giáo viên', N'Trợ giảng');

    OPEN curPTTeacher;
    FETCH NEXT FROM curPTTeacher INTO @PTTeacherStaffCode;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SP_CalculateTeacherKPI_Parttime @PTTeacherStaffCode, @KPIMonth, @PTTeacherTarget;
        FETCH NEXT FROM curPTTeacher INTO @PTTeacherStaffCode;
    END;
    CLOSE curPTTeacher;
    DEALLOCATE curPTTeacher;

    PRINT N'Hoàn tất tính toán KPI cho tháng: ' + FORMAT(@KPIMonth, 'MM/yyyy');
END;
GO

-- Thủ tục SP_ProcessMonthlyPayroll: Xử lý toàn bộ quy trình lương cho một tháng.
-- Thủ tục này sẽ gọi SP_CalculateAllMonthlyKPIs trước, sau đó duyệt qua tất cả nhân viên
-- và gọi SP_CalculateAndSendSalarySlip cho từng người.
-- Ví dụ: EXEC SP_ProcessMonthlyPayroll '2025-07-01', 'HHMS_Mail_Profile';
CREATE OR ALTER PROCEDURE SP_ProcessMonthlyPayroll
    @PayrollMonth DATE,             -- Tháng cần xử lý bảng lương
    @MailProfileName NVARCHAR(128)  -- Tên Profile Database Mail đã cấu hình
AS
BEGIN
    SET NOCOUNT ON;
    PRINT N'Bắt đầu xử lý bảng lương tháng: ' + FORMAT(@PayrollMonth, 'MM/yyyy');

    -- Bước 1: Tính toán tất cả các KPI cho tháng này
    PRINT N'Đang tính toán KPI cho tất cả các bộ phận...';
    EXEC SP_CalculateAllMonthlyKPIs @PayrollMonth;
    PRINT N'Hoàn tất tính toán KPI.';

    -- Bước 2: Duyệt qua từng nhân viên và tính toán/gửi bảng lương
    PRINT N'Đang tính toán và gửi bảng lương cho từng nhân viên...';
    DECLARE @StaffCode NVARCHAR(20);
    DECLARE curStaff CURSOR FOR
    SELECT StaffCode FROM Staff WHERE StatusID = (SELECT StatusID FROM GeneralStatus WHERE StatusName = N'Hoạt động' AND StatusType = N'Staff');

    OPEN curStaff;
    FETCH NEXT FROM curStaff INTO @StaffCode;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC SP_CalculateAndSendSalarySlip @StaffCode, @PayrollMonth, @MailProfileName;
        END TRY
        BEGIN CATCH
            PRINT N'Lỗi khi xử lý bảng lương cho nhân viên ' + @StaffCode + N': ' + ERROR_MESSAGE();
        END CATCH
        FETCH NEXT FROM curStaff INTO @StaffCode;
    END;
    CLOSE curStaff;
    DEALLOCATE curStaff;

    PRINT N'Hoàn tất xử lý bảng lương tháng: ' + FORMAT(@PayrollMonth, 'MM/yyyy');
END;
GO

-- Thủ tục SP_RequestManageStudentTuition: Tạo yêu cầu quản lý học phí cho học viên.
-- Có thể dùng để thêm mới khoản học phí hoặc cập nhật khoản học phí hiện có.
-- Ví dụ: EXEC SP_RequestManageStudentTuition 1, N'{"StudentID": 101, "ClassID": 201, "VoucherID": 1, "AmountPaid": 5000000, "PaymentDate": "2025-07-15", "PaymentMethod": "Chuyển khoản", "DueDate": "2025-09-01", "StatusID": 4}';
CREATE OR ALTER PROCEDURE SP_RequestManageStudentTuition
    @RequesterStaffID INT,
    @TuitionData JSON
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RequestCategoryID INT;
    DECLARE @PendingStatusID INT;
    DECLARE @RequestTitle NVARCHAR(255);
    DECLARE @RequestContent NVARCHAR(MAX);
    DECLARE @StudentID INT = JSON_VALUE(@TuitionData, '$.StudentID');
    DECLARE @ClassID INT = JSON_VALUE(@TuitionData, '$.ClassID');
    DECLARE @StudentFullName NVARCHAR(255) = (SELECT FullName FROM Student WHERE StudentID = @StudentID);
    DECLARE @ClassName NVARCHAR(255) = (SELECT ClassName FROM Class WHERE ClassID = @ClassID);

    IF @StudentFullName IS NULL OR @ClassName IS NULL
    BEGIN
        RAISERROR(N'StudentID hoặc ClassID không hợp lệ.', 16, 1);
        RETURN;
    END

    -- Lấy CategoryID cho yêu cầu quản lý học phí
    SELECT @RequestCategoryID = CategoryID FROM RequestCategory WHERE CategoryName = N'Yêu cầu quản lý học phí';
    IF @RequestCategoryID IS NULL
    BEGIN
        INSERT INTO RequestCategory (CategoryName, Description) VALUES (N'Yêu cầu quản lý học phí', N'Yêu cầu thêm mới hoặc cập nhật thông tin học phí của học viên.');
        SELECT @RequestCategoryID = SCOPE_IDENTITY();
        PRINT N'Đã thêm danh mục yêu cầu "Yêu cầu quản lý học phí".';
    END

    -- Lấy StatusID cho trạng thái "Đang chờ"
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';
    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Trạng thái "Đang chờ" cho ApprovalRequest không tồn tại. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    SET @RequestTitle = N'Yêu cầu quản lý học phí cho học viên ' + @StudentFullName + N' (Lớp: ' + @ClassName + N')';
    SET @RequestContent = N'Nhân viên ' + (SELECT FullName FROM Staff WHERE StaffID = @RequesterStaffID) + N' đã gửi yêu cầu quản lý học phí cho học viên ' + @StudentFullName + N' (Lớp: ' + @ClassName + N'). Chi tiết: ' + @TuitionData;

    -- RelatedEntityID sẽ là TuitionID nếu là cập nhật, hoặc NULL nếu là thêm mới.
    -- Trong trường hợp này, chúng ta sẽ để NULL và SP_ApproveRequest sẽ tự cập nhật nếu là thêm mới.
    INSERT INTO ApprovalRequest (RequestTitle, RequestContent, RequesterID, CategoryID, StatusID, CreatedDate, RelatedEntityType, RelatedEntityID, ProposedChanges)
    VALUES (@RequestTitle, @RequestContent, @RequesterStaffID, @RequestCategoryID, @PendingStatusID, GETDATE(), N'StudentTuition', NULL, @TuitionData);

    DECLARE @NewRequestID INT = SCOPE_IDENTITY();

    INSERT INTO ApprovalLog (RequestID, ApproverID, Action, ActionDate, Comment, StatusID)
    VALUES (@NewRequestID, @RequesterStaffID, N'Submitted', GETDATE(), N'Yêu cầu quản lý học phí đã được gửi.', @PendingStatusID);

    PRINT N'Yêu cầu quản lý học phí cho học viên ' + @StudentFullName + N' (Lớp: ' + @ClassName + N') đã được tạo thành công (ID Yêu cầu: ' + CAST(@NewRequestID AS NVARCHAR(10)) + N'). Chờ phê duyệt.';
END;
GO

-- NEW STORED PROCEDURES FOR NOTIFICATIONS AND BRANCH ACTIVITIES

-- Thủ tục SP_GetBranchActivities: Hiển thị các hoạt động của chi nhánh cho nhân viên thuộc chi nhánh đó.
-- Bao gồm các giao dịch tài chính, cập nhật học phí, và thay đổi lớp học.
-- Ví dụ: EXEC SP_GetBranchActivities 1; -- Lấy hoạt động của chi nhánh mà nhân viên ID 1 thuộc về
CREATE OR ALTER PROCEDURE SP_GetBranchActivities
    @StaffID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BranchID INT;
    SELECT @BranchID = BranchID FROM Staff WHERE StaffID = @StaffID;

    IF @BranchID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy chi nhánh cho nhân viên với StaffID = %d.', 16, 1, @StaffID);
        RETURN;
    END

    PRINT N'Các hoạt động gần đây của chi nhánh (ID: ' + CAST(@BranchID AS NVARCHAR(10)) + N'):';

    -- 1. Giao dịch tài chính
    SELECT
        'Financial Transaction' AS ActivityType,
        FT.TransactionDate AS ActivityDate,
        TT.TransactionTypeName AS Type,
        FT.Description AS Description,
        FT.Amount AS Amount,
        GS.StatusName AS Status
    FROM
        FinancialTransaction FT
    JOIN
        TransactionType TT ON FT.TransactionTypeID = TT.TransactionTypeID
    JOIN
        GeneralStatus GS ON FT.StatusID = GS.StatusID
    WHERE
        FT.BranchID = @BranchID
    ORDER BY
        FT.TransactionDate DESC;

    -- 2. Cập nhật học phí học viên
    SELECT
        'Student Tuition Update' AS ActivityType,
        ST.LastModified AS ActivityDate,
        S.FullName AS StudentName,
        C.ClassName AS ClassName,
        ST.TotalFee AS OriginalFee,
        ST.FinalFee AS FinalFee,
        ST.AmountPaid AS AmountPaid,
        ST.OutstandingBalance AS Outstanding,
        GS.StatusName AS Status
    FROM
        StudentTuition ST
    JOIN
        Student S ON ST.StudentID = S.StudentID
    JOIN
        Class C ON ST.ClassID = C.ClassID
    JOIN
        GeneralStatus GS ON ST.StatusID = GS.StatusID
    WHERE
        S.BranchID = @BranchID -- Giả định học phí liên quan đến chi nhánh của học viên
    ORDER BY
        ST.LastModified DESC;

    -- 3. Thay đổi thông tin lớp học (ví dụ: lớp mới tạo, lớp thay đổi trạng thái)
    SELECT
        'Class Change' AS ActivityType,
        C.StartDate AS ActivityDate, -- Có thể dùng CreatedDate nếu có
        C.ClassName AS ClassName,
        M.MajorName AS Major,
        S_Main.FullName AS MainTeacher,
        GS.StatusName AS Status,
        C.TrainingProgress AS Progress
    FROM
        Class C
    JOIN
        Major M ON C.MajorID = M.MajorID
    LEFT JOIN
        Staff S_Main ON C.MainTeacherID = S_Main.StaffID
    JOIN
        GeneralStatus GS ON C.StatusID = GS.StatusID
    WHERE
        C.BranchID = @BranchID
    ORDER BY
        C.StartDate DESC;

END;
GO

-- Thủ tục SP_GetNewBranchRequestsForDirector: Hiển thị thông báo khi có yêu cầu mới được tạo từ chi nhánh của giám đốc.
-- Ví dụ: EXEC SP_GetNewBranchRequestsForDirector 2; -- Lấy yêu cầu mới cho giám đốc chi nhánh có StaffID 2
CREATE OR ALTER PROCEDURE SP_GetNewBranchRequestsForDirector
    @DirectorStaffID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DirectorBranchID INT;
    DECLARE @PendingStatusID INT;

    SELECT @DirectorBranchID = BranchID FROM Staff WHERE StaffID = @DirectorStaffID;
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';

    IF @DirectorBranchID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy chi nhánh cho giám đốc với StaffID = %d.', 16, 1, @DirectorStaffID);
        RETURN;
    END

    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy trạng thái "Đang chờ" cho yêu cầu phê duyệt. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    PRINT N'Các yêu cầu phê duyệt mới từ chi nhánh của bạn (ID: ' + CAST(@DirectorBranchID AS NVARCHAR(10)) + N'):';

    SELECT
        AR.RequestID,
        AR.RequestTitle,
        AR.RequestContent,
        S.FullName AS RequesterName,
        RC.CategoryName AS RequestCategory,
        AR.CreatedDate
    FROM
        ApprovalRequest AR
    JOIN
        Staff S ON AR.RequesterID = S.StaffID
    JOIN
        RequestCategory RC ON AR.CategoryID = RC.CategoryID
    WHERE
        S.BranchID = @DirectorBranchID -- Yêu cầu từ chi nhánh của giám đốc
        AND AR.StatusID = @PendingStatusID -- Trạng thái đang chờ phê duyệt
    ORDER BY
        AR.CreatedDate DESC;

END;
GO

-- Thủ tục SP_GetMyRequestStatusChanges: Hiện thông báo khi trạng thái yêu cầu của nhân viên tạo thay đổi.
-- Ví dụ: EXEC SP_GetMyRequestStatusChanges 1; -- Lấy thông báo thay đổi trạng thái yêu cầu của nhân viên ID 1
CREATE OR ALTER PROCEDURE SP_GetMyRequestStatusChanges
    @StaffID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PendingStatusID INT;
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';

    IF @PendingStatusID IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy trạng thái "Đang chờ" cho yêu cầu phê duyệt. Vui lòng kiểm tra bảng GeneralStatus.', 16, 1);
        RETURN;
    END

    PRINT N'Thông báo về trạng thái yêu cầu của bạn:';

    -- Lấy các yêu cầu đã được tạo bởi nhân viên này và trạng thái đã thay đổi (không còn là "Đang chờ")
    SELECT
        AR.RequestID,
        AR.RequestTitle,
        AR.RequestContent,
        RC.CategoryName AS RequestCategory,
        GS.StatusName AS CurrentStatus,
        AR.LastModifiedDate AS StatusChangeDate,
        AL.Comment AS ApproverComment
    FROM
        ApprovalRequest AR
    JOIN
        RequestCategory RC ON AR.CategoryID = RC.CategoryID
    JOIN
        GeneralStatus GS ON AR.StatusID = GS.StatusID
    LEFT JOIN
        ApprovalLog AL ON AR.RequestID = AL.RequestID AND AL.Action IN ('Approved', 'Rejected') -- Lấy comment của hành động phê duyệt/từ chối
    WHERE
        AR.RequesterID = @StaffID
        AND AR.StatusID <> @PendingStatusID -- Trạng thái đã thay đổi
    ORDER BY
        AR.LastModifiedDate DESC;

END;
GO

-- NEW STORED PROCEDURE FOR CENTRAL BOM
-- Thủ tục SP_GetCentralBOMActivitiesAndNewRequests: Hiển thị tất cả các hoạt động của các chi nhánh và thông báo khi có yêu cầu phê duyệt mới.
-- Thủ tục này dành cho Ban Giám đốc Trung ương (BMTW) hoặc các quản trị viên cấp cao.
-- Ví dụ: EXEC SP_GetCentralBOMActivitiesAndNewRequests 1; -- Giả sử StaffID 1 là một thành viên BMTW
CREATE OR ALTER PROCEDURE SP_GetCentralBOMActivitiesAndNewRequests
    @BMTW_StaffID INT -- ID của nhân viên BMTW hoặc quản trị viên cấp cao
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem nhân viên có vai trò BMTW hoặc Quản trị viên cấp cao không
    IF NOT EXISTS (SELECT 1 FROM Staff_Role SR JOIN Role R ON SR.RoleID = R.RoleID WHERE SR.StaffID = @BMTW_StaffID AND R.RoleName IN (N'BMTW', N'Quản trị viên cấp cao'))
    BEGIN
        RAISERROR(N'Bạn không có quyền truy cập thông tin này. Chỉ BMTW hoặc Quản trị viên cấp cao mới có thể xem.', 16, 1);
        RETURN;
    END

    PRINT N'Tổng hợp hoạt động của tất cả các chi nhánh:';

    -- 1. Giao dịch tài chính từ TẤT CẢ các chi nhánh
    SELECT
        'Financial Transaction' AS ActivityType,
        B.BranchName AS Branch,
        FT.TransactionDate AS ActivityDate,
        TT.TransactionTypeName AS Type,
        FT.Description AS Description,
        FT.Amount AS Amount,
        GS.StatusName AS Status
    FROM
        FinancialTransaction FT
    JOIN
        Branch B ON FT.BranchID = B.BranchID
    JOIN
        TransactionType TT ON FT.TransactionTypeID = TT.TransactionTypeID
    JOIN
        GeneralStatus GS ON FT.StatusID = GS.StatusID
    ORDER BY
        FT.TransactionDate DESC, B.BranchName;

    -- 2. Cập nhật học phí học viên từ TẤT CẢ các chi nhánh
    SELECT
        'Student Tuition Update' AS ActivityType,
        B.BranchName AS Branch,
        ST.LastModified AS ActivityDate,
        S.FullName AS StudentName,
        C.ClassName AS ClassName,
        ST.TotalFee AS OriginalFee,
        ST.FinalFee AS FinalFee,
        ST.AmountPaid AS AmountPaid,
        ST.OutstandingBalance AS Outstanding,
        GS.StatusName AS Status
    FROM
        StudentTuition ST
    JOIN
        Student S ON ST.StudentID = S.StudentID
    JOIN
        Class C ON ST.ClassID = C.ClassID
    JOIN
        Branch B ON S.BranchID = B.BranchID -- Lấy chi nhánh từ học viên
    JOIN
        GeneralStatus GS ON ST.StatusID = GS.StatusID
    ORDER BY
        ST.LastModified DESC, B.BranchName;

    -- 3. Thay đổi thông tin lớp học từ TẤT CẢ các chi nhánh
    SELECT
        'Class Change' AS ActivityType,
        B.BranchName AS Branch,
        C.StartDate AS ActivityDate,
        C.ClassName AS ClassName,
        M.MajorName AS Major,
        S_Main.FullName AS MainTeacher,
        GS.StatusName AS Status,
        C.TrainingProgress AS Progress
    FROM
        Class C
    JOIN
        Major M ON C.MajorID = M.MajorID
    LEFT JOIN
        Staff S_Main ON C.MainTeacherID = S_Main.StaffID
    JOIN
        Branch B ON C.BranchID = B.BranchID
    JOIN
        GeneralStatus GS ON C.StatusID = GS.StatusID
    ORDER BY
        C.StartDate DESC, B.BranchName;

    PRINT N'Thông báo các yêu cầu phê duyệt mới (trạng thái "Đang chờ"):';

    DECLARE @PendingStatusID INT;
    SELECT @PendingStatusID = StatusID FROM GeneralStatus WHERE StatusName = N'Đang chờ' AND StatusType = N'ApprovalRequest';

    IF @PendingStatusID IS NULL
    BEGIN
        PRINT N'Không tìm thấy trạng thái "Đang chờ" cho yêu cầu phê duyệt. Vui lòng kiểm tra bảng GeneralStatus.';
    END
    ELSE
    BEGIN
        SELECT
            AR.RequestID,
            AR.RequestTitle,
            AR.RequestContent,
            S.FullName AS RequesterName,
            B.BranchName AS RequesterBranch,
            RC.CategoryName AS RequestCategory,
            AR.CreatedDate
        FROM
            ApprovalRequest AR
        JOIN
            Staff S ON AR.RequesterID = S.StaffID
        JOIN
            Branch B ON S.BranchID = B.BranchID
        JOIN
            RequestCategory RC ON AR.CategoryID = RC.CategoryID
        WHERE
            AR.StatusID = @PendingStatusID -- Chỉ lấy các yêu cầu đang chờ phê duyệt
        ORDER BY
            AR.CreatedDate DESC;
    END;

END;
GO

--------------------------------------------------------------------------------
-- 6. Triggers
--    Các Trigger tự động thực thi khi có sự kiện (INSERT/UPDATE) trên các bảng.
--    Trigger không trực tiếp "tìm kiếm" hay "update từ UI", mà phản ứng VỚI sự kiện đó.
--------------------------------------------------------------------------------

-- Trigger trg_Staff_AutoCode: Tự động sinh StaffCode và DisplayName khi thêm mới nhân viên.
-- LƯU Ý: Trigger này KHÔNG còn tạo tài khoản. Việc tạo tài khoản sẽ được thực hiện
-- bởi SP_ApproveRequest sau khi yêu cầu thêm nhân viên được phê duyệt.
CREATE OR ALTER TRIGGER trg_Staff_AutoCode
ON Staff
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật StaffCode và DisplayName cho các bản ghi vừa được chèn
    UPDATE S
    SET
        StaffCode = dbo.GenerateStaffCode(),
        DisplayName = dbo.GenerateStaffDisplayName(i.FullName, i.BranchID, i.DepartmentID)
    FROM Staff S
    INNER JOIN inserted i ON S.StaffID = i.StaffID;

    -- Không còn gọi SP_CreateStaffAccount ở đây nữa.
    -- Việc tạo tài khoản sẽ được kích hoạt khi yêu cầu thêm nhân viên được phê duyệt
    -- thông qua SP_ApproveRequest.
END;
GO

-- Trigger trg_Staff_UpdateDisplayName: Cập nhật lại DisplayName khi thông tin nhân viên thay đổi.
CREATE OR ALTER TRIGGER trg_Staff_UpdateDisplayName
ON Staff
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem có bất kỳ cột nào ảnh hưởng đến DisplayName bị thay đổi không
    IF UPDATE(FullName) OR UPDATE(BranchID) OR UPDATE(DepartmentID)
    BEGIN
        UPDATE S
        SET DisplayName = dbo.GenerateStaffDisplayName(i.FullName, i.BranchID, i.DepartmentID)
        FROM Staff S
        INNER JOIN inserted i ON S.StaffID = i.StaffID
        INNER JOIN deleted d ON S.StaffID = d.StaffID
        WHERE
            ISNULL(i.FullName,'') <> ISNULL(d.FullName,'') -- Nếu tên thay đổi
            OR ISNULL(i.BranchID, 0) <> ISNULL(d.BranchID, 0) -- Hoặc chi nhánh thay đổi
            OR ISNULL(i.DepartmentID, 0) <> ISNULL(d.DepartmentID, 0); -- Hoặc phòng ban thay đổi
    END;
END;
GO

-- Trigger trg_Student_AutoCode: Tự động sinh StudentCode khi thêm mới học viên.
-- LƯU Ý: Trigger này chỉ sinh mã. Việc thêm học viên sẽ thông qua phê duyệt.
CREATE OR ALTER TRIGGER trg_Student_AutoCode
ON Student
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE S
    SET StudentCode = dbo.GenerateStudentCode(i.MajorID) -- Gọi hàm sinh mã học viên
    FROM Student S
    INNER JOIN inserted i ON S.StudentID = i.StudentID; -- Chỉ cập nhật các bản ghi vừa được thêm vào
END;
GO

-- Trigger trg_Class_AutoCode: Tự động sinh ClassCode khi thêm mới lớp học.
-- LƯU Ý: Trigger này chỉ sinh mã. Việc thêm lớp học sẽ thông qua phê duyệt.
CREATE OR ALTER TRIGGER trg_Class_AutoCode
ON Class
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE C
    SET ClassCode = dbo.GenerateClassCode(i.BranchID, i.MajorID) -- Gọi hàm sinh mã lớp học
    FROM Class C
    INNER JOIN inserted i ON C.ClassID = i.ClassID; -- Chỉ cập nhật các bản ghi vừa được thêm vào
END;
GO

-- Trigger trg_Staff_LogChanges: Ghi log mọi thay đổi (INSERT/UPDATE/DELETE) trên bảng Staff vào Staff_Log.
-- Đây là ví dụ về cách Trigger có thể được dùng để theo dõi các thao tác dữ liệu,
-- bao gồm cả những thay đổi từ UI (vì UI gửi lệnh UPDATE đến DB).
CREATE OR ALTER TRIGGER trg_Staff_LogChanges
ON Staff
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Ghi log cho thao tác INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'INSERT', GETDATE() FROM inserted;
    END
    -- Ghi log cho thao tác UPDATE
    ELSE IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'UPDATE', GETDATE() FROM inserted;
    END
    -- Ghi log cho thao tác DELETE
    ELSE IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Staff_Log (StaffID, Action, ActionDate)
        SELECT StaffID, 'DELETE', GETDATE() FROM deleted;
    END
END;
GO

-- Trigger trg_Timesheet_CalculateDetails: Tính toán chi tiết chấm công (giờ làm, đi muộn, về sớm)
-- Sau khi INSERT hoặc UPDATE bảng Timesheet.
CREATE OR ALTER TRIGGER trg_Timesheet_CalculateDetails
ON Timesheet
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StandardCheckIn TIME = '08:00:00'; -- Giờ vào chuẩn cho Full-time
    DECLARE @StandardCheckOut TIME = '17:00:00'; -- Giờ ra chuẩn cho Full-time
    DECLARE @LunchBreakMinutes INT = 60; -- Thời gian nghỉ trưa 1 tiếng cho Full-time

    UPDATE TS
    SET
        TotalWorkingHours =
            CASE
                WHEN S.ContractType = N'Full-time' AND i.CheckInTime IS NOT NULL AND i.CheckOutTime IS NOT NULL THEN
                    -- Tính tổng giờ làm (giờ ra - giờ vào - giờ nghỉ trưa) cho Full-time
                    CAST(DATEDIFF(MINUTE, i.CheckInTime, i.CheckOutTime) AS DECIMAL(5,2)) / 60.0
                    - (CASE WHEN DATEDIFF(MINUTE, i.CheckInTime, i.CheckOutTime) > @LunchBreakMinutes THEN @LunchBreakMinutes ELSE 0 END) / 60.0
                WHEN S.ContractType = N'Part-time' AND i.CheckInTime IS NOT NULL AND i.CheckOutTime IS NOT NULL THEN
                    -- Đối với Part-time chỉ tính thời gian thực tế giữa giờ vào và giờ ra, không trừ giờ nghỉ cố định
                    CAST(DATEDIFF(MINUTE, i.CheckInTime, i.CheckOutTime) AS DECIMAL(5,2)) / 60.0
                ELSE NULL
            END,
        IsLate =
            CASE
                WHEN S.ContractType = N'Full-time' AND i.CheckInTime IS NOT NULL AND i.CheckInTime > @StandardCheckIn THEN 1
                ELSE 0
            END,
        IsEarlyLeave =
            CASE
                WHEN S.ContractType = N'Full-time' AND i.CheckOutTime IS NOT NULL AND i.CheckOutTime < @StandardCheckOut THEN 1
                ELSE 0
            END,
        OvertimeHours =
            CASE
                WHEN S.ContractType = N'Full-time' AND i.CheckOutTime IS NOT NULL AND i.CheckOutTime > @StandardCheckOut THEN
                    -- Tính giờ làm thêm (từ giờ ra chuẩn đến giờ ra thực tế)
                    CAST(DATEDIFF(MINUTE, @StandardCheckOut, i.CheckOutTime) AS DECIMAL(5,2)) / 60.0
                ELSE 0
            END
        -- NumberOfClasses sẽ được cập nhật bởi SP_CalculateClassesTaught
    FROM Timesheet TS
    INNER JOIN inserted i ON TS.TimesheetID = i.TimesheetID
    INNER JOIN Staff S ON i.StaffID = S.StaffID;

    -- Sau khi cập nhật giờ làm việc, gọi SP để tính số ca dạy
    -- Sử dụng bảng tạm để tránh lỗi khi có nhiều bản ghi được chèn/cập nhật cùng lúc
    DECLARE @TimesheetIDs TABLE (TimesheetID INT);
    INSERT INTO @TimesheetIDs (TimesheetID) SELECT TimesheetID FROM inserted;

    DECLARE @CurrentTimesheetID INT;
    DECLARE cur CURSOR FOR SELECT TimesheetID FROM @TimesheetIDs;
    OPEN cur;
    FETCH NEXT FROM cur INTO @CurrentTimesheetID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SP_CalculateClassesTaught @CurrentTimesheetID;
        FETCH NEXT FROM cur INTO @CurrentTimesheetID;
    END;
    CLOSE cur;
    DEALLOCATE cur;
END;
GO
