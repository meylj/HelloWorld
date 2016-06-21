using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.IO.Ports;

namespace ConsoleFATool
{
    class Program
    {
        static int Main(string[] args)
        {
            string sendmessage = "";
            for (int i = 0; i < args.Length; i++)
                sendmessage += args[i] + " ";
            System.Console.WriteLine(sendmessage);
            if (null == sendmessage || sendmessage.Equals(""))
            {
                return 0;
            }
            File.Delete("c:\\FATool\\Uart_Receive.txt");
            StreamReader readerPath = new StreamReader("c:\\FATool\\Uart_Path.txt");
            string strPath = readerPath.ReadLine();
            string[] IPortList = SerialPort.GetPortNames();
            string strReceive = "";
            if (strPath != null && strPath != "")
            {
                SerialPort port = new SerialPort(strPath, 115200);
                port.Open();
                //StreamReader reader = new StreamReader("c:\\FATool\\Uart_Send.txt");
                //string sLine = reader.ReadLine();
                //System.Console.WriteLine(sLine)
                port.WriteLine(sendmessage);
                port.ReadTimeout = 10000;

                try
                {
                    strReceive = port.ReadTo(":-)");
                    System.Console.WriteLine(strReceive);
                }
                catch (Exception)
                {

                }
                finally
                {
                    port.Close();
                }
                if (null != strReceive && !strReceive.Equals(""))
                {
                    FileStream fs = new FileStream("c:\\FATool\\Uart_Receive.txt", FileMode.Create);
                    StreamWriter sw = new StreamWriter(fs);
                    sw.Write(strReceive);
                    sw.Flush();
                    sw.Close();
                    fs.Close();
                }
            }
            return 0;
        }
    }
}
