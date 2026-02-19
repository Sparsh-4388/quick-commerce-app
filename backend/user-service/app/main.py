from fastapi import FastAPI

app = FastAPI(title="User Service")

@app.get("health")
def health():
    return {"status": "user service running"}