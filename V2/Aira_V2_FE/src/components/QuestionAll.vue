<template>
  <div class="questions">
    <!-- 질문 네비게이션 -->
    <div class="tabs">
      <div v-for="(tab, index) in tabs" :key="index" class="tab-container">
        <button :class="{ active: activeTab === index }" @click="activeTab = index">
          {{ tab }}
        </button>
        <!-- 체크박스: 질문이 완료된 경우 체크 -->
        <div class="completion-checkbox">
          <label>
            <input type="checkbox" :checked="!!answers[`answer${index + 1}`]" disabled />
          </label>
        </div>
      </div>
    </div>

    <!-- 질문 내용 -->
    <div v-if="filteredQuestions.length > 0" class="question-container">
      <div v-for="(question, index) in filteredQuestions" :key="index">
        <div class="question-content">
          <h2 class="question-title">{{ question.title }}</h2>
          <p class="question-body" v-html="question.body"></p>
        </div>
        <img :src="question.image" alt="질문 관련 이미지" class="center-image" />
        <div class="options">
          <label v-for="(option, optIndex) in question.options" :key="optIndex">
            <input
              type="radio"
              :name="'question' + activeTab"
              :value="optIndex + 1"
              v-model="answers[`answer${activeTab + 1}`]"
              @change="markCompletion(activeTab)"
            />
            <span v-html="option.label"></span>
          </label>
        </div>
      </div>
    </div>
    <button :disabled="Object.values(answers).includes('')" @click="handleSubmit">제출하기</button>
  </div>
</template>

<script>
import { submitQuestionAnswers } from '../api/api.js' // 추가된 API 호출
import { showAlert } from '../utils.js'

export default {
  data () {
    return {
      activeTab: 0, // 활성화된 탭
      tabs: ['Q1', 'Q2', 'Q3', 'Q4', 'Q5'], // 탭 이름
      answers: { answer1: '', answer2: '', answer3: '', answer4: '', answer5: '' }, // 각 질문의 답변 저장
      questions: [
        // 질문 데이터
        {
          title: 'Q1. 개방성',
          body: '새로운 아이디어를 생각할 때<br>당신은 얼마나 독창적인<br>접근 방식을 선호하시나요?',
          image: 'https://d3gsacqd9y4oge.cloudfront.net/Question1.png',
          options: [
            { label: '검증된 방법이<br />효과적인 것 같아요.' },
            { label: '창의적인 방법<br />찾는 걸 좋아해요.' }
          ]
        },
        {
          title: 'Q2. 성실성',
          body: '아이디어를 발전시키기 위해<br>얼마나 체계적으로 계획을<br>세우고 실행하나요?',
          image: 'https://d3gsacqd9y4oge.cloudfront.net/Question2.png',
          options: [
            { value: '1', label: '떠오르는 생각을<br />바로 실행에 옮겨요.' },
            { value: '2', label: '아이디어 구체화<br />계획부터 세워요.' }
          ]
        },
        {
          title: 'Q3. 외향성',
          body: '아이디어를 발전시키기 위해<br>다른 사람들과의 협업이나 <br>브레인스토밍을 선호하시나요?',
          image: 'https://d3gsacqd9y4oge.cloudfront.net/Question3.png',
          options: [
            { value: '1', label: '혼자 생각할 때 아이디어<br />발전에 더 효과적이에요.' },
            { value: '2', label: '사람들과 나누고 협업하면<br />좋은 생각이 떠올라요.' }
          ]
        },
        {
          title: 'Q4. 친화성',
          body: '아이디어를 구상할 때<br>다른 사람들의 피드백을<br>얼마나 중요하게 생각하시나요?',
          image: 'https://d3gsacqd9y4oge.cloudfront.net/Question4.png',
          options: [
            { value: '1', label: '타인의 피드백을 수용하고<br />협력하는 과정을 즐겨요.' },
            { value: '2', label: '타인의 의견보다 제 생각을<br />스스로 판단하는 편이예요.' }
          ]
        },
        {
          title: 'Q5. 정서적 안정성',
          body: '비판이나 실패가<br>아이디어 구상에<br>얼마나 영향을 미치나요?',
          image: 'https://d3gsacqd9y4oge.cloudfront.net/Question5.png',
          options: [
            { value: '1', label: '침착하게 대처하고,<br />새로운 방법을 찾아 나가요.' },
            { value: '2', label: '작은 문제나 비판에 스트레스를<br />받고 힘들어지곤해요.' }
          ]
        }
      ]
    }
  },
  computed: {
    filteredQuestions () {
      // activeTab에 맞는 질문 반환
      if (this.activeTab >= 0 && this.activeTab < this.questions.length) {
        return [this.questions[this.activeTab]]
      }
      return []
    }
  },
  methods: {
    markCompletion (index) {
      if (this.answers[`answer${index + 1}`]) {
        console.log(`Question ${index + 1} completed`)
      }
    },

    async handleSubmit () {
      const answers = {
        answer1: this.answers.answer1,
        answer2: this.answers.answer2,
        answer3: this.answers.answer3,
        answer4: this.answers.answer4,
        answer5: this.answers.answer5
      }

      try {
        const result = await submitQuestionAnswers(answers)

        if (result?.success) {
          showAlert('성공', '답변이 성공적으로 제출되었습니다.', 'success')

          // 제출 후 요약 페이지로 이동
          this.$router.push('/summary')
        } else {
          console.error('제출 실패 메시지:', result?.message || '알 수 없는 오류')
          showAlert(
            '제출 실패',
            result?.message ? `오류: ${result.message}` : '답변 제출에 실패했습니다.',
            'error'
          )
        }
      } catch (error) {
        console.error('답변 제출 중 오류 발생:', error)

        const errorMessage =
          error.response && error.response.data && error.response.data.detail
            ? error.response.data.detail
            : '답변 제출에 실패했습니다.'

        showAlert('오류', errorMessage, 'error')
      }
    }
  }
}
</script>

