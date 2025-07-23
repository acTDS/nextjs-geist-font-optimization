using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class HHMSDataAccess
    {
        private readonly string connectionString;

        public HHMSDataAccess(string connectionString)
        {
            this.connectionString = connectionString;
        }

        public async Task<DataTable> ExecuteStoredProcedureAsync(string storedProcedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(storedProcedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    DataTable dt = new DataTable();
                    await conn.OpenAsync();
                    using (SqlDataReader reader = await cmd.ExecuteReaderAsync())
                    {
                        dt.Load(reader);
                    }
                    return dt;
                }
            }
        }

        public async Task<int> ExecuteNonQueryAsync(string storedProcedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(storedProcedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    await conn.OpenAsync();
                    return await cmd.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task<object> ExecuteScalarAsync(string storedProcedureName, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(storedProcedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    await conn.OpenAsync();
                    return await cmd.ExecuteScalarAsync();
                }
            }
        }
    }
}
