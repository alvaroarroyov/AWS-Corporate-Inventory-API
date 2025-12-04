from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Corporate Inventory API v1.0", "status": "Running"}

@app.get("/health")
def read_health():
    return {"status": "healthy"}