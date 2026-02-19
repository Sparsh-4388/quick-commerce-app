from fastapi import FastAPI

app = FastAPI(title="Cart Order Service")

@app.get("health")
def health():
    return {"status": "Cart Order service running"}