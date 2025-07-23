using System;
using System.Threading.Tasks;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;

namespace HHMS_Ngoaingu68
{
    public class UIBridge
    {
        private readonly LoginHandler loginHandler;

        public UIBridge(LoginHandler loginHandler)
        {
            this.loginHandler = loginHandler;
        }

        // This method will be called from JavaScript in WebView2 for login
        public async Task<string> Login(string username, string password)
        {
            try
            {
                bool isAuthenticated = await loginHandler.AuthenticateUserAsync(username, password);
                if (isAuthenticated)
                {
                    return "{\"success\": true, \"message\": \"Đăng nhập thành công!\"}";
                }
                else
                {
                    return "{\"success\": false, \"message\": \"Tên đăng nhập hoặc mật khẩu không đúng.\"}";
                }
            }
            catch (Exception ex)
            {
                return $"{{\"success\": false, \"message\": \"Lỗi hệ thống: {ex.Message}\"}}";
            }
        }
    }
}
