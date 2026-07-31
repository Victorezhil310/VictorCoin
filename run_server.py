import sys
import os
import uvicorn

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

if __name__ == "__main__":
    print("🚀 Starting VictorCoin API Server on http://localhost:8000...")
    print("📖 Swagger API Documentation: http://localhost:8000/docs")
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
