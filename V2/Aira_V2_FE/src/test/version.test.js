import { describe, it, expect } from 'vitest'

// 1. 잘못된 잘못된 의존성 버전 사용
describe('Frontend Dependency Version Check', () => {
  it('should throw an error if an invalid version is used', () => {
    const dependencies = {
      vue: '5.0.8' // 잘못된 버전
    }
    expect(() => {
      if (dependencies.vue === '5.0.8') {
        throw new Error('Invalid Vue version: 5.0.8')
      }
    }).toThrowError('Invalid Vue version: 5.0.8')
  })
})
