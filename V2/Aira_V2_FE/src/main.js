import { createApp } from 'vue'
import App from './App.vue'
import router from './router' // router 연결
import './assets/styles/common.css' // 공통 스타일 로드

const app = createApp(App)
app.use(router) // Vue 애플리케이션에 라우터 추가
app.mount('#app') // #app에 Vue 앱 마운트
