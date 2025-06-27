# ConvertJSON

JSON 파일을 Apple Create ML 프레임워크에서 사용할 수 있는 형식으로 변환하는 macOS/iOS SwiftUI 애플리케이션입니다.

## 기능

- JSON 파일을 드래그앤드롭 또는 파일 열기로 간편하게 로드
- 4가지 Create ML 변환 타입 지원:
  - **텍스트 분류**: 텍스트 데이터를 분류 학습용으로 변환
  - **이미지 분류**: 이미지 데이터를 분류 학습용으로 변환
  - **객체 감지**: 객체 감지용 어노테이션 형식으로 변환
  - **테이블 데이터**: 일반 테이블 데이터를 학습용으로 변환
- 변환된 결과를 JSON 또는 CSV 형식으로 내보내기
- 실시간 텍스트 편집 및 미리보기
- 직관적인 SwiftUI 기반 사용자 인터페이스

## 시스템 요구사항

- macOS 12.0+ 또는 iOS 15.0+
- Xcode 16.4+
- Swift 5.9+

## 설치 및 실행

1. 저장소를 클론합니다:
```bash
git clone https://github.com/username/ConvertJSON.git
cd ConvertJSON
```

2. Xcode에서 프로젝트를 엽니다:
```bash
open convertJson/convertJson.xcodeproj
```

3. 프로젝트를 빌드하고 실행합니다 (Cmd+R)

## 사용 방법

1. 애플리케이션을 실행합니다
2. JSON 파일을 드래그앤드롭하거나 파일 메뉴에서 열기를 선택합니다
3. 원하는 Create ML 변환 타입을 선택합니다 (텍스트 분류, 이미지 분류, 객체 감지, 테이블 데이터)
4. "Create ML 형식으로 변환" 버튼을 클릭합니다
5. 변환된 결과를 확인하고 "JSON으로 내보내기" 또는 "CSV로 내보내기" 버튼으로 저장합니다

## 변환 로직

애플리케이션은 Create ML의 실제 요구사항에 맞게 다음과 같이 JSON 데이터를 변환합니다:

### 텍스트 분류 / 이미지 분류 / 테이블 데이터
- **단일 딕셔너리**: `{"text": "hello", "label": "greeting"}` → `[{"text": "hello", "label": "greeting"}]`
- **배열 (딕셔너리)**: `[{"text": "hi"}, {"text": "bye"}]` → 그대로 유지
- **배열 (기타)**: `["hello", "world"]` → `[{"value": "hello"}, {"value": "world"}]`

### 객체 감지
기존 데이터를 객체 감지 형식으로 변환하거나 템플릿을 제공합니다:
```json
{
  "image": "sample_image.jpg",
  "annotations": [
    {
      "label": "object",
      "coordinates": {
        "x": 0, "y": 0, "width": 100, "height": 100
      }
    }
  ]
}
```

모든 변환 결과는 Apple Create ML에서 바로 사용할 수 있는 표준 형식입니다.

## 프로젝트 구조

```
convertJson/
├── convertJson/
│   ├── convertJsonApp.swift       # 앱 진입점
│   ├── ContentView.swift          # 메인 UI 컴포넌트
│   ├── convertJsonDocument.swift  # 문서 처리 및 변환 로직
│   ├── Info.plist                 # 앱 설정
│   └── Assets.xcassets/           # 앱 리소스
├── convertJsonTests/              # 단위 테스트
└── convertJsonUITests/            # UI 테스트
```

## 기여하기

1. 이 저장소를 포크합니다
2. 새로운 기능 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
5. Pull Request를 생성합니다

## 테스트

```bash
# 단위 테스트 실행
xcodebuild test -scheme convertJson -destination 'platform=macOS'

# UI 테스트 실행
xcodebuild test -scheme convertJson -destination 'platform=macOS' -only-testing:convertJsonUITests
```

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 개발자

- 차원준 (chawj)

## 지원

문제가 발생하거나 기능 요청이 있으시면 GitHub Issues를 통해 알려주세요.

## 관련 링크

- [Apple Create ML Documentation](https://developer.apple.com/documentation/createml)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

Create ML 표준 형식 지원 및 다중 변환 타입 기능 추가
