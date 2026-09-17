"""
Backtest Engine - Event loop and strategy runner
"""

import logging
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Any, Callable, Dict, List, Optional, Protocol, Union
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)


class OrderSide(Enum):
    BUY = "buy"
    SELL = "sell"


class OrderType(Enum):
    MARKET = "market"
    LIMIT = "limit"
    STOP = "stop"


@dataclass
class Order:
    """Represents a trading order"""
    symbol: str
    side: OrderSide
    quantity: float
    order_type: OrderType = OrderType.MARKET
    price: Optional[float] = None
    timestamp: Optional[datetime] = None
    order_id: Optional[str] = None
    
    def __post_init__(self):
        if self.order_id is None:
            self.order_id = f"order_{id(self)}"
        if self.timestamp is None:
            self.timestamp = datetime.now()


@dataclass
class Position:
    """Represents a trading position"""
    symbol: str
    quantity: float
    avg_entry_price: float
    unrealized_pnl: float = 0.0
    realized_pnl: float = 0.0
    
    @property
    def is_long(self) -> bool:
        return self.quantity > 0
    
    @property
    def is_short(self) -> bool:
        return self.quantity < 0
    
    def get_market_value(self, current_price: float = 0.0) -> float:
        return abs(self.quantity) * current_price


@dataclass
class Trade:
    """Represents an executed trade"""
    order_id: str
    symbol: str
    side: OrderSide
    quantity: float
    price: float
    timestamp: datetime
    commission: float = 0.0
    trade_id: Optional[str] = None
    
    def __post_init__(self):
        if self.trade_id is None:
            self.trade_id = f"trade_{id(self)}"


@dataclass
class Portfolio:
    """Portfolio state tracking"""
    cash: float
    positions: Dict[str, Position] = field(default_factory=dict)
    trades: List[Trade] = field(default_factory=list)
    equity_curve: List[Dict[str, Any]] = field(default_factory=list)
    
    def get_total_value(self, prices: Optional[Dict[str, float]] = None) -> float:
        """Calculate total portfolio value"""
        position_value = 0.0
        if prices:
            for symbol, position in self.positions.items():
                if symbol in prices:
                    position_value += position.quantity * prices[symbol]
        return self.cash + position_value
    
    def update_position(self, trade: Trade) -> None:
        """Update position based on executed trade"""
        symbol = trade.symbol
        
        if symbol not in self.positions:
            self.positions[symbol] = Position(
                symbol=symbol,
                quantity=0.0,
                avg_entry_price=0.0
            )
        
        position = self.positions[symbol]
        
        if trade.side == OrderSide.BUY:
            # Update average entry price for long positions
            if position.quantity >= 0:
                total_cost = (position.quantity * position.avg_entry_price + 
                             trade.quantity * trade.price)
                position.quantity += trade.quantity
                position.avg_entry_price = total_cost / position.quantity if position.quantity > 0 else 0
            else:
                # Covering short position
                position.quantity += trade.quantity
                if position.quantity > 0:
                    position.avg_entry_price = trade.price
        else:  # SELL
            if position.quantity > 0:
                # Calculate realized PnL
                pnl = (trade.price - position.avg_entry_price) * min(trade.quantity, position.quantity)
                position.realized_pnl += pnl
            
            position.quantity -= trade.quantity
            if position.quantity == 0:
                position.avg_entry_price = 0.0
        
        # Remove position if quantity is zero
        if position.quantity == 0:
            del self.positions[symbol]
        
        self.trades.append(trade)


class Strategy(Protocol):
    """Protocol for trading strategies"""
    
    def on_data(self, timestamp: datetime, data: pd.Series, 
                portfolio: Portfolio) -> Optional[List[Order]]:
        """Process new data and optionally return orders"""
        ...
    
    def on_start(self, portfolio: Portfolio) -> None:
        """Called at the start of backtest"""
        ...
    
    def on_end(self, portfolio: Portfolio) -> None:
        """Called at the end of backtest"""
        ...


