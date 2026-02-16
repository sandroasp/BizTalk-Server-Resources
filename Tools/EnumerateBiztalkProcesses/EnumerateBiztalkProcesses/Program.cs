using System;
using System.Management;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Net;
namespace EnumerateBiztalkProcesses
{
    ///
    /// Summary description for Class1.
    ///

    class EnumerateBiztalkProcesses
    {
        ///
        /// The main entry point for the application.
        ///

        [STAThread]
        private static void Main(string[] args)
        {
            try
            {
                uint nStdHandle = 0xfffffff5;
                IntPtr hConsoleOutput = GetStdHandle(nStdHandle);
                EnumerationOptions options = new EnumerationOptions();
                options.ReturnImmediately = false;
                string hostName = Dns.GetHostName();
                ManagementObjectSearcher searcher = new ManagementObjectSearcher(@"root\MicrosoftBizTalkServer", "Select * from MSBTS_HostInstance where HostType = 1 and ServiceState = 4 and RunningServer = '" + hostName + "'", options);
                //Todo : Check to see if any BizTalk host is running !
                SetConsoleTextAttribute(hConsoleOutput, 15);
                Console.WriteLine("BiztalkHost ProcessId Memory ");
                Console.WriteLine("--------------------------------------------------------------------------------");
                foreach (ManagementObject obj2 in searcher.Get())
                {
                    string text2 = (string)obj2["HostName"];
                    PerformanceCounter counter = new PerformanceCounter("BizTalk:Messaging", "ID Process", true);
                    counter.InstanceName = text2;
                    float num3 = counter.NextValue();
                    Process processById = Process.GetProcessById(Convert.ToInt32(num3));
                    Console.WriteLine(string.Concat(new object[] { text2, new string(' ', 40 - text2.Length), num3, new string(' ', 15 - Convert.ToString(num3).Length), string.Format("{0:0,0} Kb", Convert.ToInt32((int)(processById.WorkingSet / 0x400))) }));
                }
                Console.WriteLine();
                Console.WriteLine("Press any key to exit ...");
                int num2 = Console.Read();
            }
            catch (Exception exception)
            {
                Console.WriteLine(exception);
            }
        }
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetStdHandle(uint nStdHandle);
        [DllImport("kernel32.dll")]
        public static extern bool SetConsoleTextAttribute(IntPtr hConsoleOutput, int wAttributes);
    }
}