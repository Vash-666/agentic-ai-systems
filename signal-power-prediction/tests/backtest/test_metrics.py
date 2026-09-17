"""
Unit tests for metrics calculator
"""

import unittest
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from backtest.metrics import MetricsCalculator, TradeMetrics, DrawdownMetrics, RiskMetrics


class TestMetricsCalculator(unittest.TestCase):
    """Test MetricsCalculator class"""
    
    def setUp(self):
        self.calculator = MetricsCalculator(risk_free_rate=0.02)
        
        # Create sample equity curve
        dates = pd.date_range(start='2023-01-01', periods=252, freq='D')
        np.random.seed(42)
        
        # Generate realistic equity curve with some volatility
        returns = np.random.normal(0.0005, 0.02, 252)
        equity = 100000 * np.cumprod(1 + returns)
        
        self.equity_curve = pd.DataFrame({
            'timestamp': dates,
            'equity': equity
        })
    
    def test_initialization(self):
        calc = MetricsCalculator(risk_free_rate=0.05)
        self.assertEqual(calc.risk_free_rate, 0.05)
    
    def test_calculate_return_metrics(self):
        metrics = self.calculator.calculate_return_metrics(
            self.equity_curve,
            initial_capital=100000.0
        )
        
        self.assertIn('total_return', metrics)
        self.assertIn('cagr', metrics)
        self.assertIn('initial_capital', metrics)
        self.assertIn('final_equity', metrics)
        
        self.assertEqual(metrics['initial_capital'], 100000.0)
        self.assertGreater(metrics['final_equity'], 0)
    
    def test_calculate_drawdown_metrics(self):
        metrics = self.calculator.calculate_drawdown_metrics(self.equity_curve)
        
        self.assertIn('max_drawdown', metrics)
        self.assertIn('max_drawdown_duration', metrics)
        self.assertIn('avg_drawdown', metrics)
        self.assertIn('underwater_ratio', metrics)
        
        # Max drawdown should be negative or zero
        self.assertLessEqual(metrics['max_drawdown'], 0)
        self.assertGreaterEqual(metrics['max_drawdown_duration'], 0)
    
    def test_calculate_risk_metrics(self):
        metrics = self.calculator.calculate_risk_metrics(self.equity_curve)
        
        self.assertIn('sharpe_ratio', metrics)
        self.assertIn('sortino_ratio', metrics)
        self.assertIn('volatility', metrics)
        self.assertIn('var_95', metrics)
        self.assertIn('cvar_95', metrics)
        
        # Volatility should be positive
        self.assertGreater(metrics['volatility'], 0)
    
    def test_calculate_trade_metrics(self):
        # Create mock trades
        class MockTrade:
            def __init__(self, pnl):
                self.pnl = pnl
        
        trades = [
            MockTrade(100),
            MockTrade(-50),
            MockTrade(200),
            MockTrade(-30),
            MockTrade(150),
        ]
        
        metrics = self.calculator.calculate_trade_metrics(trades)
        
        self.assertEqual(metrics['total_trades'], 5)
        self.assertEqual(metrics['winning_trades'], 3)
        self.assertEqual(metrics['losing_trades'], 2)
        self.assertAlmostEqual(metrics['win_rate'], 0.6)
        self.assertGreater(metrics['profit_factor'], 0)
    
    def test_calculate_trade_metrics_empty(self):
        metrics = self.calculator.calculate_trade_metrics([])
        self.assertEqual(metrics['total_trades'], 0)
    
    def test_calculate_all(self):
        # Create mock trades
        class MockTrade:
            def __init__(self, pnl):
                self.pnl = pnl
        
        trades = [MockTrade(100), MockTrade(-50), MockTrade(200)]
        
        metrics = self.calculator.calculate_all(
            equity_curve=self.equity_curve,
            trades=trades,
            initial_capital=100000.0
        )
        
        # Should include all metric types
        self.assertIn('total_return', metrics)
        self.assertIn('max_drawdown', metrics)
        self.assertIn('sharpe_ratio', metrics)
        self.assertIn('total_trades', metrics)
        self.assertIn('win_rate', metrics)
    
    def test_calculate_calmar_ratio(self):
        calmar = self.calculator.calculate_calmar_ratio(
            cagr=0.10,
            max_drawdown=-0.20
        )
        self.assertEqual(calmar, 0.5)
    
    def test_calculate_calmar_ratio_no_drawdown(self):
        calmar = self.calculator.calculate_calmar_ratio(
            cagr=0.10,
            max_drawdown=0.0
        )
        self.assertEqual(calmar, 0.0)
    
    def test_calculate_beta_alpha(self):
        # Create correlated returns
        np.random.seed(42)
        benchmark_returns = pd.Series(np.random.normal(0.0005, 0.01, 100))
        strategy_returns = 0.8 * benchmark_returns + pd.Series(np.random.normal(0, 0.005, 100))
        
        result = self.calculator.calculate_beta_alpha(
            strategy_returns,
            benchmark_returns
        )
        
        self.assertIn('beta', result)
        self.assertIn('alpha', result)
        self.assertIn('alpha_annualized', result)
    
    def test_generate_summary(self):
        metrics = {
            'total_return_pct': 15.5,
            'cagr_pct': 12.0,
            'sharpe_ratio': 1.2,
            'max_drawdown_pct': -10.0,
            'win_rate_pct': 55.0,
            'profit_factor': 1.5
        }
        
        summary = self.calculator.generate_summary(metrics)
        
        self.assertIn('BACKTEST PERFORMANCE SUMMARY', summary)
        self.assertIn('15.50%', summary)
        self.assertIn('1.200', summary)
        self.assertIn('-10.00%', summary)
    
    def test_generate_summary_with_trades(self):
        metrics = {
            'total_return_pct': 15.5,
            'cagr_pct': 12.0,
            'sharpe_ratio': 1.2,
            'max_drawdown_pct': -10.0,
            'win_rate_pct': 55.0,
            'profit_factor': 1.5,
            'total_trades': 100,
            'expectancy': 50.0
        }
        
        summary = self.calculator.generate_summary(metrics)
        
        self.assertIn('Trade Statistics:', summary)
        self.assertIn('100', summary)


class TestMetricsDataclasses(unittest.TestCase):
    """Test metrics dataclasses"""
    
    def test_trade_metrics_defaults(self):
        metrics = TradeMetrics()
        self.assertEqual(metrics.total_trades, 0)
        self.assertEqual(metrics.win_rate, 0.0)
    
    def test_drawdown_metrics_defaults(self):
        metrics = DrawdownMetrics()
        self.assertEqual(metrics.max_drawdown, 0.0)
        self.assertEqual(metrics.max_drawdown_duration, 0)
    
    def test_risk_metrics_defaults(self):
        metrics = RiskMetrics()
        self.assertEqual(metrics.sharpe_ratio, 0.0)
        self.assertEqual(metrics.volatility, 0.0)


if __name__ == '__main__':
    unittest.main()
