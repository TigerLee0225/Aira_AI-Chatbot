import { describe, it, expect } from 'vitest'
import dotenv from 'dotenv'
// 유효하지 않은 API 호출 추가에 대한 test

// .env 파일 로드
dotenv.config()

const BASE_URL = process.env.VUE_APP_API_BASE_URL

if (!BASE_URL) {
  throw new Error('BASE_URL is not defined. Check your .env file.')
}

// api 호출 테스트
describe('API URL Validation', () => {
  // BASE_URL을 기준으로 정규식 생성
  const apiUrlPattern = new RegExp(`^${BASE_URL.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')}\\/[a-zA-Z0-9\\-_/]*$`)

  it('should match valid API URL format', () => {
    const validApiUrl = `${BASE_URL}/api/resource`
    expect(validApiUrl).toMatch(apiUrlPattern)
  })

  it('should fail for invalid API URL format', () => {
    const invalidApiUrl = 'http://localhost:3000/api/resource'
    expect(invalidApiUrl).not.toMatch(apiUrlPattern)
  })
})
