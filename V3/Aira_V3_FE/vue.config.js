// vue.config.js
const { defineConfig } = require('@vue/cli-service')
const path = require('path')

// 환경 변수에서 API URl 가져오기
const API_BASE_URL = process.env.VUE_APP_API_BASE_URL
const WS_HOSTNAME = API_BASE_URL ? new URL(API_BASE_URL).hostname : 'default-hostname';
//주석 코드에서 사용하지만 깃에 업로드 되는 코드에서는 사용되지 않음
// 사용되지 않는 변수는 ESLint 가 오류로 확인하여 로그를 출력하는 것으로 에러 막음
console.log(`WebSocket Hostname is: ${WS_HOSTNAME}`);

module.exports = defineConfig({
  transpileDependencies: true,
  configureWebpack: {
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'src') // '@'를 src로 매핑
      }
    }
  },
  // 로컬 환경에서 적용
  devServer: {
      proxy: {
        "/api": {
          target: "http://127.0.0.1:8000", // FastAPI 백엔드 주소
          changeOrigin: true,
          pathRewrite: { "^/api": "" }, // "/api"를 제거하고 백엔드로 전달
        },
      },
    },

  // 배포 환경에서 적용하나 이제는 안 씀. Nginx를 쓰기 때문에 devServer는 무시함
  /*
  devServer: {
    host: '0.0.0.0', // Listen on all interfaces
    allowedHosts: 'all', // Accept requests from any host
    headers: {
      'Access-Control-Allow-Origin': '*'
    },
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:8000', // FastAPI 백엔드 주소
        changeOrigin: true,
        pathRewrite: { '^/api': '' } // "/api"를 제거하고 백엔드로 전달
      }
    },
    // Add a simple health check endpoint for ALB to use
    setupMiddlewares: (middlewares, devServer) => {
      if (devServer && devServer.app) {
        devServer.app.get('/health', (req, res) => {
          res.sendStatus(200)
        })
      }
      return middlewares
    },
    client: {
      webSocketURL: {
        hostname: WS_HOSTNAME, // Now uses the parsed hostname from API_BASE_URL
        port: 80,
        protocol: 'ws' // Use "wss" if your ALB uses HTTPS
      }
    }
  }
  */
})
