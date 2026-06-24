"""
Unit tests for backtest engine
"""

import unittest
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
import sys
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from backtest.engine import (
    BacktestEngine, Order, OrderSide, OrderType, 
    Position, Trade, Portfolio, Strategy
)


class MockStrategy:
    """Mock strategy for testing"""
    
    def __init__(self):
        self.orders_to_place = []
        self.start_called = False
        self.end_called = False
    
    def on_data(self, timestamp, data, portfolio):
        # Simple strategy: buy when price < 105, sell when > 110
        close = data['close']
        orders = []
        
        if close < 105 and portfolio.cash > 10000:
            orders.append(Order(
                symbol='TEST',
                side=OrderSide.BUY,
                quantity=10,
                order_type=OrderType.MARKET
            ))
        elif close > 110 and 'TEST' in portfolio.positions:
            orders.append(Order(
                symbol='TEST',
                side=OrderSide.SELL,
                quantity=10,
                order_type=OrderType.MARKET
            ))
        
        return orders
    
    def on_start(self, portfolio):
        self.start_called = True
    
    def on_end(self, portfolio):
        self.end_called = True


class TestOrder(unittest.TestCase):
    """Test Order dataclass"""
    
    def test_order_creation(self):
        order = Order(
            symbol='AAPL',
            side=OrderSide.BUY,
            quantity=100,
            order_type=OrderType.MARKET,
            price=150.0
        )
        
        self.assertEqual(order.symbol, 'AAPL')
        self.assertEqual(order.side, OrderSide.BUY)
        self.assertEqual(order.quantity, 100)
        self.assertEqual(order.order_type, OrderType.MARKET)
        self.assertEqual(order.price, 150.0)
        self.assertIsNotNone(order.order_id)
        self.assertIsNotNone(order.timestamp)
    
    def test_order_auto_id(self):
        order = Order(symbol='TEST', side=OrderSide.SELL, quantity=50)
        self.assertIsNotNone(order.order_id)
        self.assertTrue(order.order_id.startswith('order_'))


class TestPosition(unittest.TestCase):
    """Test Position dataclass"""
    
    def test_long_position(self):
        pos = Position(symbol='AAPL', quantity=100, avg_entry_price=150.0)
        self.assertTrue(pos.is_long)
        self.assertFalse(pos.is_short)
        self.assertEqual(pos.get_market_value(160.0), 16000.0)
    
    def test_short_position(self):
        pos = Position(symbol='AAPL', quantity=-100, avg_entry_price=150.0)
        self.assertFalse(pos.is_long)
        self.assertTrue(pos.is_short)


class TestTrade(unittest.TestCase):
    """Test Trade dataclass"""
    
    def test_trade_creation(self):
        trade = Trade(
            order_id='order_123',
            symbol='AAPL',
            side=OrderSide.BUY,
            quantity=100,
            price=150.0,
            timestamp=datetime.now(),
            commission=15.0
        )
        
        self.assertEqual(trade.symbol, 'AAPL')
        self.assertEqual(trade.quantity, 100)
        self.assertEqual(trade.commission, 15.0)
        self.assertIsNotNone(trade.trade_id)


class TestPortfolio(unittest.TestCase):
    """Test Portfolio class"""
    
    def setUp(self):
        self.portfolio = Portfolio(cash=100000.0)
    
    def test_initial_state(self):
        self.assertEqual(self.portfolio.cash, 100000.0)
        self.assertEqual(len(self.portfolio.positions), 0)
        self.assertEqual(len(self.portfolio.trades), 0)
    
    def test_total_value_no_positions(self):
        self.assertEqual(self.portfolio.get_total_value(), 100000.0)
    
    def test_update_position_buy(self):
        trade = Trade(
            order_id='order_1',
            symbol='AAPL',
            side=OrderSide.BUY,
            quantity=100,
            price=150.0,
            timestamp=datetime.now(),
            commission=15.0
        )
        
        self.portfolio.update_position(trade)
        
        self.assertEqual(len(self.portfolio.positions), 1)
        self.assertEqual(len(self.portfolio.trades), 1)
        self.assertEqual(self.portfolio.positions['AAPL'].quantity, 100)
        self.assertEqual(self.portfolio.positions['AAPL'].avg_entry_price, 150.0)
    
    def test_update_position_sell(self):
        # First buy
        buy_trade = Trade(
            order_id='order_1',
            symbol='AAPL',
            side=OrderSide.BUY,
            quantity=100,
            price=150.0,
            timestamp=datetime.now(),
            commission=15.0
        )
        self.portfolio.update_position(buy_trade)
        
        # Then sell
        sell_trade = Trade(
            order_id='order_2',
            symbol='AAPL',
            side=OrderSide.SELL,
            quantity=100,
            price=160.0,
            timestamp=datetime.now(),
            commission=16.0
        )
        self.portfolio.update_position(sell_trade)
        
        self.assertEqual(len(self.portfolio.positions), 0)
        self.assertEqual(len(self.portfolio.trades), 2)