<style scope>
/* 질문 전체 컨테이너 */
.questions {
  background-color: #e8e8e8;
  padding: 1rem 2rem; /* 위쪽 padding 값을 줄여서 탭이 더 위로 올라가도록 설정 */
  border-radius: 0px;
  /* 화면 전체 높이를 사용 */
  height: 100vh;
}

/* 탭 컨테이너 */
.tabs {
  display: flex; /* 버튼을 가로로 배치 */
  justify-content: space-between; /* 버튼 간격 조정 */
  margin-top: -1rem; /* 음수 margin을 사용해 탭 컨테이너를 더 위로 이동 */
  overflow-x: auto; /* 내용이 넘칠 경우 스크롤 가능 */
  white-space: nowrap; /* 줄바꿈 방지 */
}

/* 각 탭의 버튼 스타일 */
.tabs button {
  padding: 0.5rem 1rem;
  border: none;
  background: #ccc;
  cursor: pointer;
  border-radius: 0px;
}
.tabs button.active {
  font-weight: bold;
  color: white;
  background: #525252;
  border-radius: 0px;
}

/* 완료 체크박스 스타일 */
.completion-checkbox {
  display: flex; /* Flexbox 활성화 */
  justify-content: center; /* 가로 중앙 정렬 */
  align-items: center; /* 세로 중앙 정렬 */
  gap: 0.3rem; /* 체크박스와 레이블 사이의 간격 */
  margin-top: 0.5rem; /* 질문 제목과 체크박스 간 간격 */
}

.completion-checkbox label {
  font-size: 0.9rem; /* 글씨 크기 */
  color: #333; /* 글씨 색상 */
}

/* 질문 내용 스타일 */
.question-container {
  margin: 2rem 0;
  display: flex; /* Flexbox 활성화 */
  flex-direction: column; /* 세로 정렬 */
  align-items: center; /* 가로 중앙 정렬 */
  text-align: center; /* 모든 텍스트 중앙 정렬 */
}
.question-content {
  background-color: #e8e8e8;
  padding: 1.5rem;
  border-radius: 10px;
  margin-bottom: 1rem;
  box-shadow: none;
  text-align: center; /* 질문 제목과 본문을 가운데 정렬 */
}
/* 질문 제목 스타일 */
.question-title {
  color: #FF5935; /* 제목 색상 */
  font-size: 1rem; /* 제목 글씨 크기 */
  font-weight: normal; /* 제목 굵기 */
  margin-bottom: 1rem; /* 제목 아래 여백 */
  text-align: center; /* 제목을 가운데 정렬 */
  margin-left: 0; /* 왼쪽 여백 제거 */
  margin-right: 0; /* 오른쪽 여백 제거 */
}
.question-body {
  color: black;
  font-size: 1.2rem;
  line-height: 1.5;
  text-align: center; /* 본문을 가운데 정렬 */
  margin: 0rem auto;
}
.center-image {
  display: block;
  margin: 1rem auto; /* 이미지 위아래 여백 추가 */
  width: 250px;
  margin-bottom: 0rem;
}
.options {
  display: flex; /* Flexbox 활성화 */
  flex-direction: row; /* 세로 정렬 */
  align-items: center; /* 가운데 정렬 */
  margin-top: 1.7rem;
  margin-bottom: 0rem; /* 라디오 버튼 선택지와 제출 버튼 간의 거리 조정 */
  gap: 1rem; /* 라디오 버튼들 사이에 간격 추가 */
  color: black;
}
.options label {
  display: block;
  margin: 0.5rem 0;
  text-align: center; /* 라벨 가운데 정렬 */
}

/* 제출 버튼 스타일 */
button {
  padding: 0.8rem 1.5rem;
  background-color: #525252;
  color: white;
  font-size: 1rem;
  border: none;
  border-radius: 0px;
  cursor: pointer;
  margin: 2rem auto 0; /* 가로 방향 가운데 정렬 및 위쪽 여백 추가 */
  display: block; /* 블록 요소로 설정 */
}

button:disabled {
  background-color: #ccc; /* 비활성화 버튼 배경색 */
  cursor: not-allowed; /* 비활성화 포인터 설정 */
}

</style>