class ExecutionEngine:
    """Handles order execution simulation"""
    
    def __init__(self, commission_rate: float = 0.001, 
                 slippage: float = 0.0001,
                 fill_rate: float = 1.0):
        self.commission_rate = commission_rate
        self.slippage = slippage
        self.fill_rate = fill_rate
    
    def execute_order(self, order: Order, current_bar: pd.Series) -> Optional[Trade]:
        """Simulate order execution on current price bar"""
        # Simulate slippage
        slippage_factor = 1 + np.random.uniform(-self.slippage, self.slippage)
        
        if order.order_type == OrderType.MARKET:
            fill_price = current_bar['close'] * slippage_factor
        elif order.order_type == OrderType.LIMIT and order.price:
            # Check if limit order would fill
            if (order.side == OrderSide.BUY and current_bar['low'] <= order.price) or \
               (order.side == OrderSide.SELL and current_bar['high'] >= order.price):
                fill_price = order.price * slippage_factor
            else:
                return None  # Limit order didn't fill
        else:
            fill_price = current_bar['close'] * slippage_factor
        
        # Calculate commission
        trade_value = order.quantity * fill_price
        commission = trade_value * self.commission_rate
        
        return Trade(
            order_id=order.order_id,
            symbol=order.symbol,
            side=order.side,
            quantity=order.quantity,
            price=fill_price,
            timestamp=order.timestamp or datetime.now(),
            commission=commission
        )


