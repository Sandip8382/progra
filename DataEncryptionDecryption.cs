using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for DataEncryptionDecryption
/// </summary>
public class DataEncryptionDecryption
{
    public string EncryptMyData(string str)
    {
        string newstring = "";
        int ascii;
        foreach (char ch in str)
        {
            ascii = ch;
            ascii = ascii + 5;
            newstring = newstring + (char)ascii;
        }
        return newstring;
    }
    
    public string DecryptMyData(string str)
    {
        string newstring = "";
        int ascii;
        foreach (char ch in str)
        {
            ascii = ch;
            ascii = ascii - 5;
            newstring = newstring + (char)ascii;
        }
        return newstring;
    }
}