from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import time

app = FastAPI(title="LocalShop Analytics Service")

class Event(BaseModel):
    event_type: str
    user_id: Optional[str] = None
    product_id: Optional[str] = None
    timestamp: float = time.time()

# In-memory storage for demonstration
events = []

@app.get("/health")
def health_check():
    return {"success": True, "status": "Analytics Service is running"}

@app.post("/events")
async def track_event(event: Event, x_user_id: Optional[str] = Header(None)):
    event.user_id = event.user_id or x_user_id
    events.append(event.dict())
    return {"success": True, "message": "Event tracked"}

@app.get("/stats/summary")
def get_stats():
    return {
        "success": True,
        "data": {
            "total_events": len(events),
            "event_types": list(set([e['event_type'] for e in events]))
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8008)
