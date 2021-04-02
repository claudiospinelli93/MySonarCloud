using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Service;

namespace Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CalculatorController : ControllerBase
    {
        private readonly ILogger<CalculatorController> _logger;
        private readonly ICalculator _calculator;

        public CalculatorController(ILogger<CalculatorController> logger, ICalculator calculator)
        {
            _calculator = calculator;
        }

        [HttpGet]
        public ActionResult<int> Sum(int value1, int value2)
        {
            return _calculator.Sum(value1, value2);
        }
    }
}
