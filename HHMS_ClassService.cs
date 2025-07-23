using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class ClassService
    {
        private readonly HHMSDataAccess dataAccess;

        public ClassService(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<DataTable> GetClassesAsync(string searchTerm = null)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@SearchTerm", SqlDbType.NVarChar, 255) { Value = (object)searchTerm ?? DBNull.Value }
            };

            return await dataAccess.ExecuteStoredProcedureAsync("SP_GetClasses", parameters);
        }

        public async Task<int> AddOrUpdateClassAsync(
            int? classId,
            string className,
            int majorId,
            int branchId,
            int mainTeacherId,
            int assistantId,
            string room,
            DateTime startDate,
            DateTime expectedEndDate,
            string trainingProgress,
            int statusId)
        {
            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@ClassID", SqlDbType.Int) { Value = (object)classId ?? DBNull.Value },
                new SqlParameter("@ClassName", SqlDbType.NVarChar, 255) { Value = className },
                new SqlParameter("@MajorID", SqlDbType.Int) { Value = majorId },
                new SqlParameter("@BranchID", SqlDbType.Int) { Value = branchId },
                new SqlParameter("@MainTeacherID", SqlDbType.Int) { Value = mainTeacherId },
                new SqlParameter("@AssistantID", SqlDbType.Int) { Value = assistantId },
                new SqlParameter("@Room", SqlDbType.NVarChar, 50) { Value = room },
                new SqlParameter("@StartDate", SqlDbType.Date) { Value = startDate },
                new SqlParameter("@ExpectedEndDate", SqlDbType.Date) { Value = expectedEndDate },
                new SqlParameter("@TrainingProgress", SqlDbType.NVarChar, 255) { Value = trainingProgress },
                new SqlParameter("@StatusID", SqlDbType.Int) { Value = statusId }
            };

            return await dataAccess.ExecuteNonQueryAsync("SP_AddOrUpdateClass", parameters);
        }
    }
}
