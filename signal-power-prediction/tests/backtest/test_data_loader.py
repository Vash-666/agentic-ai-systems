"""
Unit tests for data loader
"""

import unittest
from datetime import datetime, timedelta
from pathlib import Path
import tempfile
import pandas as pd
import numpy as np
import sys

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent / 'src'))

from backtest.data_loader import DataLoader


class TestDataLoader(unittest.TestCase):
    """Test DataLoader class"""
    
    def setUp(self):
        self.loader = DataLoader()
        
        # Create sample data
        self.sample_data = pd.DataFrame({
            'timestamp': pd.date_range(start='2023-01-01', periods=100, freq='H'),
            'open': np.random.uniform(90, 110, 100),
            'high': np.random.uniform(100, 120, 100),
            'low': np.random.uniform(80, 100, 100),
            'close': np.random.uniform(90, 110, 100),
            'volume': np.random.randint(1000, 10000, 100)
        })
        # Ensure OHLC relationships
        for i in range(len(self.sample_data)):
            row = self.sample_data.iloc[i]
            self.sample_data.at[i, 'high'] = max(row['open'], row['high'], row['close'])
            self.sample_data.at[i, 'low'] = min(row['open'], row['low'], row['close'])
    
    def test_initialization(self):
        loader = DataLoader(data_dir='/tmp')
        self.assertEqual(str(loader.data_dir), '/tmp')
    
    def test_load_from_dataframe(self):
        df = self.loader.load_from_dataframe(
            self.sample_data.copy(),
            symbol='TEST',
            timestamp_col='timestamp'
        )
        
        self.assertEqual(len(df), 100)
        self.assertEqual(df['symbol'].iloc[0], 'TEST')
        self.assertIsInstance(df.index, pd.DatetimeIndex)
    
    def test_generate_synthetic_data(self):
        df = self.loader.generate_synthetic_data(
            symbol='SYNTH',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 31),
            frequency='1D',
            start_price=100.0,
            volatility=0.02,
            seed=42
        )
        
        self.assertGreater(len(df), 0)
        self.assertEqual(df['symbol'].iloc[0], 'SYNTH')
        self.assertIn('open', df.columns)
        self.assertIn('high', df.columns)
        self.assertIn('low', df.columns)
        self.assertIn('close', df.columns)
        self.assertIn('volume', df.columns)
        
        # Check OHLC relationships
        self.assertTrue((df['high'] >= df['low']).all())
        self.assertTrue((df['high'] >= df['open']).all())
        self.assertTrue((df['high'] >= df['close']).all())
        self.assertTrue((df['low'] <= df['open']).all())
        self.assertTrue((df['low'] <= df['close']).all())
    
    def test_resample(self):
        # Generate hourly data
        df = self.loader.generate_synthetic_data(
            symbol='TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 10),
            frequency='1H',
            seed=42
        )
        
        # Resample to daily
        daily = self.loader.resample(df, rule='1D')
        
        self.assertLess(len(daily), len(df))
        self.assertIn('open', daily.columns)
        self.assertIn('high', daily.columns)
        self.assertIn('low', daily.columns)
        self.assertIn('close', daily.columns)
        self.assertIn('volume', daily.columns)
    
    def test_filter_by_date(self):
        df = self.loader.generate_synthetic_data(
            symbol='TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 31),
            frequency='1D',
            seed=42
        )
        
        # Filter to first half
        filtered = self.loader.filter_by_date(
            df,
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 15)
        )
        
        self.assertLess(len(filtered), len(df))
        self.assertGreaterEqual(filtered.index.min(), datetime(2023, 1, 1))
        self.assertLessEqual(filtered.index.max(), datetime(2023, 1, 15))
    
    def test_add_technical_indicators(self):
        df = self.loader.generate_synthetic_data(
            symbol='TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 6, 30),
            frequency='1D',
            seed=42
        )
        
        df_with_indicators = self.loader.add_technical_indicators(
            df,
            indicators=['sma', 'ema', 'rsi', 'macd', 'bb']
        )
        
        self.assertIn('sma_20', df_with_indicators.columns)
        self.assertIn('sma_50', df_with_indicators.columns)
        self.assertIn('ema_12', df_with_indicators.columns)
        self.assertIn('ema_26', df_with_indicators.columns)
        self.assertIn('rsi', df_with_indicators.columns)
        self.assertIn('macd', df_with_indicators.columns)
        self.assertIn('macd_signal', df_with_indicators.columns)
        self.assertIn('bb_upper', df_with_indicators.columns)
        self.assertIn('bb_lower', df_with_indicators.columns)
    
    def test_split_train_test(self):
        df = self.loader.generate_synthetic_data(
            symbol='TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 3, 31),
            frequency='1D',
            seed=42
        )
        
        train, test = self.loader.split_train_test(df, train_ratio=0.8)
        
        total_len = len(train) + len(test)
        self.assertEqual(total_len, len(df))
        self.assertGreater(len(train), len(test))
    
    def test_cache(self):
        df = self.loader.generate_synthetic_data(
            symbol='CACHE_TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 10),
            frequency='1D',
            seed=42
        )
        
        # Should be cached
        cached = self.loader.get_cached('CACHE_TEST')
        self.assertIsNotNone(cached)
        
        # Clear cache
        self.loader.clear_cache()
        cached = self.loader.get_cached('CACHE_TEST')
        self.assertIsNone(cached)
    
    def test_get_data_info(self):
        df = self.loader.generate_synthetic_data(
            symbol='INFO_TEST',
            start_date=datetime(2023, 1, 1),
            end_date=datetime(2023, 1, 10),
            frequency='1D',
            seed=42
        )
        
        info = self.loader.get_data_info(df)
        
        self.assertIn('rows', info)
        self.assertIn('columns', info)
        self.assertIn('date_range', info)
        self.assertIn('duration', info)
        self.assertIn('symbols', info)
        self.assertIn('price_range', info)
        self.assertIn('avg_volume', info)
        
        self.assertEqual(info['rows'], len(df))
        self.assertIn('INFO_TEST', info['symbols'])
    
    def test_load_csv(self):
        # Create temporary CSV file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            f.write('timestamp,open,high,low,close,volume\n')
            for i in range(10):
                f.write(f'2023-01-{i+1:02d} 00:00:00,100,105,95,102,1000\n')
            temp_path = f.name
        
        try:
            df = self.loader.load_csv(temp_path, symbol='CSV_TEST')
            self.assertEqual(len(df), 10)
            self.assertEqual(df['symbol'].iloc[0], 'CSV_TEST')
        finally:
            Path(temp_path).unlink()


if __name__ == '__main__':
    unittest.main()
