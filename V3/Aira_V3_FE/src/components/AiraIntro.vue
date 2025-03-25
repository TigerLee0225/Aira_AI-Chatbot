<template>
  <div class="intro">
    <!-- 로고와 설명 텍스트를 포함하는 컨테이너 -->
    <div class="text-container">
      <!-- 로고 이미지 -->
      <img src="https://d3gsacqd9y4oge.cloudfront.net/Aira_logo.png" alt="Aira 로고" class="logo">

      <!-- 설명 텍스트 -->
      <p class="description">지금부터<br>당신만의 Aira 조각을<br>도와드리겠습니다.</p>
    </div>
    <!-- 버튼 -->
    <button class="btn" @click="goToNext">Next</button>
  </div>
</template>

<script>
export default {
  methods: {
    goToNext () {
      this.$router.push('/question') // Question1으로 이동
    }
  }
}
</script>

<style scoped>
/* 메인 컨테이너 스타일 */
.intro {
    /* 플렉스 박스를 사용하여 자식 요소를 배치 */
    display: flex;
    /* 요소를 세로 방향으로 정렬 */
    flex-direction: column;
    /* 자식 요소를 수평으로 중앙 정렬 */
    align-items: center;
    /* 자식 요소를 수직으로 중앙 정렬 */
    justify-content: center;
    /* 화면 전체 높이를 사용 */
    height: 100vh;
    /* 배경색을 밝은 회색으로 설정 */
    background-color: #e8e8e8;
    /* 텍스트 기본 색상을 검정색으로 설정 */
    color: black;

}

/* 로고와 텍스트를 감싸는 부모 컨테이너 */
.text-container {
    display: flex; /* 플렉스 박스를 사용하여 자식 요소를 정렬 */
    flex-direction: column; /* 로고와 텍스트를 세로로 배치 */
    align-items: flex-start; /* 자식 요소를 위쪽(텍스트 시작점)으로 정렬 */
    gap: 1rem; /* 로고와 설명 텍스트 간격 설정 */
    margin-bottom: 2rem; /* 로고와 텍스트 아래 여백 추가 */
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

/* 설명 텍스트 스타일 */
.description {
    /* 설명 글자의 크기 설정 */
    font-size: 1.3rem;
    /* 텍스트 색상을 중간 회색으로 설정 */
    color: #333;
    /* 텍스트를 왼쪽에 정렬 */
    text-align: left;
    /* 텍스트 줄 간격 추가 */
    line-height: 1.6;
}

/* 버튼 스타일 */
.btn {
    /* 버튼이랑 설명텍스트 간격 */
    margin-top: 6%;
    /* 버튼 내부 여백 설정 (위아래, 좌우) */
    padding: 0.8rem 5rem;
    /* 버튼 글자 크기 설정 */
    font-size: 1rem;
    /* 버튼 텍스트 색상을 흰색으로 설정 */
    color: #fff;
    /* 버튼 배경색을 짙은 회색으로 설정 */
    background-color: #525252;
    /* 버튼 테두리를 제거 */
    border: none;
    /* 버튼 모서리를 둥글게 설정 */
    border-radius: 0px;
    /* 커서를 클릭 가능하도록 설정 */
    cursor: pointer;
    /* 텍스트 정렬을 가운데로 설정 */
    text-align: center;
}

/* 버튼 호버 시 스타일 */
.btn:hover {
    /* 호버 시 버튼 배경색을 더 밝은 회색으로 변경 */
    background-color: #555;
}
</style>
