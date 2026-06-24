"""
Real-time market data ingestion via WebSocket.
Supports multiple data providers (Polygon, Alpaca).
"""

import asyncio
import json
import os
from dataclasses import dataclass
from datetime import datetime
from typing import Callable, Dict, List, Optional
import structlog

logger = structlog.get_logger()


@dataclass
class MarketTick:
    """Standardized market tick data."""
    symbol: str
    timestamp: datetime
    price: float
    size: float
    bid: Optional[float] = None
    ask: Optional[float] = None
    volume: Optional[float] = None
    source: str = "unknown"


class WebSocketFeed:
    """Base class for WebSocket market data feeds."""
    
    def __init__(self, symbols: List[str], on_tick: Callable[[MarketTick], None]):
        self.symbols = symbols
        self.on_tick = on_tick
        self.connected = False
        self.buffer: List[MarketTick] = []
        self.max_buffer = int(os.getenv("MAX_BUFFER_SIZE", "1000"))
        
    async def connect(self):
        """Establish WebSocket connection."""
        raise NotImplementedError
        
    async def disconnect(self):
        """Close WebSocket connection."""
        raise NotImplementedError
        
    def _buffer_tick(self, tick: MarketTick):
        """Buffer tick for batch processing."""
        self.buffer.append(tick)
        if len(self.buffer) >= int(os.getenv("BATCH_SIZE", "100")):
            self._flush_buffer()
            
    def _flush_buffer(self):
        """Process buffered ticks."""
        for tick in self.buffer:
            self.on_tick(tick)
        self.buffer.clear()


class PolygonWebSocket(WebSocketFeed):
    """Polygon.io WebSocket feed."""
    
    WS_URL = "wss://socket.polygon.io/stocks"
    
    def __init__(self, symbols: List[str], on_tick: Callable[[MarketTick], None]):
        super().__init__(symbols, on_tick)
        self.api_key = os.getenv("POLYGON_API_KEY")
        if not self.api_key:
            raise ValueError("POLYGON_API_KEY not set")
            
    async def connect(self):
        """Connect to Polygon WebSocket."""
        import websockets
        
        uri = f"{self.WS_URL}?apiKey={self.api_key}"
        
        try:
            self.ws = await websockets.connect(uri)
            self.connected = True
            logger.info("Connected to Polygon WebSocket", symbols=self.symbols)
            
            # Subscribe to trades
            subscribe_msg = {
                "action": "subscribe",
                "params": f"T.{','.join(self.symbols)}"
            }
            await self.ws.send(json.dumps(subscribe_msg))
            
            # Start message loop
            await self._message_loop()
            
        except Exception as e:
            logger.error("Polygon connection failed", error=str(e))
            await self._reconnect()
            
    async def _message_loop(self):
        """Process incoming messages."""
        import websockets
        
        try:
            async for message in self.ws:
                data = json.loads(message)
                await self._handle_message(data)
        except websockets.exceptions.ConnectionClosed:
            logger.warning("Polygon connection closed")
            await self._reconnect()
            
    async def _handle_message(self, data: Dict):
        """Parse and process Polygon message."""
        if data.get("ev") == "T":  # Trade event
            tick = MarketTick(
                symbol=data["sym"],
                timestamp=datetime.fromtimestamp(data["t"] / 1000),
                price=data["p"],
                size=data["s"],
                source="polygon"
            )
            self._buffer_tick(tick)
            
    async def _reconnect(self):
        """Reconnect with exponential backoff."""
        self.connected = False
        delay = int(os.getenv("WEBSOCKET_RECONNECT_SECONDS", "5"))
        logger.info(f"Reconnecting in {delay} seconds...")
        await asyncio.sleep(delay)
        await self.connect()
        
    async def disconnect(self):
        """Disconnect from WebSocket."""
        if self.connected and hasattr(self, 'ws'):
            await self.ws.close()
            self.connected = False
            logger.info("Disconnected from Polygon")


