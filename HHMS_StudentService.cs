using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class StudentService
    {
        private readonly HHMSDataAccess dataAccess;

        public StudentService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetStudentsAsync(string searchTerm = null)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@SearchTerm", SqlDbType.NVarChar, 255) { Value = (object)searchTerm ?? DBNull.Value }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetStudents", parameters);
        }

        public async Task<int> AddOrUpdateStudentAsync(
            int? studentId,
            string fullName,
            string gender,
            string idNumber,
            DateTime birthDate,
            string studentAddress,
            string phone,
            string email,
            int branchId,
            int majorId,
            int consultantStaffId,
            string entryLevel,
            string exitLevel,
            int statusId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@StudentID", SqlDbType.Int) { Value = (object)studentId ?? DBNull.Value },
                new SqlParameter("@FullName", SqlDbType.NVarChar, 255) { Value = fullName },
                new SqlParameter("@Gender", SqlDbType.NVarChar, 10) { Value = gender },
                new SqlParameter("@IDNumber", SqlDbType.NVarChar, 50) { Value = idNumber },
                new SqlParameter("@BirthDate", SqlDbType.Date) { Value = birthDate },
                new SqlParameter("@StudentAddress", SqlDbType.NVarChar, 255) { Value = studentAddress },
                new SqlParameter("@Phone", SqlDbType.NVarChar, 20) { Value = phone },
                new SqlParameter("@Email", SqlDbType.NVarChar, 255) { Value = email },
                new SqlParameter("@BranchID", SqlDbType.Int) { Value = branchId },
                new SqlParameter("@MajorID", SqlDbType.Int) { Value = majorId },
                new SqlParameter("@ConsultantStaffID", SqlDbType.Int) { Value = consultantStaffId },
                new SqlParameter("@EntryLevel", SqlDbType.NVarChar, 20) { Value = entryLevel },
                new SqlParameter("@ExitLevel", SqlDbType.NVarChar, 20) { Value = exitLevel },
                new SqlParameter("@StatusID", SqlDbType.Int) { Value = statusId }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_AddOrUpdateStudent", parameters);
        }
    }
}
