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
        
        [Fact]
        public void Sum_CorrectValue_ReturnSum()
        {
            // arrange
            int value1 = 2;
            int value2 = 3;

            // act
            var result = _calculator.Sum(value1, value2);

            // assert
            Assert.Equal(5, result);
        }        
    }
}
