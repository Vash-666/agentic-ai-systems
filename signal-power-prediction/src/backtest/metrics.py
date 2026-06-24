"""
Metrics Calculator - Performance metrics for backtesting
"""

import logging
from dataclasses import dataclass
from typing import Dict, List, Optional, Union
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)


@dataclass
class TradeMetrics:
    """Metrics for individual trades"""
    total_trades: int = 0
    winning_trades: int = 0
    losing_trades: int = 0
    win_rate: float = 0.0
    avg_win: float = 0.0
    avg_loss: float = 0.0
    profit_factor: float = 0.0
    largest_win: float = 0.0
    largest_loss: float = 0.0
    avg_trade_return: float = 0.0


@dataclass
class DrawdownMetrics:
    """Drawdown-related metrics"""
    max_drawdown: float = 0.0
    max_drawdown_duration: int = 0
    avg_drawdown: float = 0.0
    recovery_factor: float = 0.0
    calmar_ratio: float = 0.0


@dataclass
class RiskMetrics:
    """Risk-adjusted performance metrics"""
    sharpe_ratio: float = 0.0
    sortino_ratio: float = 0.0
    volatility: float = 0.0
    downside_deviation: float = 0.0
    var_95: float = 0.0  # Value at Risk (95%)
    cvar_95: float = 0.0  # Conditional VaR