class BacktestEngine:
    """
    Main backtesting engine with event loop
    """
    
    def __init__(self, 
                 initial_capital: float = 100000.0,
                 commission_rate: float = 0.001,
                 slippage: float = 0.0001,
                 allow_short: bool = False):
        """
        Initialize backtest engine
        
        Args:
            initial_capital: Starting cash
            commission_rate: Commission as decimal (e.g., 0.001 = 0.1%)
            slippage: Slippage factor for execution simulation
            allow_short: Whether to allow short selling
        """
        self.initial_capital = initial_capital
        self.commission_rate = commission_rate
        self.allow_short = allow_short
        
        self.execution_engine = ExecutionEngine(
            commission_rate=commission_rate,
            slippage=slippage
        )
        
        self.portfolio: Optional[Portfolio] = None
        self.strategy: Optional[Strategy] = None
        self.data: Optional[pd.DataFrame] = None
        self.results: Dict[str, Any] = {}
        
        logger.info(f"BacktestEngine initialized with capital: ${initial_capital:,.2f}")
    
    def set_strategy(self, strategy: Strategy) -> None:
        """Set the trading strategy"""
        self.strategy = strategy
        logger.info(f"Strategy set: {strategy.__class__.__name__}")
    
    def load_data(self, data: pd.DataFrame) -> None:
        """Load historical price data"""
        required_cols = ['open', 'high', 'low', 'close', 'volume']
        missing_cols = [col for col in required_cols if col not in data.columns]
        
        if missing_cols:
            raise ValueError(f"Data missing required columns: {missing_cols}")
        
        self.data = data.copy()
        logger.info(f"Data loaded: {len(data)} bars")
    
    def run(self) -> Dict[str, Any]:
        """
        Run the backtest
        
        Returns:
            Dictionary containing backtest results
        """
        if self.strategy is None:
            raise ValueError("Strategy not set. Call set_strategy() first.")
        
        if self.data is None or len(self.data) == 0:
            raise ValueError("No data loaded. Call load_data() first.")
        
        # Initialize portfolio
        self.portfolio = Portfolio(cash=self.initial_capital)
        
        # Strategy initialization
        self.strategy.on_start(self.portfolio)
        
        logger.info("Starting backtest...")
        
        # Event loop
        pending_orders: List[Order] = []
        
        for timestamp, bar in self.data.iterrows():
            # Convert timestamp to datetime if needed
            if isinstance(timestamp, pd.Timestamp):
                current_time = timestamp.to_pydatetime()
            else:
                current_time = datetime.now()
            
            # Process pending orders from previous bar
            for order in pending_orders:
                trade = self.execution_engine.execute_order(order, bar)
                if trade:
                    # Update cash
                    trade_cost = trade.quantity * trade.price + trade.commission
                    if order.side == OrderSide.BUY:
                        self.portfolio.cash -= trade_cost
                    else:
                        self.portfolio.cash += trade_cost - trade.commission
                    
                    # Update positions
                    self.portfolio.update_position(trade)
            
            pending_orders = []
            
            # Get current prices for equity calculation
            current_prices = {bar.get('symbol', 'default'): bar['close']}
            
            # Record equity
            equity = self.portfolio.get_total_value(current_prices)
            self.portfolio.equity_curve.append({
                'timestamp': current_time,
                'equity': equity,
                'cash': self.portfolio.cash,
                'positions': len(self.portfolio.positions)
            })
            
            # Call strategy on new data
            orders = self.strategy.on_data(current_time, bar, self.portfolio)
            
            if orders:
                # Validate orders
                for order in orders:
                    if self._validate_order(order, bar):
                        order.timestamp = current_time
                        pending_orders.append(order)
        
        # Strategy cleanup
        self.strategy.on_end(self.portfolio)
        
        # Generate results
        self.results = self._generate_results()
        
        logger.info("Backtest completed")
        return self.results
    
    def _validate_order(self, order: Order, current_bar: pd.Series) -> bool:
        """Validate if order can be executed"""
        # Check if we have enough cash for buy orders
        if order.side == OrderSide.BUY:
            order_cost = order.quantity * current_bar['close']
            commission = order_cost * self.commission_rate
            total_cost = order_cost + commission
            
            if total_cost > self.portfolio.cash:
                logger.warning(f"Insufficient funds for buy order: {order}")
                return False
        
        # Check if we have position for sell orders
        elif order.side == OrderSide.SELL:
            if not self.allow_short:
                current_position = self.portfolio.positions.get(order.symbol)
                if not current_position or current_position.quantity < order.quantity:
                    logger.warning(f"Insufficient position for sell order: {order}")
                    return False
        
        return True
    
    def _generate_results(self) -> Dict[str, Any]:
        """Generate backtest results summary"""
        if not self.portfolio.equity_curve:
            return {}
        
        equity_df = pd.DataFrame(self.portfolio.equity_curve)
        
        # Calculate returns
        equity_df['returns'] = equity_df['equity'].pct_change()
        
        results = {
            'initial_capital': self.initial_capital,
            'final_equity': self.portfolio.equity_curve[-1]['equity'],
            'total_return': (self.portfolio.equity_curve[-1]['equity'] - self.initial_capital) / self.initial_capital,
            'total_trades': len(self.portfolio.trades),
            'equity_curve': self.portfolio.equity_curve,
            'trades': self.portfolio.trades,
            'positions': self.portfolio.positions
        }
        
        return results
    
    def get_equity_curve(self) -> pd.DataFrame:
        """Get equity curve as DataFrame"""
        if not self.portfolio or not self.portfolio.equity_curve:
            return pd.DataFrame()
        return pd.DataFrame(self.portfolio.equity_curve)
    
    def get_trade_log(self) -> pd.DataFrame:
        """Get trade log as DataFrame"""
        if not self.portfolio or not self.portfolio.trades:
            return pd.DataFrame()
        
        trades_data = []
        for trade in self.portfolio.trades:
            trades_data.append({
                'trade_id': trade.trade_id,
                'order_id': trade.order_id,
                'symbol': trade.symbol,
                'side': trade.side.value,
                'quantity': trade.quantity,
                'price': trade.price,
                'commission': trade.commission,
                'timestamp': trade.timestamp
            })
        
        return pd.DataFrame(trades_data)
