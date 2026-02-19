from fastapi import FastAPI

app = FastAPI(title="Delivery Service")

@app.get("health")
def health():
    return {"status": "delivery service running"}