import { describe, it, expect } from 'vitest'

// 컴파일 오류가 발생하는 코드 주입 테스트
/* eslint-disable no-undef */ // 파일 전체에서 no-undef 규칙 비활성화

describe('Compile Error Test', () => {
  // 1. undefinedFunction() 호출 시 ReferenceError가 발생하는지 확인
  it('should throw an error when an undefined function is called', () => {
    const callUndefinedFunction = () => {
      // eslint-disable-next-line no-undef
      undefinedFunction() // 존재하지 않는 함수 호출
    }

    expect(callUndefinedFunction).toThrowError(ReferenceError)
  })

  // 2. 객체에서 존재하지 않는 메서드(nonExistentMethod()) 호출 시 TypeError가 발생하는지 확인
  it('should throw an error when a non-existent method is called on an object', () => {
    const obj = {}
    const callUndefinedMethod = () => {
      obj.nonExistentMethod() // 객체에서 존재하지 않는 메서드 호출
    }

    expect(callUndefinedMethod).toThrowError(TypeError)
  })

  // 3. undefined 객체에서 속성을 접근하려고 할 때 TypeError가 발생하는지 확인
  it('should throw an error when trying to access a property of undefined', () => {
    const obj = undefined
    const accessUndefinedProperty = () => {
      console.log(obj.someProperty) // undefined에서 속성 접근
    }

    expect(accessUndefinedProperty).toThrowError(TypeError)
  })
})
