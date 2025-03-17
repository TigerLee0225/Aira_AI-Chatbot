<template>
  <div id="app">
    <router-view /> <!-- 라우터를 통해 현재 화면 표시 -->
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>

<style>
body {
  font-family: Arial, sans-serif;
  margin: 0;
  padding: 0;
  background-color: #2c2c2c;
  color: #fff;
}

button {
  margin: 10px;
  padding: 10px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  background: #333;
  color: white;
  transition: background 0.3s ease;
}

button:hover {
  background: #555;
}
</style>
