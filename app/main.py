import logging
import secrets

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.openapi.docs import HTMLResponse, get_swagger_ui_html
from fastapi.openapi.utils import get_openapi
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBasic, HTTPBasicCredentials

from app import exception_handler
from app.settings import Settings

settings = Settings()
security = HTTPBasic()
app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)

# 例外ハンドラの登録
exception_handler.init_app(app)

# このアプリケーションのログ設定
root_logger = logging.getLogger("app")
root_logger.addHandler(logging.StreamHandler())
root_logger.setLevel(settings.LOG_LEVEL)


@app.get("/", include_in_schema=False)
@app.get("/health", include_in_schema=False)
def health() -> JSONResponse:
    """ヘルスチェック"""
    return JSONResponse({"message": "It worked!!"})


@app.get("/docs", include_in_schema=False)
async def get_documentation(credentials: HTTPBasicCredentials = Depends(security)) -> HTMLResponse:
    if not _validate_credentials(credentials):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return get_swagger_ui_html(openapi_url="/openapi.json", title="docs")


@app.get("/openapi.json", include_in_schema=False)
async def get_open_api_endpoint(
    credentials: HTTPBasicCredentials = Depends(security),
) -> JSONResponse:
    if not _validate_credentials(credentials):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Basic"},
        )
    return JSONResponse(get_openapi(title="FastAPI Template", version="1", routes=app.routes))


def _validate_credentials(credentials: HTTPBasicCredentials) -> bool:
    correct_username = secrets.compare_digest(credentials.username, settings.BASIC_USER_NAME)
    correct_password = secrets.compare_digest(credentials.password, settings.BASIC_PASSWORD)
    return correct_username and correct_password


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
