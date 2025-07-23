using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class BranchService
    {
        private readonly HHMSDataAccess dataAccess;

        public BranchService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetBranchesAsync(string searchTerm = null)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@SearchTerm", SqlDbType.NVarChar, 255) { Value = (object)searchTerm ?? DBNull.Value }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetBranches", parameters);
        }

        public async Task<int> AddOrUpdateBranchAsync(
            int? branchId,
            string branchCode,
            string branchName,
            string branchAddress,
            string branchLicense,
            string branchDirector,
            int statusId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@BranchID", SqlDbType.Int) { Value = (object)branchId ?? DBNull.Value },
                new SqlParameter("@BranchCode", SqlDbType.NVarChar, 20) { Value = branchCode },
                new SqlParameter("@BranchName", SqlDbType.NVarChar, 255) { Value = branchName },
                new SqlParameter("@BranchAddress", SqlDbType.NVarChar, 255) { Value = branchAddress },
                new SqlParameter("@BranchLicense", SqlDbType.NVarChar, 255) { Value = branchLicense },
                new SqlParameter("@BranchDirector", SqlDbType.NVarChar, 255) { Value = branchDirector },
                new SqlParameter("@StatusID", SqlDbType.Int) { Value = statusId }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_AddOrUpdateBranch", parameters);
        }
    }
}
