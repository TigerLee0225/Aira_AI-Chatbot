<template>
  <div class="signup-wrapper"> <!-- 최상위 요소 추가 -->
    <div class="button-login">
      <button @click="goToLogin">로그인</button>
    </div>
    <div class="signup-page">
      <div class="signup-container">
        <!-- 로고 이미지 -->
        <img src="https://d3gsacqd9y4oge.cloudfront.net/Aira_logo.png" alt="Aira 로고" class="logo">
        <h1>회원가입</h1>

        <!-- 닉네임 입력 필드 -->
        <div class="form-group">
          <label for="nickname">닉네임</label>
          <input type="text" v-model="nickname" id="nickname" placeholder="" />
        </div>

        <!-- 이메일 입력 필드 -->
        <div class="form-group">
          <label for="email">이메일</label>
          <input type="email" v-model="email" id="email" placeholder="" />
        </div>

        <!-- 비밀번호 입력 필드 -->
        <div class="form-group">
          <label for="password">비밀번호</label>
          <input type="password" v-model="password" id="password" placeholder="" />
          <div class="error" :class="{ hidden: isPasswordValid }">
            *8자리 이상, 영어, 숫자, 특수문자 포함
          </div>
        </div>

        <!-- 비밀번호 확인 필드 -->
        <div class="form-group">
          <label for="confirmPassword">비밀번호 확인</label>
          <input type="password" v-model="confirmPassword" id="confirmPassword" placeholder="" />
          <div v-if="isPasswordMismatch" class="error">
            비밀번호가 일치하지 않습니다.
          </div>
        </div>

        <!-- 회원가입 버튼 -->
        <div class="form-group">
          <button class="signup-btn" :disabled="!isFormValid" @click="handleSignup">
            회원가입
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { handleSignup } from '../api/api.js'
import { showAlert } from '../utils.js'

export default {
  data () {
    return {
      nickname: '',
      email: '',
      password: '',
      confirmPassword: ''
    }
  },
  computed: {
    isPasswordValid () {
      const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
      return passwordRegex.test(this.password)
    },
    isPasswordMismatch () {
      return this.password !== this.confirmPassword && this.confirmPassword.length > 0
    },
    isFormValid () {
      return (
        this.nickname &&
        this.email &&
        this.isPasswordValid &&
        !this.isPasswordMismatch
      )
    }
  },
  methods: {
    async handleSignup () {
      try {
        const result = await handleSignup(this.nickname, this.email, this.password)

        if (result.success) {
          showAlert('성공', '회원가입에 성공했습니다!', 'success')

          // 입력 필드 초기화
          this.nickname = ''
          this.email = ''
          this.password = ''
          this.confirmPassword = ''

          // 회원가입 성공 시 로그인 페이지로 이동
          this.$router.push('/login')
        } else {
          console.log('회원가입 실패 메시지:', result.message) // 디버깅 로그

          if (result.message.includes('Username already registered')) {
            showAlert(
              '회원가입 실패',
              '이미 존재하는 아이디입니다.',
              'error'
            )
          } else if (result.message.includes('Email already registered')) {
            showAlert(
              '회원가입 실패',
              '이미 존재하는 이메일입니다.',
              'error'
            )
          } else {
            showAlert(
              '회원가입 실패',
              `오류: ${result.message}`,
              'error'
            )
          }
        }
      } catch (error) {
        console.error('회원가입 중 오류 발생:', error)

        showAlert(
          '회원가입 실패',
          '회원가입 중 오류가 발생했습니다.',
          'error'
        )
      }
    },
    goToLogin () {
      this.$router.push('/login') // 로그인 페이지로 이동
    }
  }
}
</script>

<style scoped>
/* 페이지 배경색 설정 */
.button-login {
  height: auto;
  padding: 0;
  margin: 0;
  background-color: #e8e8e8;
  text-align: left;
  position: fixed;
  top: 0;
  left: 0;
  width: auto;
  padding: 10px 20px;
  z-index: 1000;
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

.signup-page {
  background-color: #e8e8e8;
  min-height: calc(100vh - 5vh);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

/* 회원가입 컨테이너 스타일 */
.signup-container {
  max-width: 400px;
  background: transparent;
  padding: 20px;
  border-radius: 0px;
  box-shadow: none;
}

/* 입력 그룹 스타일 */
.form-group {
  position: relative;
  margin-bottom: 15px;
  min-height: 4.5rem;
  max-width: 350px; /* 입력 필드와 동일한 최대 너비 */
  width: 100%;
}

/* 제목 스타일 */
h1 {
  text-align: left;
  margin-bottom: 30px;
  color: #333;
  font-size: 1.7rem;
  font-weight: normal;
}

/* 입력 필드 라벨 스타일 */
label {
  display: block;
  margin-bottom: 5px;
  color: #555;
  font-size: 1rem;
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
  border-color: #b6b5b5;
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
/* 오류 메시지 스타일 */
.error {
  color: red;
  font-size: 0.8rem;
  margin-top: 5px;
  min-height: 1.2rem;
  width: 100%;
  white-space: pre-wrap;
  overflow-wrap: break-word;
  box-sizing: border-box;
}

.error.hidden {
  visibility: hidden;
  opacity: 0;
  height: 0;
  overflow: hidden;
  transition: visibility 0.3s, opacity 0.3s;
}

/* 버튼 스타일 */
.signup-btn {
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

.signup-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.signup-btn:hover:not(:disabled) {
  background: #525252;
}
</style>
