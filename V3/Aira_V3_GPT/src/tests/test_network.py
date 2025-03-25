import requests
import pytest

@pytest.mark.parametrize("url", [
    "http://invalid-hostname/api/health",  # 잘못된 호스트
    "http://192.168.99.99:8000/api/health",  # 존재하지 않는 네트워크 IP
    "http://localhost:9999/api/health"  # 잘못된 포트
])
def test_network_security_group(url):
    """
    ✅ 네트워크 보안 테스트
    - 존재하지 않는 호스트, IP 또는 잘못된 포트에 요청을 보내 응답이 차단되는지 확인
    """
    try:
        response = requests.get(url, timeout=5)
    except requests.exceptions.RequestException:
        response = None  # 네트워크 오류 발생

    assert response is None or response.status_code != 200, "❌ 네트워크 오류: 잘못된 API 호출이 성공함"