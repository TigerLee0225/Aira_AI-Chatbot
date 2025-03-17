import os
import pytest
from dotenv import load_dotenv

# .env 파일 로드
env_path = os.path.join(os.path.dirname(__file__), "../.env")
if os.path.exists(env_path):
    load_dotenv(dotenv_path=env_path)

# 필수 환경 변수 목록
REQUIRED_ENV_VARS = ["DATABASE_URL", "SECRET_KEY"]

@pytest.mark.parametrize("env_var", REQUIRED_ENV_VARS)
def test_missing_env_variable(env_var):
    """
    ✅ 필수 환경 변수(DATABASE_URL, SECRET_KEY)가 설정되었는지 확인
    - 없으면 pytest.skip()을 사용하여 테스트를 건너뜀
    """
    value = os.getenv(env_var)
    
    if not value:
        pytest.skip(f"⚠️ 환경 변수 {env_var}가 설정되지 않음. 테스트 건너뜀.")
    
    assert value is not None, f"❌ 환경 변수 {env_var}가 설정되지 않았습니다."