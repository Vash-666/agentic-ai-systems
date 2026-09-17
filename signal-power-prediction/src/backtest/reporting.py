"""
Reporting - Results output and visualization
"""

import json
import logging
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional, Union
import pandas as pd
import numpy as np

logger = logging.getLogger(__name__)


class ReportGenerator:
    """
    Generates reports from backtest results
    """
    
    def __init__(self, output_dir: Optional[Union[str, Path]] = None):
        """
        Initialize report generator
        
        Args:
            output_dir: Directory for saving reports
        """
        self.output_dir = Path(output_dir) if output_dir else Path.cwd()
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"ReportGenerator initialized with output_dir: {self.output_dir}")
    
    def generate_full_report(self,
                            results: Dict[str, Any],
                            metrics: Dict[str, float],
                            equity_curve: pd.DataFrame,
                            trades: Optional[List] = None,
                            save: bool = True,
                            filename_prefix: str = "backtest") -> Dict[str, Any]:
        """
        Generate comprehensive backtest report
        
        Args:
            results: Raw backtest results
            metrics: Calculated performance metrics
            equity_curve: Equity curve DataFrame
            trades: List of trades
            save: Whether to save reports to files
            filename_prefix: Prefix for output filenames
        
        Returns:
            Dictionary containing all report data
        """
        report = {
            'metadata': {
                'generated_at': datetime.now().isoformat(),
                'version': '1.0.0',
            },
            'summary': self._generate_summary(metrics),
            'metrics': metrics,
            'equity_curve': self._format_equity_curve(equity_curve),
            'trades': self._format_trades(trades) if trades else [],
            'charts_data': self._generate_chart_data(equity_curve, metrics),
        }
        
        if save:
            self._save_reports(report, filename_prefix)
        
        logger.info("Full report generated successfully")
        return report
    
    def generate_json_report(self,
                            metrics: Dict[str, float],
                            equity_curve: pd.DataFrame,
                            trades: Optional[List] = None) -> str:
        """
        Generate JSON format report
        
        Args:
            metrics: Performance metrics
            equity_curve: Equity curve DataFrame
            trades: List of trades
        
        Returns:
            JSON string
        """
        report = {
            'generated_at': datetime.now().isoformat(),
            'metrics': self._serialize_metrics(metrics),
            'equity_curve': self._format_equity_curve(equity_curve),
            'trades': self._format_trades(trades) if trades else [],
        }
        
        return json.dumps(report, indent=2, default=str)
    
    def generate_csv_report(self,
                           equity_curve: pd.DataFrame,
                           filename: str = "equity_curve.csv") -> Path:
        """
        Save equity curve to CSV
        
        Args:
            equity_curve: Equity curve DataFrame
            filename: Output filename
        
        Returns:
            Path to saved file
        """
        filepath = self.output_dir / filename
        equity_curve.to_csv(filepath, index=True)
        logger.info(f"Equity curve saved to {filepath}")
        return filepath
    
    def generate_trade_log_csv(self,
                               trades: List,
                               filename: str = "trade_log.csv") -> Path:
        """
        Save trade log to CSV
        
        Args:
            trades: List of trades
            filename: Output filename
        
        Returns:
            Path to saved file
        """
        if not trades:
            logger.warning("No trades to save")
            return None
        
        trades_data = self._format_trades(trades)
        df = pd.DataFrame(trades_data)
        
        filepath = self.output_dir / filename
        df.to_csv(filepath, index=False)
        logger.info(f"Trade log saved to {filepath}")
        return filepath
    
    def generate_text_report(self, metrics: Dict[str, float]) -> str:
        """
        Generate plain text report
        
        Args:
            metrics: Performance metrics
        
        Returns:
            Formatted text report
        """
        lines = [
            "=" * 60,
            "BACKTEST PERFORMANCE REPORT",
            "=" * 60,
            f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "PERFORMANCE SUMMARY",
            "-" * 60,
            f"Initial Capital:       ${metrics.get('initial_capital', 0):,.2f}",
            f"Final Equity:          ${metrics.get('final_equity', 0):,.2f}",
            f"Total Return:          {metrics.get('total_return_pct', 0):+.2f}%",
            f"CAGR:                  {metrics.get('cagr_pct', 0):.2f}%",
            f"Duration:              {metrics.get('duration_days', 0)} days",
            "",
            "RISK METRICS",
            "-" * 60,
            f"Sharpe Ratio:          {metrics.get('sharpe_ratio', 0):.3f}",
            f"Sortino Ratio:         {metrics.get('sortino_ratio', 0):.3f}",
            f"Volatility (Annual):   {metrics.get('volatility_annualized_pct', 0):.2f}%",
            f"VaR (95%):             {metrics.get('var_95_pct', 0):.2f}%",
            f"CVaR (95%):            {metrics.get('cvar_95_pct', 0):.2f}%",
            "",
            "DRAWDOWN ANALYSIS",
            "-" * 60,
            f"Max Drawdown:          {metrics.get('max_drawdown_pct', 0):.2f}%",
            f"Max DD Duration:       {metrics.get('max_drawdown_duration', 0)} bars",
            f"Avg Drawdown:          {metrics.get('avg_drawdown_pct', 0):.2f}%",
            f"Underwater Ratio:      {metrics.get('underwater_ratio_pct', 0):.1f}%",
            "",
        ]
        
        if 'total_trades' in metrics:
            lines.extend([
                "TRADE STATISTICS",
                "-" * 60,
                f"Total Trades:          {metrics.get('total_trades', 0)}",
                f"Winning Trades:        {metrics.get('winning_trades', 0)}",
                f"Losing Trades:         {metrics.get('losing_trades', 0)}",
                f"Win Rate:              {metrics.get('win_rate_pct', 0):.1f}%",
                f"Profit Factor:         {metrics.get('profit_factor', 0):.2f}",
                f"Average Win:           ${metrics.get('avg_win', 0):,.2f}",
                f"Average Loss:          ${metrics.get('avg_loss', 0):,.2f}",
                f"Largest Win:           ${metrics.get('largest_win', 0):,.2f}",
                f"Largest Loss:          ${metrics.get('largest_loss', 0):,.2f}",
                f"Expectancy:            ${metrics.get('expectancy', 0):,.2f}",
                "",
            ])
        
        lines.extend([
            "=" * 60,
            "END OF REPORT",
            "=" * 60,
        ])
        
        return "\n".join(lines)
    
    def generate_html_report(self,
                            metrics: Dict[str, float],
                            equity_curve: pd.DataFrame,
                            trades: Optional[List] = None) -> str:
        """
        Generate HTML report with embedded charts
        
        Args:
            metrics: Performance metrics
            equity_curve: Equity curve DataFrame
            trades: List of trades
        
        Returns:
            HTML string
        """
        # Prepare chart data
        chart_data = self._generate_chart_data(equity_curve, metrics)
        
        html = f"""<!DOCTYPE html>
<html>
<head>
    <title>Backtest Report</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }}
        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 20px;
        }}
        .metrics-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }}
        .metric-card {{
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .metric-label {{
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        .metric-value {{
            font-size: 24px;
            font-weight: bold;
            margin-top: 5px;
        }}
        .positive {{ color: #10b981; }}
        .negative {{ color: #ef4444; }}
        .section {{
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        th, td {{
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }}
        th {{
            background: #f9fafb;
            font-weight: 600;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Backtest Performance Report</h1>
        <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
    
    <div class="metrics-grid">
        <div class="metric-card">
            <div class="metric-label">Total Return</div>
            <div class="metric-value {'positive' if metrics.get('total_return', 0) >= 0 else 'negative'}">
                {metrics.get('total_return_pct', 0):+.2f}%
            </div>
        </div>
        <div class="metric-card">
            <div class="metric-label">CAGR</div>
            <div class="metric-value">{metrics.get('cagr_pct', 0):.2f}%</div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Sharpe Ratio</div>
            <div class="metric-value">{metrics.get('sharpe_ratio', 0):.3f}</div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Max Drawdown</div>
            <div class="metric-value negative">{metrics.get('max_drawdown_pct', 0):.2f}%</div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Win Rate</div>
            <div class="metric-value">{metrics.get('win_rate_pct', 0):.1f}%</div>
        </div>
        <div class="metric-card">
            <div class="metric-label">Profit Factor</div>
            <div class="metric-value">{metrics.get('profit_factor', 0):.2f}</div>
        </div>
    </div>
    
    <div class="section">
        <h2>Performance Metrics</h2>
        <table>
            <tr><th>Metric</th><th>Value</th></tr>
            <tr><td>Initial Capital</td><td>${metrics.get('initial_capital', 0):,.2f}</td></tr>
            <tr><td>Final Equity</td><td>${metrics.get('final_equity', 0):,.2f}</td></tr>
            <tr><td>Total Trades</td><td>{metrics.get('total_trades', 0)}</td></tr>
            <tr><td>Volatility (Annual)</td><td>{metrics.get('volatility_annualized_pct', 0):.2f}%</td></tr>
            <tr><td>Sortino Ratio</td><td>{metrics.get('sortino_ratio', 0):.3f}</td></tr>
            <tr><td>VaR (95%)</td><td>{metrics.get('var_95_pct', 0):.2f}%</td></tr>
        </table>
    </div>
</body>
</html>"""
        
        return html
    
    def save_text_report(self,
                        metrics: Dict[str, float],
                        filename: str = "backtest_report.txt") -> Path:
        """
        Save text report to file
        
        Args:
            metrics: Performance metrics
            filename: Output filename
        
        Returns:
            Path to saved file
        """
        report_text = self.generate_text_report(metrics)
        filepath = self.output_dir / filename
        
        with open(filepath, 'w') as f:
            f.write(report_text)
        
        logger.info(f"Text report saved to {filepath}")
        return filepath
    
    def save_html_report(self,
                        metrics: Dict[str, float],
                        equity_curve: pd.DataFrame,
                        filename: str = "backtest_report.html",
                        trades: Optional[List] = None) -> Path:
        """
        Save HTML report to file
        
        Args:
            metrics: Performance metrics
            equity_curve: Equity curve DataFrame
            filename: Output filename
            trades: List of trades
        
        Returns:
            Path to saved file
        """
        html = self.generate_html_report(metrics, equity_curve, trades)
        filepath = self.output_dir / filename
        
        with open(filepath, 'w') as f:
            f.write(html)
        
        logger.info(f"HTML report saved to {filepath}")
        return filepath
    
    def save_json_report(self,
                        metrics: Dict[str, float],
                        equity_curve: pd.DataFrame,
                        filename: str = "backtest_report.json",
                        trades: Optional[List] = None) -> Path:
        """
        Save JSON report to file
        
        Args:
            metrics: Performance metrics
            equity_curve: Equity curve DataFrame
            filename: Output filename
            trades: List of trades
        
        Returns:
            Path to saved file
        """
        json_str = self.generate_json_report(metrics, equity_curve, trades)
        filepath = self.output_dir / filename
        
        with open(filepath, 'w') as f:
            f.write(json_str)
        
        logger.info(f"JSON report saved to {filepath}")
        return filepath
    
    def _generate_summary(self, metrics: Dict[str, float]) -> Dict[str, Any]:
        """Generate summary section"""
        return {
            'total_return': metrics.get('total_return_pct', 0),
            'cagr': metrics.get('cagr_pct', 0),
            'sharpe_ratio': metrics.get('sharpe_ratio', 0),
            'max_drawdown': metrics.get('max_drawdown_pct', 0),
            'win_rate': metrics.get('win_rate_pct', 0),
            'profit_factor': metrics.get('profit_factor', 0),
        }
    
    def _format_equity_curve(self, equity_curve: pd.DataFrame) -> List[Dict]:
        """Format equity curve for serialization"""
        if equity_curve.empty:
            return []
        
        df = equity_curve.copy()
        
        # Reset index if timestamp is in index
        if isinstance(df.index, pd.DatetimeIndex):
            df = df.reset_index()
            if 'index' in df.columns:
                df.rename(columns={'index': 'timestamp'}, inplace=True)
        
        # Convert timestamps to strings
        if 'timestamp' in df.columns:
            df['timestamp'] = df['timestamp'].astype(str)
        
        return df.to_dict('records')
    
    def _format_trades(self, trades: List) -> List[Dict]:
        """Format trades for serialization"""
        if not trades:
            return []
        
        formatted = []
        for trade in trades:
            trade_dict = {}
            for attr in ['trade_id', 'order_id', 'symbol', 'side', 'quantity', 
                        'price', 'commission', 'timestamp']:
                value = getattr(trade, attr, None)
                if hasattr(value, 'value'):  # Enum
                    value = value.value
                elif isinstance(value, datetime):
                    value = value.isoformat()
                trade_dict[attr] = value
            formatted.append(trade_dict)
        
        return formatted
    
    def _generate_chart_data(self,
                            equity_curve: pd.DataFrame,
                            metrics: Dict[str, float]) -> Dict[str, Any]:
        """Generate data for charts"""
        if equity_curve.empty:
            return {}
        
        # Calculate drawdown series
        equity = equity_curve['equity']
        running_max = equity.expanding().max()
        drawdown = (equity - running_max) / running_max * 100
        
        return {
            'equity_curve': {
                'timestamps': equity_curve.index.astype(str).tolist() if hasattr(equity_curve.index, 'astype') else [],
                'values': equity.tolist(),
            },
            'drawdown': {
                'timestamps': equity_curve.index.astype(str).tolist() if hasattr(equity_curve.index, 'astype') else [],
                'values': drawdown.tolist(),
            },
            'returns_distribution': {
                'mean': metrics.get('avg_daily_return', 0),
                'std': metrics.get('volatility', 0),
            },
        }
    
    def _serialize_metrics(self, metrics: Dict[str, float]) -> Dict[str, Any]:
        """Serialize metrics, handling special types"""
        serialized = {}
        for key, value in metrics.items():
            if isinstance(value, (np.integer, np.floating)):
                serialized[key] = float(value)
            elif isinstance(value, np.ndarray):
                serialized[key] = value.tolist()
            elif pd.isna(value):
                serialized[key] = None
            else:
                serialized[key] = value
        return serialized
    
    def _save_reports(self, report: Dict[str, Any], prefix: str) -> Dict[str, Path]:
        """Save all report formats"""
        saved_files = {}
        
        # JSON report
        json_path = self.output_dir / f"{prefix}_report.json"
        with open(json_path, 'w') as f:
            json.dump(report, f, indent=2, default=str)
        saved_files['json'] = json_path
        
        # Text report
        if 'metrics' in report:
            text_path = self.save_text_report(
                report['metrics'], 
                f"{prefix}_report.txt"
            )
            saved_files['text'] = text_path
        
        logger.info(f"Reports saved: {saved_files}")
        return saved_files
