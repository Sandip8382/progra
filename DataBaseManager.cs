using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// Summary description for DataBaseManager
/// </summary>
public class DataBaseManager
{
    SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["myconnection"].ToString());
    public bool ExecuteIUD(string query)
    {
        SqlCommand cmd = new SqlCommand(query, con);
        int x = 0;
        try
        {
            con.Open();
            x = cmd.ExecuteNonQuery();
        }
        catch (Exception)
        {
            x = 0;
        }
        finally
        {
            con.Close();
        }
        if (x > 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public DataTable ExecuteSelect(string query)
    {
        SqlDataAdapter sqlda = new SqlDataAdapter(query,con);
        DataTable dt = new DataTable();
        sqlda.Fill(dt);
        return dt;
    }
	
}