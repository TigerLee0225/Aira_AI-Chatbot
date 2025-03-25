#!/bin/bash

# ==========================
# AWS 환경 설정
# ==========================
AWS_DEFAULT_REGION="ap-northeast-2"
IAM_PROFILE_NAME="Aira-Node-IAM"  # 새로 연결할 IAM 인스턴스 프로파일 이름

# ==========================
# 1. 현재 인스턴스 ID 확인 (IMDSv2 지원)
# ==========================
echo "🔎 인스턴스 ID 가져오는 중..."

# IMDSv2 토큰 요청
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# IMDSv2 지원 여부 확인 후 인스턴스 ID 가져오기
if [[ -n "$TOKEN" ]]; then
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/instance-id")
else
    INSTANCE_ID=$(curl -s "http://169.254.169.254/latest/meta-data/instance-id")
fi

# 인스턴스 ID가 정상적으로 가져왔는지 확인
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ 인스턴스 ID를 가져올 수 없습니다. 스크립트를 종료합니다."
    exit 1
fi
echo "✅ 현재 인스턴스 ID: $INSTANCE_ID"

# ==========================
# 2. 현재 IAM Instance Profile 확인
# ==========================
echo "🔎 현재 연결된 IAM Instance Profile 확인..."
CURRENT_PROFILE=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].IamInstanceProfile.Arn' --output text)

if [[ "$CURRENT_PROFILE" == "None" || -z "$CURRENT_PROFILE" ]]; then
    echo "⚠️ 연결된 IAM Instance Profile이 없습니다."
else
    echo "✅ 현재 연결된 IAM Instance Profile: $CURRENT_PROFILE"
    echo "🚨 기존 IAM Instance Profile 연결 해제..."
    
    ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations \
        --filters Name=instance-id,Values="$INSTANCE_ID" \
        --query 'IamInstanceProfileAssociations[*].AssociationId' --output text)

    if [[ -n "$ASSOCIATION_ID" ]]; then
        aws ec2 disassociate-iam-instance-profile --association-id "$ASSOCIATION_ID"
        echo "✅ 기존 IAM Instance Profile이 해제되었습니다."
    else
        echo "⚠️ 기존 IAM Instance Profile이 없습니다."
    fi
fi

# ==========================
# 3. 새로운 IAM Instance Profile 연결
# ==========================
echo "🔄 새로운 IAM Instance Profile 연결 중..."
aws ec2 associate-iam-instance-profile --instance-id "$INSTANCE_ID" \
    --iam-instance-profile Name="$IAM_PROFILE_NAME"

echo "✅ 새로운 IAM Instance Profile 연결 완료."

# ==========================
# 4. IMDS 설정 변경
# ==========================
echo "🔄 IMDS 설정을 변경하여 HttpTokens를 'optional'로 설정 중..."
aws ec2 modify-instance-metadata-options --instance-id "$INSTANCE_ID" \
    --http-tokens optional --http-endpoint enabled

echo "✅ IMDS 설정 변경 완료."

# ==========================
# 5. 최종 설정 확인
# ==========================
echo "🔍 새로운 IAM 설정 및 IMDS 설정 확인..."
aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[*].Instances[*].{IMDS:MetadataOptions,IAMProfile:IamInstanceProfile}'

echo "🚀 IMDS 및 IAM Role 설정 완료! 이제 쿠버네티스에서 정상적으로 AWS 리소스를 사용할 수 있습니다."