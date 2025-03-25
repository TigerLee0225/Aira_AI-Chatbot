<template>
  <div class="chat-container">
    <h1>Aira</h1>

    <!-- 메인 이미지 -->
    <main>
      <div class="center-image">
        <img src="https://d3gsacqd9y4oge.cloudfront.net/Aira_chat.png" alt="Mars Central Image">
      </div>
    </main>

    <!-- 채팅 인터페이스 -->
    <section id="chat-window">
      <div id="chat-output">
        <div v-for="(message, index) in messages" :key="index" class="chat-message" :class="message.sender">
          {{ message.text }}
        </div>
      </div>
      <div id="chat-input-container">
        <input v-model="userInput" type="text" placeholder="Type your message..." @keyup.enter="sendMessage" />
        <button @click="sendMessage" :disabled="isDisabled">↑</button>
      </div>
    </section>
  </div>
</template>

<script>
import { ref } from 'vue'
import { sendMessageToBot } from '../api/api.js' // API 호출 함수

export default {
  setup () {
    const userInput = ref('') // 사용자 입력 저장
    const messages = ref([]) // 채팅 메시지 목록
    const isDisabled = ref(false) // 버튼 비활성화 상태

    const sendMessage = async () => {
      if (userInput.value.trim() === '') return

      isDisabled.value = true

      // 사용자 메시지 추가
      messages.value.push({ text: userInput.value, sender: 'user' })

      try {
        console.log("Sending message:", userInput.value)
        const response = await sendMessageToBot(userInput.value)
        console.log("Response received:", response)
        if (response.success) {
          messages.value.push({ text: response.response, sender: 'gpt' })
        } else {
          messages.value.push({ text: 'Error: 백엔드 통신 실패', sender: 'gpt' })
        }
      } catch (error) {
        messages.value.push({ text: 'Error: 백엔드 통신 실패', sender: 'gpt' })
      }

      isDisabled.value = false
      userInput.value = ''
    }

    return { userInput, messages, sendMessage, isDisabled }
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900&family=Quicksand:wght@300..700&display=swap');

/* 기본 리셋 */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

h1 {
  font-size: 60px;
  font-weight: 300;
  font-family: "Poppins", serif;
  text-shadow: 0 0 10px rgba(255, 255, 255, 0.7);
}

/* 전체 컨테이너 스타일 */
.chat-container {
  font-family: 'Pretendard', Arial, sans-serif;
  background: linear-gradient(180deg, #CCCCCC 0%, #B7B7B7 100%);
  text-align: center;
  padding: 50px;
  height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  overflow: hidden;
}

/* 메인 이미지 스타일 */
.center-image img {
  width: 100%;
  height: auto;
  object-fit: cover;
  margin-top: -50px;
  margin-bottom: -70px;
}

/* 채팅창 컨테이너 */
#chat-window {
  position: relative;
  width: 90%;
  height: 100vh;
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  flex-grow: 1;
}

/* 채팅 출력 영역 */
#chat-output {
  width: 100%;
  height: 50vh;
  overflow-y: auto;
  padding: 10px;
  font-size: 16px;
  color: white;
  line-height: 1.5;
  border-radius: 5px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

/* 채팅 메시지 공통 스타일 */
.chat-message {
    max-width: 90%; /* 채팅 메시지 길이를 입력창과 동일하게 설정 */
    padding: 10px;
    margin: 5px 0;
    line-height: 1.5;
    font-size: 16px;
    color: white;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.7); /* 흰색 효과 추가 */
}

/* 사용자 메시지 스타일 (오른쪽 정렬, 파란색 말풍선) */
.chat-message.user {
    align-self: flex-end;
    text-align: right;
}

/* AI 메시지 스타일 (왼쪽 정렬, 회색 말풍선) */
.chat-message.gpt {
    align-self: flex-start;
    text-align: left;
}

/* 채팅창 컨테이너 */
#chat-window {
  position: relative;
  width: 90%;
  height: 70vh;
  max-width: 500px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  flex-grow: 1;
}

/* 채팅 출력 영역 */
#chat-output {
  width: 100%;
  height: 30vh;
  overflow-y: auto;
  padding: 10px;
  font-size: 16px;
  color: white;
  line-height: 1.5;
  border-radius: 5px;
  margin-bottom: 15px;
}

/* 입력창과 버튼 컨테이너 */
#chat-input-container {
  display: flex;
  justify-content: center; /* 입력창과 버튼 간 간격을 균등하게 유지 */
  align-items: center; /* 세로 중앙 정렬 */
  width: 30%; /* 컨테이너 전체 너비 사용 */
  position: fixed;
  bottom: 20px; /* 화면 하단에서 20px 위 */
  left: 50%; /* 화면 중앙으로 이동 */
  transform: translateX(-50%); /* 중앙 정렬 */
  padding: 10px 0; /* 위아래 여백 추가 */
  background: transparent; /* 투명 배경 */
}

#chat-input-container input {
  flex: 1; /* 입력창이 남는 공간을 모두 차지 */
  padding: 10px;
  font-size: 16px;
  border: none; /* 모든 테두리 제거 */
  border-bottom: 2px solid white; /* 하단에 흰색 밑줄 추가 */
  background: transparent !important; /* 배경을 완전히 제거 */
  color: white; /* 텍스트 색상을 흰색으로 설정 */
  outline: none; /* 포커스 외곽선 제거 */
}

#chat-input-container input::placeholder {
  color: rgba(255, 255, 255, 0.5); /* 투명한 흰색 플레이스홀더 */
}

#chat-input-container input:focus {
  border-bottom: 2px solid white; /* 포커스 시 밑줄 강조 */
}

/* 버튼 스타일 */
button {
  background: transparent;
  font-size: 20px;
  border: none;
  border-radius: 5px;
  margin-left: 10px;
  padding: 10px 15px;
  cursor: pointer;
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
