<template>
  <div class="login-wrapper"> <!-- 최상위 요소로 래핑 -->
    <div class="button-signup">
      <button @click="goToSignup">회원가입</button>
    </div>
    <div class="login-page">
      <div class="login-container">
        <!-- 로고 이미지 -->
        <img src="https://d3gsacqd9y4oge.cloudfront.net/Aira_logo.png" alt="Aira 로고" class="logo">

        <h1>로그인</h1>

        <!-- 이메일 입력 필드 -->
        <div class="form-group">
          <label for="email">이메일</label>
          <input type="email" v-model="email" id="email" placeholder="" />
        </div>

        <!-- 비밀번호 입력 필드 -->
        <div class="form-group">
          <label for="password">비밀번호</label>
          <input type="password" v-model="password" id="password" placeholder="" />
        </div>

        <!-- 로그인 버튼 -->
        <div class="form-group">
          <button class="login-btn" :disabled="!isFormValid" @click="handleLogin">
            로그인
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { handleLogin } from '../api/api.js'
import { showAlert } from '../utils.js'

export default {
  data () {
    return {
      email: '',
      password: ''
    }
  },
  computed: {
    isEmailValid () {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(this.email)
    },
    isFormValid () {
      return this.isEmailValid && this.password.length > 0
    }
  },
  methods: {
    async handleLogin () {
      try {
        const result = await handleLogin(this.email, this.password)

        if (result.success) {
          localStorage.setItem('token', result.data.access_token) // 토큰 저장
          showAlert('성공', '로그인 성공!', 'success') // 로그인 성공 알림
          this.$router.push('/intro') // 로그인 성공 시 Intro 페이지로 이동
        } else {
          console.log('로그인 실패 메시지:', result.message) // 디버깅 로그

          if (result.message.includes('Invalid credentials')) {
            showAlert(
              '로그인 실패',
              '이메일 또는 패스워드가 일치하지 않습니다.',
              'error'
            )
          } else {
            showAlert(
              '로그인 실패',
              `오류: ${result.message}`,
              'error'
            )
          }
        }
      } catch (error) {
        console.error('Unexpected error during login:', error)

        showAlert(
          '오류',
          '로그인 중 알 수 없는 오류가 발생했습니다.',
          'error'
        )
      }
    },
    goToSignup () {
      this.$router.push('/signup') // 회원가입 페이지로 이동
    }
  }
}
</script>

<style scoped>
/* 페이지 배경색 설정 */
.button-signup {
  height: auto; /* 고정 높이를 제거 */
  padding: 0; /* 버튼 내부 위아래 여백 제거 */
  margin: 0; /* 버튼 외부 여백 제거 */
  background-color: #e8e8e8; /* 버튼 배경색 */
  text-align: left; /* 버튼 텍스트를 왼쪽 정렬 */
  position: fixed; /* 화면 상단에 고정 */
  top: 0; /* 페이지의 가장 위로 배치 */
  left: 0; /* 왼쪽에 정렬 */
  width: auto; /* 너비를 콘텐츠 크기에 맞춤 */
  padding: 10px 20px; /* 버튼 내부 좌우 여백 설정 */
  z-index: 1000; /* 다른 요소 위에 위치 */
}

.login-page {
  background-color: #e8e8e8;
  min-height: calc(100vh - 5vh); /* 버튼 높이만큼 제외 */
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

/* 로그인 컨테이너 스타일 */
.login-container {
  max-width: 400px; /* 컨테이너 최대 너비 */
  background: transparent; /* 컨테이너 배경 투명 */
  padding: 20px; /* 내부 여백 */
  border-radius: 0px; /* 직각 모서리 */
  box-shadow: none; /* 그림자 제거 */
  margin-top: -170px; /* 컨테이너를 위로 이동 */
}

/* 제목 스타일 */
h1 {
  text-align: left; /* 텍스트를 왼쪽 정렬 */
  margin-bottom: 30px; /* 제목 아래 여백 */
  color: #333; /* 제목 색상 */
  font-size: 1.7rem; /* 글자 크기 */
  font-weight: normal; /* 기본 글자 두께 */
}
/* 입력 그룹 스타일 */
.form-group {
  position: relative;
  margin-bottom: 15px;
  min-height: 4.5rem;
  max-width: 350px; /* 입력 필드와 동일한 최대 너비 */
  width: 100%;
}

/* 입력 필드 라벨 스타일 */
label {
  display: block; /* 라벨을 블록 요소로 설정 */
  margin-bottom: 5px; /* 라벨과 입력 필드 간 간격 */
  color: #555; /* 라벨 텍스트 색상 */
  font-size: 1rem; /* 라벨 글자 크기 */
}

/* 입력 필드 스타일 */
input {
  width: 100%;
  padding: 12px;
  border: 1px solid #e8e8e8;
  border-radius: 0px;
  font-size: 0.8rem;
  outline: none;
  transition: border-color 0.3s;
  box-sizing: border-box;
}

input:focus {
  border-color: #b6b5b5; /* 포커스 시 테두리 색상 */
}

/* 버튼 스타일 */
button {
    /* 버튼의 안쪽 여백 설정 (위아래 0.8rem, 좌우 2rem) */
    padding: 0.8rem 1rem;
    /* 글자 크기를 1rem으로 설정 */
    font-size: 0.8rem;
    /* 버튼 배경색을 파란색으로 설정 */
    background-color: #ccc;
    /* 버튼 텍스트 색상을 흰색으로 설정 */
    color: white;
    /* 버튼의 테두리를 제거 */
    border: none;
    /* 버튼의 모서리를 둥글게 설정 */
    border-radius: 0px;
    /* 커서를 클릭 가능하도록 설정 */
    cursor: pointer;
}

/* 로고 이미지 스타일 */
.logo {
    /* 로고 이미지의 너비 설정 */
    width: 50px;
    /* 이미지 비율 유지 */
    height: auto;
    /* 로고를 컨테이너 기준으로 오른쪽으로 이동 */
    margin: 0;
}

/* 오류 메시지 스타일 */
.error {
  color: red; /* 오류 메시지 색상 */
  font-size: 0.8rem; /* 글자 크기 */
  margin-top: 5px; /* 위쪽 간격 */
  margin-left: 5px; /* 왼쪽 간격 */
  min-height: 1.2rem; /* 최소 높이 설정 */
  width: 100%; /* 부모 요소의 너비에 맞게 설정 */
  white-space: pre-wrap; /* 공백과 줄바꿈 유지 */
  overflow-wrap: break-word; /* 긴 텍스트 자동 줄바꿈 */
  box-sizing: border-box; /* 크기 계산에 테두리와 패딩 포함 */
}

/* 버튼 스타일 */
.login-btn {
  width: 100%; /* 버튼 너비를 컨테이너에 맞춤 */
  padding: 12px; /* 내부 여백 */
  background: #525252; /* 버튼 배경색 */
  color: #fff; /* 버튼 텍스트 색상 */
  border: none; /* 테두리 제거 */
  border-radius: 0px; /* 모서리를 직각으로 설정 */
  font-size: 1rem; /* 글자 크기 */
  font-weight: bold; /* 굵은 글씨 */
  cursor: pointer; /* 클릭 가능한 커서 */
  transition: background-color 0.3s; /* 배경색 전환 효과 */
  align-items: center;
}

.login-btn:disabled {
  background: #ccc; /* 비활성화된 버튼 배경색 */
  cursor: not-allowed; /* 클릭 불가 커서 */
}

.login-btn:hover:not(:disabled) {
  background: #525252; /* 활성화된 버튼에 마우스를 올릴 때 배경색 */
}
</style>
