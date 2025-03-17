import json
import time
import uuid
import boto3
import openai
import os
# import openai  # Uncomment if you're calling the real API
from models.chat import ChatRequest  # Ensure this model is defined appropriately
from fastapi import HTTPException

# Initialize the SQS client
sqs = boto3.client("sqs", region_name="ap-northeast-2")

# Get queue URLs from environment variables (or use defaults for local testing)
REQUEST_QUEUE_URL = os.getenv(
    "REQUEST_QUEUE_URL",
    "https://sqs.ap-northeast-2.amazonaws.com/730335258114/gpt-request-queue.fifo"
)
RESPONSE_QUEUE_URL = os.getenv(
    "RESPONSE_QUEUE_URL",
    "https://sqs.ap-northeast-2.amazonaws.com/730335258114/gpt-response-queue.fifo"
)

# set your OpenAI API key if calling the real API
openai.api_key = os.getenv("OPENAI_API_KEY")

def call_openai_api(request_body: dict) -> dict:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise Exception("OPENAI_API_KEY is not set")
    openai.api_key = api_key

    # Create the client instance
    from openai import OpenAI
    client = OpenAI(api_key=api_key)
    
    prompt = request_body.get("prompt", "")
    max_tokens = request_body.get("max_tokens", 2000)
    temperature = request_body.get("temperature", 0.7)

    print(f"Calling OpenAI API with prompt: {prompt}")
    try:
        chat_completion = client.chat.completions.create(
            model="gpt-4o",  # Adjust to your specific model if needed
            messages=[
                {"role": "user", "content": prompt}
            ],
            max_tokens=max_tokens,
            temperature=temperature
        )
        print("OpenAI API response received")
        return chat_completion.to_dict()
    except Exception as e:
        # Log the full exception details
        error_detail = repr(e)  
        print(f"Error in OpenAI API call: {error_detail}")
        raise Exception(f"OpenAI API 호출 실패: {error_detail}")

def process_generate_request(chat_request: ChatRequest) -> dict:
    request_id = str(uuid.uuid4())
    message_body = {
        "request_id": request_id,
        "prompt": chat_request.prompt,
        "max_tokens": chat_request.max_tokens,
        "temperature": chat_request.temperature,
    }
    
    try:
        sqs.send_message(
            QueueUrl=REQUEST_QUEUE_URL,
            MessageBody=json.dumps(message_body),
            MessageGroupId="default",
            MessageDeduplicationId=request_id
        )
    except Exception as e:
        raise Exception(f"SQS 요청 메시지 전송 실패: {str(e)}")
    
    start_time = time.time()
    iteration = 0
    timeout = 120  # seconds
    while True:
        iteration += 1
        print(f"Polling iteration {iteration}, elapsed time: {time.time() - start_time:.2f} seconds")
        
        try:
            resp = sqs.receive_message(
                QueueUrl=RESPONSE_QUEUE_URL,
                MaxNumberOfMessages=1,
                WaitTimeSeconds=5,
                MessageAttributeNames=["All"]
            )
        except Exception as e:
            raise Exception(f"SQS 응답 메시지 수신 실패: {str(e)}")
        
        if "Messages" in resp:
            for message in resp["Messages"]:
                try:
                    received_message = json.loads(message["Body"])
                except Exception as e:
                    print(f"Error parsing message: {e}")
                    continue
                
                if received_message.get("request_id") == request_id:
                    try:
                        sqs.delete_message(
                            QueueUrl=RESPONSE_QUEUE_URL,
                            ReceiptHandle=message["ReceiptHandle"]
                        )
                    except Exception as e:
                        print(f"Error deleting response message: {e}")
                    return received_message
        
        if time.time() - start_time > timeout:
            raise Exception("SQS 응답 메시지 수신 시간 초과")
        
        time.sleep(1)

def blocking_process_messages():
    print("Starting background SQS processor...")
    while True:
        try:
            response = sqs.receive_message(
                QueueUrl=REQUEST_QUEUE_URL,
                MaxNumberOfMessages=1,
                WaitTimeSeconds=5,
                MessageAttributeNames=["All"]
            )
            if "Messages" in response:
                for message in response["Messages"]:
                    try:
                        request_body = json.loads(message["Body"])
                        request_id = request_body.get("request_id")
                        # Process the request by calling OpenAI API (dummy here)
                        result = call_openai_api(request_body)
                        
                        response_body = {
                            "request_id": request_id,
                            "result": result
                        }
                        
                        sqs.send_message(
                            QueueUrl=RESPONSE_QUEUE_URL,
                            MessageBody=json.dumps(response_body),
                            MessageGroupId="default",
                            MessageDeduplicationId=str(uuid.uuid4())
                        )
                        # Delete the processed message from the request queue
                        sqs.delete_message(
                            QueueUrl=REQUEST_QUEUE_URL,
                            ReceiptHandle=message["ReceiptHandle"]
                        )
                        print(f"Processed message {request_id}")
                    except Exception as e:
                        print(f"Error processing message: {e}")
        except Exception as e:
            print(f"Error receiving messages: {e}")
        time.sleep(1)

async def process_messages():
    import asyncio
    await asyncio.to_thread(blocking_process_messages)