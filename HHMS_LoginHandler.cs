using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    public class LoginHandler
    {
        private readonly HHMSDataAccess dataAccess;

        public LoginHandler(HHMSDataAccess dataAccess)
        {
            this.dataAccess = dataAccess;
        }

        public async Task<bool> AuthenticateUserAsync(string username, string password)
        {
            try
            {
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Username", SqlDbType.NVarChar, 100) { Value = username },
                    new SqlParameter("@Password", SqlDbType.NVarChar, 255) { Value = password }
                };

                DataTable result = await dataAccess.ExecuteStoredProcedureAsync("SP_UserLogin", parameters);

                if (result.Rows.Count > 0)
                {
                    // Authentication successful
                    return true;
                }
                else
                {
                    // Authentication failed
                    return false;
                }
            }
            catch (Exception ex)
            {
                // Log exception or handle accordingly
                throw new Exception("Error during user authentication.", ex);
            }
        }
    }
}
