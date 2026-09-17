"""
Data Loader - Historical data loading and preprocessing
"""

import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Union, Callable
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)


class DataLoader:
    """
    Handles loading and preprocessing of historical market data
    """
    
    def __init__(self, data_dir: Optional[Union[str, Path]] = None):
        """
        Initialize data loader
        
        Args:
            data_dir: Directory containing data files
        """
        self.data_dir = Path(data_dir) if data_dir else None
        self._cache: Dict[str, pd.DataFrame] = {}
        
        logger.info(f"DataLoader initialized with data_dir: {data_dir}")
    
    def load_csv(self, 
                 filepath: Union[str, Path],
                 symbol: Optional[str] = None,
                 timestamp_col: str = 'timestamp',
                 parse_dates: bool = True,
                 **pandas_kwargs) -> pd.DataFrame:
        """
        Load data from CSV file
        
        Args:
            filepath: Path to CSV file
            symbol: Symbol name (extracted from filename if not provided)
            timestamp_col: Column name for timestamps
            parse_dates: Whether to parse date columns
            **pandas_kwargs: Additional arguments for pd.read_csv
        
        Returns:
            DataFrame with OHLCV data
        """
        filepath = Path(filepath)
        if not filepath.exists():
            raise FileNotFoundError(f"Data file not found: {filepath}")
        
        # Extract symbol from filename if not provided
        if symbol is None:
            symbol = filepath.stem
        
        logger.info(f"Loading data from {filepath}")
        
        # Load CSV
        df = pd.read_csv(filepath, **pandas_kwargs)
        
        # Parse timestamps
        if parse_dates and timestamp_col in df.columns:
            df[timestamp_col] = pd.to_datetime(df[timestamp_col])
            df.set_index(timestamp_col, inplace=True)
        
        # Add symbol column
        df['symbol'] = symbol
        
        # Validate required columns
        self._validate_ohlcv(df)
        
        # Sort by index
        df.sort_index(inplace=True)
        
        logger.info(f"Loaded {len(df)} rows for {symbol}")
        
        # Cache the data
        self._cache[symbol] = df
        
        return df
    
    def load_parquet(self,
                     filepath: Union[str, Path],
                     symbol: Optional[str] = None) -> pd.DataFrame:
        """
        Load data from Parquet file
        
        Args:
            filepath: Path to Parquet file
            symbol: Symbol name
        
        Returns:
            DataFrame with OHLCV data
        """
        filepath = Path(filepath)
        if not filepath.exists():
            raise FileNotFoundError(f"Data file not found: {filepath}")
        
        if symbol is None:
            symbol = filepath.stem
        
        logger.info(f"Loading data from {filepath}")
        
        df = pd.read_parquet(filepath)
        
        # Add symbol if not present
        if 'symbol' not in df.columns:
            df['symbol'] = symbol
        
        self._validate_ohlcv(df)
        df.sort_index(inplace=True)
        
        self._cache[symbol] = df
        
        logger.info(f"Loaded {len(df)} rows for {symbol}")
        return df
    
    def load_from_dataframe(self,
                           df: pd.DataFrame,
                           symbol: str,
                           timestamp_col: Optional[str] = None) -> pd.DataFrame:
        """
        Load data from existing DataFrame
        
        Args:
            df: DataFrame with OHLCV data
            symbol: Symbol name
            timestamp_col: Column to use as index (if not already set)
        
        Returns:
            Processed DataFrame
        """
        df = df.copy()
        
        # Set timestamp as index if provided
        if timestamp_col and timestamp_col in df.columns:
            df[timestamp_col] = pd.to_datetime(df[timestamp_col])
            df.set_index(timestamp_col, inplace=True)
        
        # Add symbol
        df['symbol'] = symbol
        
        self._validate_ohlcv(df)
        df.sort_index(inplace=True)
        
        self._cache[symbol] = df
        
        logger.info(f"Loaded {len(df)} rows for {symbol} from DataFrame")
        return df
    
    def generate_synthetic_data(self,
                                symbol: str,
                                start_date: datetime,
                                end_date: datetime,
                                frequency: str = '1H',
                                start_price: float = 100.0,
                                volatility: float = 0.02,
                                trend: float = 0.0001,
                                seed: Optional[int] = None) -> pd.DataFrame:
        """
        Generate synthetic OHLCV data for testing
        
        Args:
            symbol: Symbol name
            start_date: Start date
            end_date: End date
            frequency: Data frequency ('1H', '1D', etc.)
            start_price: Starting price
            volatility: Price volatility
            trend: Price trend factor
            seed: Random seed for reproducibility
        
        Returns:
            DataFrame with synthetic OHLCV data
        """
        if seed is not None:
            np.random.seed(seed)
        
        # Generate timestamps
        timestamps = pd.date_range(start=start_date, end=end_date, freq=frequency)
        n_periods = len(timestamps)
        
        # Generate price path using random walk
        returns = np.random.normal(trend, volatility, n_periods)
        prices = start_price * np.exp(np.cumsum(returns))
        
        # Generate OHLC from close prices
        data = []
        for i, timestamp in enumerate(timestamps):
            close = prices[i]
            # Generate realistic OHLC
            high_noise = abs(np.random.normal(0, volatility * close * 0.5))
            low_noise = abs(np.random.normal(0, volatility * close * 0.5))
            
            high = close + high_noise
            low = close - low_noise
            
            # Open is previous close or current close with small noise
            if i > 0:
                open_price = prices[i-1] + np.random.normal(0, volatility * close * 0.3)
            else:
                open_price = close + np.random.normal(0, volatility * close * 0.3)
            
            # Ensure OHLC relationships
            high = max(high, open_price, close)
            low = min(low, open_price, close)
            
            # Generate volume
            volume = int(np.random.uniform(1000, 10000) * (1 + volatility * 10))
            
            data.append({
                'timestamp': timestamp,
                'open': round(open_price, 4),
                'high': round(high, 4),
                'low': round(low, 4),
                'close': round(close, 4),
                'volume': volume,
                'symbol': symbol
            })
        
        df = pd.DataFrame(data)
        df.set_index('timestamp', inplace=True)
        
        self._cache[symbol] = df
        
        logger.info(f"Generated {len(df)} synthetic bars for {symbol}")
        return df
    
    def resample(self,
                 df: pd.DataFrame,
                 rule: str,
                 symbol: Optional[str] = None) -> pd.DataFrame:
        """
        Resample data to different timeframe
        
        Args:
            df: DataFrame with OHLCV data
            rule: Resampling rule (e.g., '1D', '4H', '1W')
            symbol: Symbol name (preserved from original if not provided)
        
        Returns:
            Resampled DataFrame
        """
        if symbol is None:
            symbol = df['symbol'].iloc[0] if 'symbol' in df.columns else 'unknown'
        
        resampled = df.resample(rule).agg({
            'open': 'first',
            'high': 'max',
            'low': 'min',
            'close': 'last',
            'volume': 'sum'
        })
        
        resampled['symbol'] = symbol
        resampled.dropna(inplace=True)
        
        logger.info(f"Resampled {len(df)} bars to {len(resampled)} {rule} bars")
        return resampled
    
    def filter_by_date(self,
                       df: pd.DataFrame,
                       start_date: Optional[datetime] = None,
                       end_date: Optional[datetime] = None) -> pd.DataFrame:
        """
        Filter data by date range
        
        Args:
            df: DataFrame with datetime index
            start_date: Start date (inclusive)
            end_date: End date (inclusive)
        
        Returns:
            Filtered DataFrame
        """
        mask = pd.Series(True, index=df.index)
        
        if start_date:
            mask &= df.index >= start_date
        if end_date:
            mask &= df.index <= end_date
        
        filtered = df[mask].copy()
        logger.info(f"Filtered to {len(filtered)} rows from {start_date} to {end_date}")
        return filtered
    
    def add_technical_indicators(self,
                                  df: pd.DataFrame,
                                  indicators: Optional[List[str]] = None) -> pd.DataFrame:
        """
        Add common technical indicators
        
        Args:
            df: DataFrame with OHLCV data
            indicators: List of indicators to add ('sma', 'ema', 'rsi', 'macd', 'bb')
        
        Returns:
            DataFrame with added indicators
        """
        if indicators is None:
            indicators = ['sma', 'ema', 'rsi']
        
        df = df.copy()
        
        if 'sma' in indicators:
            df['sma_20'] = df['close'].rolling(window=20).mean()
            df['sma_50'] = df['close'].rolling(window=50).mean()
        
        if 'ema' in indicators:
            df['ema_12'] = df['close'].ewm(span=12).mean()
            df['ema_26'] = df['close'].ewm(span=26).mean()
        
        if 'rsi' in indicators:
            delta = df['close'].diff()
            gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
            loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
            rs = gain / loss
            df['rsi'] = 100 - (100 / (1 + rs))
        
        if 'macd' in indicators:
            ema_12 = df['close'].ewm(span=12).mean()
            ema_26 = df['close'].ewm(span=26).mean()
            df['macd'] = ema_12 - ema_26
            df['macd_signal'] = df['macd'].ewm(span=9).mean()
            df['macd_histogram'] = df['macd'] - df['macd_signal']
        
        if 'bb' in indicators:  # Bollinger Bands
            df['bb_middle'] = df['close'].rolling(window=20).mean()
            bb_std = df['close'].rolling(window=20).std()
            df['bb_upper'] = df['bb_middle'] + (bb_std * 2)
            df['bb_lower'] = df['bb_middle'] - (bb_std * 2)
        
        logger.info(f"Added indicators: {indicators}")
        return df
    
    def split_train_test(self,
                         df: pd.DataFrame,
                         train_ratio: float = 0.8,
                         split_date: Optional[datetime] = None) -> tuple:
        """
        Split data into train and test sets
        
        Args:
            df: DataFrame to split
            train_ratio: Ratio of data for training (if split_date not provided)
            split_date: Specific date to split on
        
        Returns:
            Tuple of (train_df, test_df)
        """
        if split_date:
            train_df = df[df.index < split_date].copy()
            test_df = df[df.index >= split_date].copy()
        else:
            split_idx = int(len(df) * train_ratio)
            train_df = df.iloc[:split_idx].copy()
            test_df = df.iloc[split_idx:].copy()
        
        logger.info(f"Split data: {len(train_df)} train, {len(test_df)} test")
        return train_df, test_df
    
    def get_cached(self, symbol: str) -> Optional[pd.DataFrame]:
        """Get cached data for a symbol"""
        return self._cache.get(symbol)
    
    def clear_cache(self) -> None:
        """Clear all cached data"""
        self._cache.clear()
        logger.info("Cache cleared")
    
    def _validate_ohlcv(self, df: pd.DataFrame) -> None:
        """Validate that DataFrame has required OHLCV columns"""
        required = ['open', 'high', 'low', 'close', 'volume']
        missing = [col for col in required if col not in df.columns]
        
        if missing:
            raise ValueError(f"Missing required columns: {missing}")
        
        # Validate OHLC relationships
        invalid = (
            (df['high'] < df['low']) |
            (df['high'] < df['open']) |
            (df['high'] < df['close']) |
            (df['low'] > df['open']) |
            (df['low'] > df['close'])
        )
        
        if invalid.any():
            n_invalid = invalid.sum()
            logger.warning(f"Found {n_invalid} bars with invalid OHLC relationships")
    
    def get_data_info(self, df: pd.DataFrame) -> Dict:
        """Get information about loaded data"""
        return {
            'rows': len(df),
            'columns': list(df.columns),
            'date_range': (df.index.min(), df.index.max()),
            'duration': df.index.max() - df.index.min(),
            'symbols': df['symbol'].unique().tolist() if 'symbol' in df.columns else ['unknown'],
            'price_range': (df['low'].min(), df['high'].max()),
            'avg_volume': df['volume'].mean(),
            'missing_values': df.isnull().sum().to_dict()
        }
