module.exports = {
    // Vue CLI를 사용하지 않는 경우 기본 설정
    moduleFileExtensions: ['js', 'json', 'vue'],
    transform: {
      '^.+\\.vue$': 'vue-jest',       // .vue 파일 변환
      '^.+\\.js$': 'babel-jest'        // JavaScript 파일 변환
    },
    // 테스트 파일 경로 패턴을 지정 (현재 src/test 폴더 내에 테스트 파일이 있음)
    testMatch: ['**/src/test/**/*.test.js'],
    // 커버리지 수집을 활성화
    collectCoverage: true,
    coverageDirectory: 'coverage', // 커버리지 리포트 폴더를 루트의 /coverage로 지정
    // 커버리지 수집 시 포함할 파일들 (필요에 따라 조정)
    collectCoverageFrom: ['src/**/*.{js,vue}', '!**/node_modules/**']
  };