using System;
using System.Windows.Forms;
using Microsoft.Web.WebView2.WinForms;
using System.Threading.Tasks;

namespace HHMS_Ngoaingu68
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }
    }

    public class MainForm : Form
    {
        private WebView2 webView;

        public MainForm()
        {
            InitializeComponents();
        }

        private async void InitializeComponents()
        {
            this.Text = "HHMS Ngoaingu68 - Language Center Management";
            this.Width = 1200;
            this.Height = 800;

            webView = new WebView2
            {
                Dock = DockStyle.Fill
            };
            this.Controls.Add(webView);

            await InitializeWebView();
        }

        private async Task InitializeWebView()
        {
            await webView.EnsureCoreWebView2Async(null);
            // Load the main dashboard page (adjust path as needed)
            webView.CoreWebView2.Navigate("file:///project/sandbox/user-workspace/DashBoard.html");

            // Expose the C# bridge object to JavaScript
            var loginHandler = new LoginHandler(new HHMSDataAccess("Your SQL Server Connection String Here"));
            var uiBridge = new UIBridge(loginHandler);

            webView.CoreWebView2.AddHostObjectToScript("bridge", uiBridge);
        }

        private async Task InitializeWebView()
        {
            await webView.EnsureCoreWebView2Async(null);
            // Load the main dashboard page (adjust path as needed)
            webView.CoreWebView2.Navigate("file:///project/sandbox/user-workspace/DashBoard.html");

            // Expose the C# bridge object to JavaScript
            var loginHandler = new LoginHandler(new HHMSDataAccess("Your SQL Server Connection String Here"));
            var uiBridge = new UIBridge(loginHandler);

            webView.CoreWebView2.AddHostObjectToScript("bridge", uiBridge);
        }
    }
}
