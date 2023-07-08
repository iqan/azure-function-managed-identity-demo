using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace ServicebusTriggerDemo
{
    public class DemoServicebusTrigger
    {
        private readonly ILogger<DemoServicebusTrigger> _logger;

        public DemoServicebusTrigger(ILogger<DemoServicebusTrigger> log)
        {
            _logger = log;
        }

        [FunctionName("DemoServicebusTrigger")]
        public void Run([ServiceBusTrigger("demotopic", "demosub", Connection = "demoservicebus")]string mySbMsg)
        {
            _logger.LogInformation($"C# ServiceBus topic trigger function processed message: {mySbMsg}");
        }
    }
}
