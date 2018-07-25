using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net;  /// for network connect
using System.Net.Mail; /// for mail SMTP server create

/// <summary>
/// Summary description for EmailSender
/// </summary>
public class EmailSender
{
    public bool SendMyEmail(string to, string subject, string message)
    {
        string username = "sandipkumargzp@gmail.com";
        string password="8948656462";
        SmtpClient Client = new SmtpClient();
        MailMessage msg = new MailMessage();
        MailAddress from = new MailAddress(username);
        MailAddress sendto = new MailAddress(to);
        //SMTP SETTING
        NetworkCredential nc = new NetworkCredential(username, password);
        Client.EnableSsl = true;
        Client.Host = "smtp.gmail.com";
        Client.UseDefaultCredentials = false;
        Client.Port = 587;
        Client.Credentials = nc;

        // mail message settings

        msg.IsBodyHtml = true;
        msg.Sender = from;
        msg.From = from;
        msg.Subject = subject;
        msg.To.Add(sendto);
        msg.Body = message;

        Client.Send(msg);
        return true;


    }

}