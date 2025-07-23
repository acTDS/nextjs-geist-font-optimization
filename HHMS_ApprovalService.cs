using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class ApprovalService
    {
        private readonly HHMSDataAccess dataAccess;

        public ApprovalService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetPendingRequestsAsync(int staffId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@StaffID", SqlDbType.Int) { Value = staffId }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetPendingRequestsForStaff", parameters);
        }

        public async Task<int> ApproveRequestAsync(int requestId, int approverStaffId, string mailProfileName)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@RequestID", SqlDbType.Int) { Value = requestId },
                new SqlParameter("@ApproverStaffID", SqlDbType.Int) { Value = approverStaffId },
                new SqlParameter("@MailProfileName", SqlDbType.NVarChar, 128) { Value = mailProfileName }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_ApproveRequest", parameters);
        }

        public async Task<int> RejectRequestAsync(int requestId, int approverStaffId, string comment)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@RequestID", SqlDbType.Int) { Value = requestId },
                new SqlParameter("@ApproverStaffID", SqlDbType.Int) { Value = approverStaffId },
                new SqlParameter("@Comment", SqlDbType.NVarChar, 500) { Value = comment }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_RejectRequest", parameters);
        }
    }
}
