using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class StaffService
    {
        private readonly HHMSDataAccess dataAccess;

        public StaffService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetStaffAsync(string searchTerm = null)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@SearchTerm", SqlDbType.NVarChar, 255) { Value = (object)searchTerm ?? DBNull.Value }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetStaff", parameters);
        }

        public async Task<int> AddOrUpdateStaffAsync(
            int? staffId,
            string fullName,
            string gender,
            string idNumber,
            DateTime birthDate,
            string staffAddress,
            string phone,
            string email,
            int branchId,
            int departmentId,
            string position,
            string contractType,
            DateTime dateJoined,
            int statusId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@StaffID", SqlDbType.Int) { Value = (object)staffId ?? DBNull.Value },
                new SqlParameter("@FullName", SqlDbType.NVarChar, 255) { Value = fullName },
                new SqlParameter("@Gender", SqlDbType.NVarChar, 10) { Value = gender },
                new SqlParameter("@IDNumber", SqlDbType.NVarChar, 50) { Value = idNumber },
                new SqlParameter("@BirthDate", SqlDbType.Date) { Value = birthDate },
                new SqlParameter("@StaffAddress", SqlDbType.NVarChar, 255) { Value = staffAddress },
                new SqlParameter("@Phone", SqlDbType.NVarChar, 20) { Value = phone },
                new SqlParameter("@Email", SqlDbType.NVarChar, 255) { Value = email },
                new SqlParameter("@BranchID", SqlDbType.Int) { Value = branchId },
                new SqlParameter("@DepartmentID", SqlDbType.Int) { Value = departmentId },
                new SqlParameter("@Position", SqlDbType.NVarChar, 100) { Value = position },
                new SqlParameter("@ContractType", SqlDbType.NVarChar, 50) { Value = contractType },
                new SqlParameter("@DateJoined", SqlDbType.Date) { Value = dateJoined },
                new SqlParameter("@StatusID", SqlDbType.Int) { Value = statusId }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_AddOrUpdateStaff", parameters);
        }
    }
}
