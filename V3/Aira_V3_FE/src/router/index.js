import { createRouter, createWebHistory } from 'vue-router'
import SignupForm from '../components/SignupForm.vue'
import LoginForm from '../components/LoginForm.vue'
import AiraIntro from '../components/AiraIntro.vue'
import QuestionAll from '../components/QuestionAll.vue'
import Summary from '../components/SummaryPage.vue'
import ChatPage from '../components/ChatPage.vue'

const routes = [
  { path: '/', redirect: '/login' }, // 기본 경로를 로그인 페이지로 설정
  { path: '/signup', component: SignupForm },
  { path: '/login', component: LoginForm },
  { path: '/intro', component: AiraIntro },
  { path: '/question', component: QuestionAll },
  { path: '/summary', component: Summary },
  { path: '/chat', component: ChatPage }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