class TestBacktestEngine(unittest.TestCase):
    """Test BacktestEngine class"""
    
    def setUp(self):
        self.engine = BacktestEngine(
            initial_capital=100000.0,
            commission_rate=0.001,
            slippage=0.0001
        )
        
        # Create sample data
        dates = pd.date_range(start='2023-01-01', periods=100, freq='D')
        np.random.seed(42)
        prices = 100 + np.cumsum(np.random.randn(100) * 0.5)
        
        self.sample_data = pd.DataFrame({
            'open': prices + np.random.randn(100) * 0.1,
            'high': prices + abs(np.random.randn(100)) * 0.5,
            'low': prices - abs(np.random.randn(100)) * 0.5,
            'close': prices,
            'volume': np.random.randint(1000, 10000, 100)
        }, index=dates)
    
    def test_initialization(self):
        self.assertEqual(self.engine.initial_capital, 100000.0)
        self.assertEqual(self.engine.commission_rate, 0.001)
        self.assertIsNone(self.engine.portfolio)
        self.assertIsNone(self.engine.strategy)
    
    def test_set_strategy(self):
        strategy = MockStrategy()
        self.engine.set_strategy(strategy)
        self.assertEqual(self.engine.strategy, strategy)
    
    def test_load_data(self):
        self.engine.load_data(self.sample_data)
        self.assertIsNotNone(self.engine.data)
        self.assertEqual(len(self.engine.data), 100)
    
    def test_load_data_missing_columns(self):
        bad_data = pd.DataFrame({'close': [100, 101, 102]})
        with self.assertRaises(ValueError):
            self.engine.load_data(bad_data)
    
    def test_run_backtest(self):
        strategy = MockStrategy()
        self.engine.set_strategy(strategy)
        self.engine.load_data(self.sample_data)
        
        results = self.engine.run()
        
        self.assertTrue(strategy.start_called)
        self.assertTrue(strategy.end_called)
        self.assertIn('total_return', results)
        self.assertIn('total_trades', results)
        self.assertIsNotNone(self.engine.portfolio)
    
    def test_run_without_strategy(self):
        self.engine.load_data(self.sample_data)
        with self.assertRaises(ValueError):
            self.engine.run()
    
    def test_run_without_data(self):
        strategy = MockStrategy()
        self.engine.set_strategy(strategy)
        with self.assertRaises(ValueError):
            self.engine.run()
    
    def test_get_equity_curve(self):
        strategy = MockStrategy()
        self.engine.set_strategy(strategy)
        self.engine.load_data(self.sample_data)
        self.engine.run()
        
        equity_curve = self.engine.get_equity_curve()
        self.assertIsInstance(equity_curve, pd.DataFrame)
        self.assertGreater(len(equity_curve), 0)
    
    def test_get_trade_log(self):
        strategy = MockStrategy()
        self.engine.set_strategy(strategy)
        self.engine.load_data(self.sample_data)
        self.engine.run()
        
        trade_log = self.engine.get_trade_log()
        self.assertIsInstance(trade_log, pd.DataFrame)


class TestExecutionEngine(unittest.TestCase):
    """Test ExecutionEngine class"""
    
    def setUp(self):
        from backtest.engine import ExecutionEngine
        self.engine = ExecutionEngine(commission_rate=0.001, slippage=0.0001)
    
    def test_market_order_execution(self):
        order = Order(symbol='TEST', side=OrderSide.BUY, quantity=10)
        bar = pd.Series({
            'open': 100.0,
            'high': 101.0,
            'low': 99.0,
            'close': 100.5,
            'volume': 1000
        })
        
        trade = self.engine.execute_order(order, bar)
        
        self.assertIsNotNone(trade)
        self.assertEqual(trade.symbol, 'TEST')
        self.assertEqual(trade.quantity, 10)
        self.assertGreater(trade.commission, 0)
    
    def test_limit_order_no_fill(self):
        order = Order(
            symbol='TEST', 
            side=OrderSide.BUY, 
            quantity=10,
            order_type=OrderType.LIMIT,
            price=90.0  # Below low
        )
        bar = pd.Series({
            'open': 100.0,
            'high': 101.0,
            'low': 99.0,
            'close': 100.5,
            'volume': 1000
        })
        
        trade = self.engine.execute_order(order, bar)
        self.assertIsNone(trade)


if __name__ == '__main__':
    unittest.main()
