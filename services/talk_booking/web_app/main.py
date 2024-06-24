from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/ping")
def ping():
    return {"message": "pong"}
