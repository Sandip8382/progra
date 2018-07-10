using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class Admin_forgottenPassword : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        string query = "select * from adminlogin where adminEmail='" + TextBox1.Text + "'";
        DataBaseManager dbm = new DataBaseManager();
        DataTable dt = new DataTable();
        dt=dbm.ExecuteSelect(query);
        if (dt.Rows.Count > 0)
        {
            Response.Redirect("ResetPassword.aspx?email="+TextBox1.Text);
        }
        else
        {
            Response.Write("<script>alert('Email Not found.')</script>");
        }
    }
}