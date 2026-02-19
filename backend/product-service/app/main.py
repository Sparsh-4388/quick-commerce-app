from fastapi import FastAPI

app = FastAPI(title="Product Service")

@app.get("health")
def health():
    return {"status": "product service running"}