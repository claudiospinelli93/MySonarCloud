using System;
using Moq.AutoMock;
using Xunit;

namespace Service.Test
{
    public class CalculatorTest
    {

        private readonly AutoMocker _mocker;
        private readonly Calculator _calculator;
        public CalculatorTest()
        {
            _mocker = new AutoMocker();

            _calculator = _mocker.CreateInstance<Calculator>();
        }
     
    }
}
