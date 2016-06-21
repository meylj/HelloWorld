using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.IO.Ports;

namespace ConsoleGetPath
{
    class Program
    {
        static void Main(string[] args)
        {
            File.Delete("c:\\FATool\\Uart_Path.txt");
            File.Delete("c:\\FATool\\Uart_send.txt");
            string[] IPortList = SerialPort.GetPortNames();
            string strPath = "";
            for (int i = 0; i < IPortList.Length; i++)
            {
                System.Console.WriteLine(IPortList[i]);

                SerialPort port = new SerialPort(IPortList[i], 115200);
                port.Open();
                port.WriteLine("sn");
                port.ReadTimeout = 500;

                try
                {
                    System.Console.WriteLine(port.ReadTo(":-)"));
                }
                catch (Exception)
                {
                    port.Close();
                    continue;
                }

                strPath = port.PortName;
                port.Close();
                break;
            }
            if (!strPath.Equals(""))
            {
                FileStream fs = new FileStream("c:\\FATool\\Uart_Path.txt", FileMode.Create);
                StreamWriter sw = new StreamWriter(fs);
                sw.Write(strPath);
                sw.Flush();
                sw.Close();
                fs.Close();
            }
        }
    }
}
