// api.js
import axios from 'axios'

// 환경 변수에서 API URL 가져오기
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL

/**
 * 로그인 API 호출 함수
 */
export const handleLogin = async (email, password) => {
  try {
    console.log('Sending login request with:', { email, password })

    const response = await axios.post(
      `${API_BASE_URL}/auth/login`,
      { email, password },
      {
        headers: {
          'Content-Type': 'application/json'
        }
      }
    )

    console.log('Login response:', response.data)

    return {
      success: true,
      data: response.data // access_token 포함
    }
  } catch (error) {
    console.error('Login error:', error.response ? error.response.data : error)

    // 서버에서 반환된 오류 메시지 추출
    const errorMessage =
      error.response && error.response.data && error.response.data.detail
        ? error.response.data.detail
        : '로그인 중 알 수 없는 오류가 발생했습니다.'

    return {
      success: false,
      message: errorMessage // 에러 메시지 반환
    }
  }
}

/**
 * 회원가입 API 호출 함수
 * param {string} nickname 사용자 닉네임
 * param {string} email 사용자 이메일
 * param {string} password 사용자 비밀번호
 * returns {object} 성공 여부와 데이터 또는 에러 메시지
 **/
export const handleSignup = async (nickname, email, password) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/auth/register`, {
      username: nickname, // 닉네임을 username으로 전달
      email,
      password
    })

    return {
      success: true,
      data: response.data
    }
  } catch (error) {
    console.error('회원가입 오류:', error.response ? error.response.data : error)

    // 서버 응답에서 오류 메시지 추출
    const errorMessage =
      error.response && error.response.data && error.response.data.detail
        ? error.response.data.detail
        : '회원가입 중 알 수 없는 오류가 발생했습니다.'

    return {
      success: false,
      message: errorMessage // 에러 메시지 반환
    }
  }
}

/**
 * 질문 답변 제출 API 호출 함수
 * param {object} answers 질문 답변 데이터
 * returns {object} 성공 여부와 메시지
 */
export const submitQuestionAnswers = async (answers) => {
  const token = localStorage.getItem('token') // 저장된 토큰 가져오기
  try {
    const response = await axios.post(`${API_BASE_URL}/questions/submit`, answers, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}` // 인증 헤더 추가
      }
    })

    return {
      success: true,
      data: response.data
    }
  } catch (error) {
    console.error('Error submitting answers:', error)

    // 서버 응답에서 오류 메시지 추출
    const errorMessage =
      error.response && error.response.data && error.response.data.detail
        ? error.response.data.detail
        : '답변 제출에 실패했습니다.'

    return {
      success: false,
      message: errorMessage // 오류 메시지 반환
    }
  }
}

// 사용자 정보 가져오기
export const getUserInfo = async () => {
  const token = localStorage.getItem('token') // 저장된 토큰 가져오기
  try {
    const response = await axios.get(`${API_BASE_URL}/auth/me`, {
      headers: {
        Authorization: `Bearer ${token}` // 인증 헤더에 토큰 추가
      }
    })
    return response.data // 사용자 정보 반환
  } catch (error) {
    console.error('Error fetching user info:', error)
    return null // 오류 발생 시 null 반환
  }
}

/**
 * 챗봇 메시지 전송 API 호출 함수
 */
export const sendMessageToBot = async (message) => {
  const token = localStorage.getItem('token') // 저장된 토큰 가져오기

  try {
    // API 요청
    const response = await axios.post(
      `${API_BASE_URL}/generate/`,
      {
        prompt: message, // 사용자 메시지
        max_tokens: 2000, // 최대 토큰 수
        temperature: 0.7 // 창의성 조절
      },
      {
        headers: {
          'Content-Type': 'application/json', // JSON 데이터임을 명시
          Authorization: `Bearer ${token}` // 인증 헤더 추가
        }
      }
    )
    console.log("Response from backend:", response.data)
    const chatContent = response.data.response
    // 응답 데이터 구조 조정
    return { success: true, response: chatContent } // 백엔드에서 반환한 "response" 필드 사용
  } catch (error) {
    console.error('API 호출 오류:', error.response?.data || error.message)

    // 오류 처리
    return {
      success: false,
      response: '백엔드 통신 오류 발생' // 기본 에러 메시지
    }
  }
}
