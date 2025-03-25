<template>
  <div class="intro">
    <div class="text-container">
      <img src="https://d3gsacqd9y4oge.cloudfront.net/Aira_logo.png" alt="Logo" class="logo" />
      <h2 class="title">요약</h2>
      <p class="notation">* 3차 프로젝트 도입 예정, 예시입니다</p>
      <p class="description">
          아이디어 구상 시, 검증된 방법을 선호하며 <br>
          즉흥적으로 실행에 옮기시는군요! <br>
          혼자 사고하는 것을 더 선호하시지만, <br> 타인의 피드백도 수용하며 협력을 즐기시는 모습입니다.<br>
          실패와 비판에도 침착하게 대처하시고 <br>긍정적으로 극복하는 태도를 지니셨습니다!
      </p>
    </div>
    <button class="btn" @click="goToChat">채팅으로 이동</button>
  </div>
</template>

<script>
export default {
  data () {
    return {
      summary: '요약을 생성 중입니다...'
    }
  },
  methods: {
    goToChat () {
      this.$router.push('/chat')
    }
  }
}
</script>

<style scoped>
/* 메인 컨테이너 스타일 */
.intro {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #e8e8e8;
  color: black;
}

.description {
  font-size: 1.1rem !important;
  font-weight: normal !important;
  margin-bottom: 1rem !important;
  color: #222 !important;
}

/* 로고와 텍스트를 감싸는 부모 컨테이너 */
.text-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 2rem;
}

/* 로고 이미지 스타일 */
.logo {
  width: 50px;
  height: auto;
  margin: 0;
}

/* 제목 스타일 */
.title {
  font-size: 2rem;
  font-weight: bold;
  margin-bottom: 1rem;
  color: #222;
  text-align: center;
}

/* 설명 텍스트 스타일 */
.description {
  font-size: 1.3rem;
  color: #333;
  text-align: left;
  line-height: 1.6;
  margin-top: 0rem;
}

/* 버튼 스타일 */
.btn {
  margin-top: 6%;
  padding: 0.8rem 5rem;
  font-size: 1rem;
  color: #fff;
  background-color: #525252;
  border: none;
  border-radius: 0px;
  cursor: pointer;
  text-align: center;
}

/* 버튼 호버 시 스타일 */
.btn:hover {
  background-color: #555;
}

.notation {
  color: red;
  font-size: 1rem;
  font-weight: bold;
  margin-bottom: 0rem;
  text-align: center; /* 가로 가운데 정렬 (필요 시) */
}
</style>