class MetricsCalculator:
    """
    Calculates comprehensive performance metrics for backtesting results
    """
    
    def __init__(self, risk_free_rate: float = 0.02):
        """
        Initialize metrics calculator
        
        Args:
            risk_free_rate: Annual risk-free rate for Sharpe ratio calculation
        """
        self.risk_free_rate = risk_free_rate
        logger.info(f"MetricsCalculator initialized with risk-free rate: {risk_free_rate}")
    
    def calculate_all(self,
                     equity_curve: pd.DataFrame,
                     trades: Optional[List] = None,
                     initial_capital: float = 100000.0) -> Dict[str, Union[float, int]]:
        """
        Calculate all available metrics
        
        Args:
            equity_curve: DataFrame with equity values and timestamps
            trades: List of trade objects
            initial_capital: Initial capital amount
        
        Returns:
            Dictionary with all calculated metrics
        """
        metrics = {}
        
        # Basic return metrics
        metrics.update(self.calculate_return_metrics(equity_curve, initial_capital))
        
        # Drawdown metrics
        metrics.update(self.calculate_drawdown_metrics(equity_curve))
        
        # Risk metrics
        metrics.update(self.calculate_risk_metrics(equity_curve))
        
        # Trade metrics
        if trades:
            metrics.update(self.calculate_trade_metrics(trades))
        
        logger.info("All metrics calculated successfully")
        return metrics
    
    def calculate_return_metrics(self,
                                  equity_curve: pd.DataFrame,
                                  initial_capital: float = 100000.0) -> Dict[str, float]:
        """
        Calculate basic return metrics
        
        Args:
            equity_curve: DataFrame with equity values
            initial_capital: Initial capital amount
        
        Returns:
            Dictionary with return metrics
        """
        if 'equity' not in equity_curve.columns:
            raise ValueError("Equity curve must contain 'equity' column")
        
        equity = equity_curve['equity']
        
        # Calculate returns
        returns = equity.pct_change().dropna()
        
        # Total return
        final_equity = equity.iloc[-1]
        total_return = (final_equity - initial_capital) / initial_capital
        
        # Annualized return
        if 'timestamp' in equity_curve.columns:
            timestamps = pd.to_datetime(equity_curve['timestamp'])
        else:
            timestamps = equity_curve.index
        
        duration_days = (timestamps.max() - timestamps.min()).days
        duration_years = duration_days / 365.25
        
        if duration_years > 0:
            cagr = (final_equity / initial_capital) ** (1 / duration_years) - 1
        else:
            cagr = 0.0
        
        metrics = {
            'initial_capital': initial_capital,
            'final_equity': final_equity,
            'total_return': total_return,
            'total_return_pct': total_return * 100,
            'cagr': cagr,
            'cagr_pct': cagr * 100,
            'duration_days': duration_days,
            'duration_years': duration_years,
            'avg_daily_return': returns.mean(),
            'avg_daily_return_pct': returns.mean() * 100,
        }
        
        logger.debug(f"Return metrics: {metrics}")
        return metrics
    
    def calculate_drawdown_metrics(self, equity_curve: pd.DataFrame) -> Dict[str, float]:
        """
        Calculate drawdown metrics
        
        Args:
            equity_curve: DataFrame with equity values
        
        Returns:
            Dictionary with drawdown metrics
        """
        equity = equity_curve['equity']
        
        # Calculate running maximum
        running_max = equity.expanding().max()
        
        # Calculate drawdown
        drawdown = (equity - running_max) / running_max
        drawdown_pct = drawdown * 100
        
        # Maximum drawdown
        max_drawdown = drawdown.min()
        max_drawdown_pct = max_drawdown * 100
        
        # Find max drawdown duration
        is_drawdown = drawdown < 0
        drawdown_periods = []
        current_start = None
        
        for i, in_dd in enumerate(is_drawdown):
            if in_dd and current_start is None:
                current_start = i
            elif not in_dd and current_start is not None:
                drawdown_periods.append(i - current_start)
                current_start = None
        
        if current_start is not None:
            drawdown_periods.append(len(is_drawdown) - current_start)
        
        max_drawdown_duration = max(drawdown_periods) if drawdown_periods else 0
        avg_drawdown = drawdown[is_drawdown].mean() if is_drawdown.any() else 0
        
        # Calculate underwater ratio (time spent in drawdown)
        underwater_ratio = is_drawdown.sum() / len(is_drawdown)
        
        metrics = {
            'max_drawdown': max_drawdown,
            'max_drawdown_pct': max_drawdown_pct,
            'max_drawdown_duration': max_drawdown_duration,
            'avg_drawdown': avg_drawdown,
            'avg_drawdown_pct': avg_drawdown * 100,
            'underwater_ratio': underwater_ratio,
            'underwater_ratio_pct': underwater_ratio * 100,
        }
        
        logger.debug(f"Drawdown metrics: {metrics}")
        return metrics
    
    def calculate_risk_metrics(self, equity_curve: pd.DataFrame) -> Dict[str, float]:
        """
        Calculate risk-adjusted metrics
        
        Args:
            equity_curve: DataFrame with equity values
        
        Returns:
            Dictionary with risk metrics
        """
        equity = equity_curve['equity']
        returns = equity.pct_change().dropna()
        
        if len(returns) < 2:
            logger.warning("Insufficient data for risk metrics")
            return {
                'sharpe_ratio': 0.0,
                'sortino_ratio': 0.0,
                'volatility': 0.0,
                'volatility_annualized': 0.0,
                'downside_deviation': 0.0,
                'var_95': 0.0,
                'cvar_95': 0.0,
            }
        
        # Volatility (standard deviation of returns)
        volatility = returns.std()
        
        # Annualize volatility (assuming daily data)
        volatility_annualized = volatility * np.sqrt(252)
        
        # Sharpe Ratio
        excess_returns = returns.mean() - (self.risk_free_rate / 252)
        sharpe_ratio = (excess_returns / volatility * np.sqrt(252)) if volatility > 0 else 0
        
        # Sortino Ratio (downside deviation only)
        downside_returns = returns[returns < 0]
        downside_deviation = downside_returns.std() if len(downside_returns) > 0 else 0
        downside_deviation_annualized = downside_deviation * np.sqrt(252)
        sortino_ratio = (excess_returns * 252 / downside_deviation_annualized) if downside_deviation_annualized > 0 else 0
        
        # Value at Risk (95% confidence)
        var_95 = np.percentile(returns, 5)
        
        # Conditional VaR (expected shortfall)
        cvar_95 = returns[returns <= var_95].mean() if len(returns[returns <= var_95]) > 0 else 0
        
        # Skewness and Kurtosis
        skewness = returns.skew()
        kurtosis = returns.kurtosis()
        
        metrics = {
            'sharpe_ratio': sharpe_ratio,
            'sortino_ratio': sortino_ratio,
            'volatility': volatility,
            'volatility_pct': volatility * 100,
            'volatility_annualized': volatility_annualized,
            'volatility_annualized_pct': volatility_annualized * 100,
            'downside_deviation': downside_deviation,
            'downside_deviation_pct': downside_deviation * 100,
            'var_95': var_95,
            'var_95_pct': var_95 * 100,
            'cvar_95': cvar_95,
            'cvar_95_pct': cvar_95 * 100,
            'skewness': skewness,
            'kurtosis': kurtosis,
        }
        
        logger.debug(f"Risk metrics: {metrics}")
        return metrics
    
    def calculate_trade_metrics(self, trades: List) -> Dict[str, Union[float, int]]:
        """
        Calculate trade-specific metrics
        
        Args:
            trades: List of trade objects
        
        Returns:
            Dictionary with trade metrics
        """
        if not trades:
            return {
                'total_trades': 0,
                'winning_trades': 0,
                'losing_trades': 0,
                'win_rate': 0.0,
                'profit_factor': 0.0,
            }
        
        # Extract trade returns
        trade_returns = []
        
        for trade in trades:
            # Calculate trade return if possible
            if hasattr(trade, 'pnl'):
                trade_returns.append(trade.pnl)
            elif hasattr(trade, 'price') and hasattr(trade, 'quantity'):
                # Simplified calculation
                trade_value = trade.price * trade.quantity
                trade_returns.append(trade_value)
        
        if not trade_returns:
            return {'total_trades': len(trades)}
        
        trade_returns = np.array(trade_returns)
        
        # Basic counts
        total_trades = len(trades)
        winning_trades = np.sum(trade_returns > 0)
        losing_trades = np.sum(trade_returns < 0)
        breakeven_trades = np.sum(trade_returns == 0)
        
        # Win rate
        win_rate = winning_trades / total_trades if total_trades > 0 else 0
        
        # Average win/loss
        wins = trade_returns[trade_returns > 0]
        losses = trade_returns[trade_returns < 0]
        
        avg_win = wins.mean() if len(wins) > 0 else 0
        avg_loss = abs(losses.mean()) if len(losses) > 0 else 0
        
        # Profit factor
        total_wins = wins.sum() if len(wins) > 0 else 0
        total_losses = abs(losses.sum()) if len(losses) > 0 else 0
        profit_factor = total_wins / total_losses if total_losses > 0 else float('inf')
        
        # Largest win/loss
        largest_win = wins.max() if len(wins) > 0 else 0
        largest_loss = abs(losses.min()) if len(losses) > 0 else 0
        
        # Expectancy
        avg_trade_return = trade_returns.mean()
        expectancy = (win_rate * avg_win) - ((1 - win_rate) * avg_loss)
        
        metrics = {
            'total_trades': total_trades,
            'winning_trades': int(winning_trades),
            'losing_trades': int(losing_trades),
            'breakeven_trades': int(breakeven_trades),
            'win_rate': win_rate,
            'win_rate_pct': win_rate * 100,
            'avg_win': avg_win,
            'avg_loss': avg_loss,
            'profit_factor': profit_factor,
            'largest_win': largest_win,
            'largest_loss': largest_loss,
            'avg_trade_return': avg_trade_return,
            'expectancy': expectancy,
        }
        
        logger.debug(f"Trade metrics: {metrics}")
        return metrics
    
    def calculate_calmar_ratio(self,
                               cagr: float,
                               max_drawdown: float) -> float:
        """
        Calculate Calmar ratio (CAGR / Max Drawdown)
        
        Args:
            cagr: Compound Annual Growth Rate
            max_drawdown: Maximum drawdown (as negative decimal)
        
        Returns:
            Calmar ratio
        """
        if max_drawdown >= 0 or max_drawdown == 0:
            return 0.0
        
        calmar = cagr / abs(max_drawdown)
        return calmar
    
    def calculate_beta_alpha(self,
                            strategy_returns: pd.Series,
                            benchmark_returns: pd.Series) -> Dict[str, float]:
        """
        Calculate beta and alpha relative to benchmark
        
        Args:
            strategy_returns: Strategy return series
            benchmark_returns: Benchmark return series
        
        Returns:
            Dictionary with beta and alpha
        """
        # Align the series
        aligned = pd.concat([strategy_returns, benchmark_returns], axis=1).dropna()
        
        if len(aligned) < 2:
            return {'beta': 0.0, 'alpha': 0.0}
        
        strategy_rets = aligned.iloc[:, 0]
        benchmark_rets = aligned.iloc[:, 1]
        
        # Calculate beta
        covariance = strategy_rets.cov(benchmark_rets)
        benchmark_variance = benchmark_rets.var()
        beta = covariance / benchmark_variance if benchmark_variance > 0 else 0
        
        # Calculate alpha
        alpha = strategy_rets.mean() - beta * benchmark_rets.mean()
        
        # Annualized alpha
        alpha_annualized = alpha * 252
        
        return {
            'beta': beta,
            'alpha': alpha,
            'alpha_annualized': alpha_annualized,
        }
    
    def generate_summary(self, metrics: Dict) -> str:
        """
        Generate human-readable summary of metrics
        
        Args:
            metrics: Dictionary of calculated metrics
        
        Returns:
            Formatted summary string
        """
        lines = [
            "=" * 50,
            "BACKTEST PERFORMANCE SUMMARY",
            "=" * 50,
            "",
            "Returns:",
            f"  Total Return:        {metrics.get('total_return_pct', 0):.2f}%",
            f"  CAGR:                {metrics.get('cagr_pct', 0):.2f}%",
            f"  Duration:            {metrics.get('duration_days', 0)} days",
            "",
            "Risk Metrics:",
            f"  Sharpe Ratio:        {metrics.get('sharpe_ratio', 0):.3f}",
            f"  Sortino Ratio:       {metrics.get('sortino_ratio', 0):.3f}",
            f"  Volatility (Ann.):   {metrics.get('volatility_annualized_pct', 0):.2f}%",
            f"  VaR (95%):           {metrics.get('var_95_pct', 0):.2f}%",
            "",
            "Drawdown:",
            f"  Max Drawdown:        {metrics.get('max_drawdown_pct', 0):.2f}%",
            f"  Max DD Duration:     {metrics.get('max_drawdown_duration', 0)} bars",
            f"  Underwater Ratio:    {metrics.get('underwater_ratio_pct', 0):.1f}%",
            "",
        ]
        
        if 'total_trades' in metrics:
            lines.extend([
                "Trade Statistics:",
                f"  Total Trades:        {metrics.get('total_trades', 0)}",
                f"  Win Rate:            {metrics.get('win_rate_pct', 0):.1f}%",
                f"  Profit Factor:       {metrics.get('profit_factor', 0):.2f}",
                f"  Expectancy:          ${metrics.get('expectancy', 0):.2f}",
                "",
            ])
        
        lines.append("=" * 50)
        
        return "\n".join(lines)
