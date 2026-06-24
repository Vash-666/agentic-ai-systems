"""
Unit tests for reporting module
"""

import unittest
from datetime import datetime
from pathlib import Path
import tempfile
import json
import pandas as pd
import numpy as np
import sys

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from backtest.reporting import ReportGenerator


class TestReportGenerator(unittest.TestCase):
    """Test ReportGenerator class"""
    
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.generator = ReportGenerator(output_dir=self.temp_dir)
        
        # Create sample data
        dates = pd.date_range(start='2023-01-01', periods=100, freq='D')
        np.random.seed(42)
        equity = 100000 + np.cumsum(np.random.randn(100) * 100)
        
        self.equity_curve = pd.DataFrame({
            'timestamp': dates,
            'equity': equity,
            'cash': equity * 0.5,
            'positions': np.random.randint(0, 5, 100)
        })
        
        self.metrics = {
            'initial_capital': 100000.0,
            'final_equity': 110000.0,
            'total_return': 0.10,
            'total_return_pct': 10.0,
            'cagr': 0.15,
            'cagr_pct': 15.0,
            'sharpe_ratio': 1.2,
            'sortino_ratio': 1.5,
            'max_drawdown': -0.05,
            'max_drawdown_pct': -5.0,
            'max_drawdown_duration': 10,
            'volatility_annualized': 0.20,
            'win_rate': 0.55,
            'total_trades': 100
        }
        
        # Mock trades
        class MockTrade:
            def __init__(self, i):
                self.trade_id = f'trade_{i}'
                self.order_id = f'order_{i}'
                self.symbol = 'TEST'
                self.side = 'BUY' if i % 2 == 0 else 'SELL'
                self.quantity = 10
                self.price = 100.0 + i
                self.commission = 1.0
                self.timestamp = datetime.now()
        
        self.trades = [MockTrade(i) for i in range(10)]
    
    def test_initialization(self):
        gen = ReportGenerator(output_dir='/tmp/reports')
        self.assertEqual(str(gen.output_dir), '/tmp/reports')
    
    def test_generate_text_report(self):
        report = self.generator.generate_text_report(self.metrics)
        
        self.assertIn('BACKTEST PERFORMANCE REPORT', report)
        self.assertIn('Total Return:', report)
        self.assertIn('10.00%', report)
        self.assertIn('Sharpe Ratio:', report)
        self.assertIn('1.200', report)
    
    def test_generate_json_report(self):
        json_str = self.generator.generate_json_report(
            self.metrics,
            self.equity_curve,
            self.trades
        )
        
        # Verify it's valid JSON
        data = json.loads(json_str)
        self.assertIn('metrics', data)
        self.assertIn('equity_curve', data)
        self.assertIn('trades', data)
        self.assertIn('generated_at', data)
    
    def test_generate_html_report(self):
        html = self.generator.generate_html_report(
            self.metrics,
            self.equity_curve,
            self.trades
        )
        
        self.assertIn('<!DOCTYPE html>', html)
        self.assertIn('<title>Backtest Report</title>', html)
        self.assertIn('10.00%', html)
        self.assertIn('1.200', html)
    
    def test_generate_csv_report(self):
        filepath = self.generator.generate_csv_report(
            self.equity_curve,
            filename='test_equity.csv'
        )
        
        self.assertTrue(filepath.exists())
        
        # Verify content
        df = pd.read_csv(filepath)
        self.assertEqual(len(df), 100)
        self.assertIn('equity', df.columns)
    
    def test_generate_trade_log_csv(self):
        filepath = self.generator.generate_trade_log_csv(
            self.trades,
            filename='test_trades.csv'
        )
        
        self.assertTrue(filepath.exists())
        
        # Verify content
        df = pd.read_csv(filepath)
        self.assertEqual(len(df), 10)
    
    def test_generate_trade_log_csv_empty(self):
        filepath = self.generator.generate_trade_log_csv([], filename='empty_trades.csv')
        self.assertIsNone(filepath)
    
    def test_save_text_report(self):
        filepath = self.generator.save_text_report(
            self.metrics,
            filename='test_report.txt'
        )
        
        self.assertTrue(filepath.exists())
        
        # Verify content
        with open(filepath, 'r') as f:
            content = f.read()
            self.assertIn('BACKTEST PERFORMANCE REPORT', content)
    
    def test_save_html_report(self):
        filepath = self.generator.save_html_report(
            self.metrics,
            self.equity_curve,
            filename='test_report.html'
        )
        
        self.assertTrue(filepath.exists())
        
        # Verify content
        with open(filepath, 'r') as f:
            content = f.read()
            self.assertIn('<!DOCTYPE html>', content)
    
    def test_save_json_report(self):
        filepath = self.generator.save_json_report(
            self.metrics,
            self.equity_curve,
            filename='test_report.json'
        )
        
        self.assertTrue(filepath.exists())
        
        # Verify content
        with open(filepath, 'r') as f:
            data = json.load(f)
            self.assertIn('metrics', data)
    
    def test_generate_full_report(self):
        report = self.generator.generate_full_report(
            results={'test': 'data'},
            metrics=self.metrics,
            equity_curve=self.equity_curve,
            trades=self.trades,
            save=True,
            filename_prefix='full_test'
        )
        
        self.assertIn('metadata', report)
        self.assertIn('summary', report)
        self.assertIn('metrics', report)
        self.assertIn('equity_curve', report)
        self.assertIn('trades', report)
        
        # Check files were saved
        json_file = Path(self.temp_dir) / 'full_test_report.json'
        self.assertTrue(json_file.exists())
    
    def test_format_equity_curve(self):
        formatted = self.generator._format_equity_curve(self.equity_curve)
        
        self.assertIsInstance(formatted, list)
        self.assertEqual(len(formatted), 100)
        self.assertIn('equity', formatted[0])
    
    def test_format_trades(self):
        formatted = self.generator._format_trades(self.trades)
        
        self.assertIsInstance(formatted, list)
        self.assertEqual(len(formatted), 10)
        self.assertIn('trade_id', formatted[0])
        self.assertIn('symbol', formatted[0])
    
    def test_generate_chart_data(self):
        chart_data = self.generator._generate_chart_data(
            self.equity_curve,
            self.metrics
        )
        
        self.assertIn('equity_curve', chart_data)
        self.assertIn('drawdown', chart_data)
        self.assertIn('returns_distribution', chart_data)
    
    def test_serialize_metrics(self):
        metrics_with_numpy = {
            'float_val': 1.5,
            'int_val': np.int64(10),
            'np_float': np.float64(3.14),
            'array': np.array([1, 2, 3])
        }
        
        serialized = self.generator._serialize_metrics(metrics_with_numpy)
        
        self.assertIsInstance(serialized['int_val'], float)
        self.assertIsInstance(serialized['np_float'], float)
        self.assertIsInstance(serialized['array'], list)


if __name__ == '__main__':
    unittest.main()
