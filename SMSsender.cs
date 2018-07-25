using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;


/// <summary>
/// Summary description for SMSsender
/// </summary>
public class SMSsender
{
    public bool SendMySMS(string msg, string mobile)
    {
        string userid = "PNPLRC";
        string pass = "pnplrc@5001";
        string route = "205";
        string senderid = "PNPLRC";
        string APIUrl = "http://sendsms.sandeshwala.com/API/WebSMS/Http/v1.0a/index.php?username=" + userid + "&password=" + pass + "&sender=" + senderid + "&to=" + mobile + "&message=" + msg + "&reqid=1&format={json|text}&route_id=" + route;

        WebClient wc = new WebClient();
        string result = wc.DownloadString(APIUrl);
        if (result != "")
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}