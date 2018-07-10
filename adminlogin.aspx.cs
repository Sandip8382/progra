using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class adminlogin : System.Web.UI.Page
{
    DataBaseManager dbm = new DataBaseManager();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        string query = "select * from adminlogin where adminEmail='" + TextBox1.Text + "' and adminPassword='" + TextBox2.Text + "'";
        DataTable dt = new DataTable();
        dt = dbm.ExecuteSelect(query);
        if (dt.Rows.Count > 0)
        {
            bool status = bool.Parse(dt.Rows[0][2].ToString());
            if (status == true)
            {
                Session["admin"] = TextBox1.Text;
                int logincount = int.Parse(dt.Rows[0][3].ToString());
                logincount++;
                string query2 = "update adminlogin set loginCount='" + logincount + "',lastAdminDateTime='" + DateTime.Now.ToString() + "' where adminEmail='" + TextBox1.Text + "'";
                bool x = dbm.ExecuteIUD(query2);
                if (x)
                {
                    Response.Redirect("~/Admin/Default.aspx");
                }
                else
                {
                    Response.Write("<script>alert('Update query Failed')</script>");
                }
            }
            else
            {
                Response.Write("<script>alert('your login Id Blocked.')</script>");
            }
        }
        else
        {
            Response.Write("<script>alert('Email or password Incurrect.')</script>");
        }

    }
}