@router.get("/result/{request_id}")
async def get_result(request_id: str):
    response = sqs.receive_message(
        QueueUrl=RESPONSE_QUEUE_URL,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=5
    )

    if "Messages" in response:
        for message in response["Messages"]:
            body = json.loads(message["Body"])

            if body["request_id"] == request_id:
                result = body["result"]

                # 처리된 메시지는 삭제
                sqs.delete_message(
                    QueueUrl=RESPONSE_QUEUE_URL,
                    ReceiptHandle=message["ReceiptHandle"]
                )

                return {"status": "completed", "result": result}

    return {"status": "processing", "message": "Request is still being processed"}