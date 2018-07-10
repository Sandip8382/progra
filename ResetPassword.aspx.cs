using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_ResetPassword : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        if (TextBox1.Text == TextBox2.Text)
        {
            if (!String.IsNullOrEmpty(Request.QueryString["email"]))
            {
                string email = Request.QueryString["email"];
                string query = "update adminlogin set adminPassword='" + TextBox1.Text + "' where adminEmail='" + email + "'";
                DataBaseManager dbm = new DataBaseManager();
                bool x = dbm.ExecuteIUD(query);
                if (x)
                {
                    System.Threading.Thread.Sleep(5);
                    Response.Redirect("../adminlogin.aspx");
                    Response.Write("<script>alert('Password Changed.')</script>");
                }
                else
                {
                    Response.Write("<script>alert('Password Not Changed.')</script>");
                }
            }
            else
            {
                Response.Redirect("forgottenPassword.aspx");
            }
        }
        else
        {
            Response.Write("<script>alert('New Password Not match')</script>");
        }
    }
}