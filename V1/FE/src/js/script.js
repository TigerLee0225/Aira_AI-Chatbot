// 백엔드 API 설정
const BE_PUBLIC_IP = "http://aira-be-alb-1145499117.ap-northeast-2.elb.amazonaws.com"; // 백엔드 주소 입력

// DOM 요소
const sendBtn = document.getElementById("send-btn");
const userInput = document.getElementById("user-input");
const chatOutput = document.getElementById("chat-output");

// 채팅 전송 함수
async function sendMessage() {
    const userMessage = userInput.value.trim();

    if (userMessage) {
        toggleInputState(true); // 입력창과 버튼 비활성화
        appendMessage(userMessage, "user"); // 사용자 메시지 추가

        try {
            const response = await fetch(`${BE_PUBLIC_IP}/generate/`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    prompt: userMessage,
                    max_tokens: 200,
                    temperature: 0.7,
                }),
            });

            if (!response.ok) {
                throw new Error("Failed to fetch response from server.");
            }

            const data = await response.json();
            appendMessage(data.response, "gpt"); // GPT 응답 메시지 추가
        } catch (error) {
            appendMessage("Error: 백엔드 통신 실패", "gpt"); // 에러 메시지 처리
        }

        toggleInputState(false); // 입력창과 버튼 활성화
        userInput.value = ""; // 입력창 초기화
    }
}

// 입력창 및 버튼 상태를 토글하는 함수
function toggleInputState(isDisabled) {
    userInput.disabled = isDisabled; // 입력창 비활성화/활성화
    sendBtn.disabled = isDisabled; // 버튼 비활성화/활성화
    if (isDisabled) {
        sendBtn.style.opacity = "0.5"; // 비활성화 시 시각적 효과
        sendBtn.style.cursor = "not-allowed"; // 클릭 불가능 표시
    } else {
        sendBtn.style.opacity = "1"; // 활성화 시 원래 상태
        sendBtn.style.cursor = "pointer"; // 클릭 가능 표시
    }
}

// 메시지 추가 함수
function appendMessage(message, sender) {
    const messageElement = document.createElement("div");
    messageElement.classList.add("chat-message", sender);
    messageElement.textContent = message;
    chatOutput.appendChild(messageElement);

    // 스크롤 자동 이동
    chatOutput.scrollTop = chatOutput.scrollHeight;
}

// 엔터 키 입력 이벤트
userInput.addEventListener("keydown", (event) => {
    if (event.key === "Enter") {
        event.preventDefault();
        if (!userInput.disabled) { // 입력창이 활성화된 경우에만 실행
            sendMessage();
        }
    }
});

// 버튼 클릭 이벤트
sendBtn.addEventListener("click", () => {
    if (!sendBtn.disabled) { // 버튼이 활성화된 경우에만 실행
        sendMessage();
    }
});