class AlpacaWebSocket(WebSocketFeed):
    """Alpaca Markets WebSocket feed."""
    
    WS_URL = "wss://stream.data.alpaca.markets/v2/iex"
    
    def __init__(self, symbols: List[str], on_tick: Callable[[MarketTick], None]):
        super().__init__(symbols, on_tick)
        self.api_key = os.getenv("ALPACA_API_KEY")
        self.secret_key = os.getenv("ALPACA_SECRET_KEY")
        if not self.api_key or not self.secret_key:
            raise ValueError("ALPACA_API_KEY and ALPACA_SECRET_KEY must be set")
            
    async def connect(self):
        """Connect to Alpaca WebSocket."""
        import websockets
        
        try:
            self.ws = await websockets.connect(self.WS_URL)
            self.connected = True
            logger.info("Connected to Alpaca WebSocket")
            
            # Authenticate
            auth_msg = {
                "action": "auth",
                "key": self.api_key,
                "secret": self.secret_key
            }
            await self.ws.send(json.dumps(auth_msg))
            
            # Subscribe to trades
            subscribe_msg = {
                "action": "subscribe",
                "trades": self.symbols
            }
            await self.ws.send(json.dumps(subscribe_msg))
            
            await self._message_loop()
            
        except Exception as e:
            logger.error("Alpaca connection failed", error=str(e))
            await self._reconnect()
            
    async def _message_loop(self):
        """Process incoming messages."""
        import websockets
        
        try:
            async for message in self.ws:
                data = json.loads(message)
                for item in data:
                    await self._handle_message(item)
        except websockets.exceptions.ConnectionClosed:
            logger.warning("Alpaca connection closed")
            await self._reconnect()
            
    async def _handle_message(self, data: Dict):
        """Parse and process Alpaca message."""
        if data.get("T") == "t":  # Trade message
            tick = MarketTick(
                symbol=data["S"],
                timestamp=datetime.fromisoformat(data["t"].replace("Z", "+00:00")),
                price=data["p"],
                size=data["s"],
                source="alpaca"
            )
            self._buffer_tick(tick)
            
    async def _reconnect(self):
        """Reconnect with delay."""
        self.connected = False
        delay = int(os.getenv("WEBSOCKET_RECONNECT_SECONDS", "5"))
        logger.info(f"Reconnecting in {delay} seconds...")
        await asyncio.sleep(delay)
        await self.connect()
        
    async def disconnect(self):
        """Disconnect from WebSocket."""
        if self.connected and hasattr(self, 'ws'):
            await self.ws.close()
            self.connected = False
            logger.info("Disconnected from Alpaca")


class MultiMarketFeed:
    """Aggregate feeds from multiple markets."""
    
    def __init__(self):
        self.feeds: List[WebSocketFeed] = []
        self.tick_handlers: List[Callable[[MarketTick], None]] = []
        
    def add_feed(self, feed: WebSocketFeed):
        """Add a feed to the aggregator."""
        # Wrap the feed's on_tick to notify all handlers
        original_on_tick = feed.on_tick
        
        def wrapped_on_tick(tick: MarketTick):
            original_on_tick(tick)
            for handler in self.tick_handlers:
                handler(tick)
                
        feed.on_tick = wrapped_on_tick
        self.feeds.append(feed)
        
    def on_tick(self, handler: Callable[[MarketTick], None]):
        """Register a tick handler."""
        self.tick_handlers.append(handler)
        
    async def start(self):
        """Start all feeds."""
        tasks = [feed.connect() for feed in self.feeds]
        await asyncio.gather(*tasks)
        
    async def stop(self):
        """Stop all feeds."""
        for feed in self.feeds:
            await feed.disconnect()


# Example usage
if __name__ == "__main__":
    import os
    
    # Load symbols from environment
    stocks = os.getenv("STOCKS", "AAPL,MSFT").split(",")
    
    def on_tick(tick: MarketTick):
        print(f"{tick.symbol}: ${tick.price:.2f} @ {tick.timestamp}")
        
    async def main():
        feed = PolygonWebSocket(stocks, on_tick)
        try:
            await feed.connect()
        except KeyboardInterrupt:
            await feed.disconnect()
            
    asyncio.run(main())
