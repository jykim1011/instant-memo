파일 쓰기 권한이 필요합니다. 대신 README 전체 내용을 여기 출력합니다.

---

```markdown
# Instant Memo (순간 메모)

> 짧은 아이디어와 임시 정보를 순간적으로 기록하는 생산성 앱

---

## 앱 개요

**Instant Memo**는 복잡한 정리 과정 없이 순간적인 아이디어나 임시 정보를 빠르게 캡처하고 관리할 수 있는 생산성 앱입니다. 사용자는 메모를 즉시 작성하고, 완료된 항목을 토글하거나 스와이프로 삭제하는 등 직관적인 조작으로 휘발성 정보를 효율적으로 처리할 수 있습니다. 불필요한 기능을 배제하고 메모 작성에만 집중할 수 있도록 설계되어 일상 속 생산성을 높여줍니다.

---

## 주요 기능

- **빠른 메모 생성 및 즉시 저장** — 앱을 열자마자 바로 메모 작성 가능
- **활성/완료 메모 필터링** — Segmented Control로 활성 메모와 완료된 메모를 전환하여 조회
- **완료 토글** — 체크박스 탭으로 메모를 완료 처리하거나 활성 상태로 되돌리기
- **스와이프 삭제** — 메모 항목을 스와이프하여 빠르게 제거
- **메모 편집** — 기존 메모 내용을 언제든지 수정
- **메모 삭제** — 편집 화면에서 불필요한 메모를 영구 삭제

---

## 화면 구성

### 화면 1: MemoListScreen — 내 메모

모든 메모를 한눈에 보고 관리하는 메인 화면입니다.

- **AppBar**: `내 메모` 제목 + 활성/완료 전환용 Segmented Control
- **Body**: `ListView.builder`로 메모 목록 렌더링
  - 각 항목은 `ListTile` 구성 — 좌측 완료 체크박스, 중앙 메모 내용, 우측 편집 아이콘
  - 스와이프로 항목 삭제 지원
- **FAB**: 화면 하단 중앙의 `FloatingActionButton`으로 새 메모 추가
- **이동**: `FloatingActionButton` 또는 편집 아이콘 → `MemoFormScreen`

### 화면 2: MemoFormScreen — 메모 추가/편집

새 메모를 작성하거나 기존 메모를 수정하는 화면입니다.

- **AppBar**: 신규 작성 시 `메모 추가`, 편집 시 `메모 편집` 제목 표시
- **Body**: `SingleChildScrollView` > `Padding` > `Column`
  - `TextField(maxLines: null)` — 메모 내용 자유 입력 (멀티라인)
  - `ElevatedButton` — 메모 저장
  - `TextButton` — 기존 메모 편집 시에만 표시되는 삭제 버튼

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| 프레임워크 | Flutter (Dart) |
| 로컬 저장소 | `shared_preferences` |
| 광고 SDK | `google_mobile_ads` (AdMob) |
| 상태 관리 | `setState` (내장) |

---

## 빌드 방법

### 사전 요구 사항

- Flutter SDK 3.x 이상
- Android Studio 또는 Xcode (플랫폼별)
- AdMob 계정 및 앱 ID

### 빌드 명령

```bash
# 패키지 설치
flutter pub get

# 디버그 APK 빌드
flutter build apk --debug
```

---

## AdMob ID 교체 안내

앱 배포 전 반드시 테스트 ID를 실제 AdMob ID로 교체해야 합니다.

### 교체 위치

**`android/app/src/main/AndroidManifest.xml`**
```xml
<!-- 아래 테스트 ID를 실제 앱 ID로 교체 -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

**`lib/main.dart` 또는 광고 위젯 파일**
```dart
// 테스트 배너 ID (교체 필요)
const String bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

### 테스트 ID (개발용)

| 플랫폼 | 테스트 배너 Ad Unit ID |
|--------|----------------------|
| Android | `ca-app-pub-3940256099942544/6300978111` |
| iOS | `ca-app-pub-3940256099942544/2934735716` |

> 실제 ID는 AdMob 콘솔에서 앱을 등록한 후 발급받을 수 있습니다.

---

## 데이터 저장 방식

메모 데이터는 `shared_preferences`를 통해 기기 로컬에 JSON 직렬화 형태로 저장됩니다.

| 키 | 타입 | 설명 |
|----|------|------|
| `instant_memo_list` | `String` (JSON) | 전체 메모 목록 (Memo 객체 배열을 JSON으로 직렬화) |

### Memo 객체 구조 (JSON)

```json
{
  "id": "uuid-string",
  "content": "메모 내용",
  "isCompleted": false,
  "createdAt": "2026-05-24T10:00:00.000Z"
}
```

> 앱 삭제 시 저장된 모든 데이터도 함께 삭제됩니다.

---

## 라이선스

This project is for personal/educational use. All rights reserved.
```

---

파일 저장은 `D:/app-creator-agent/apps/2026-05-24-instant-memo/README.md` 경로에 쓰기 권한을 허용해주시면 바로 저장할 수 있습니다. 허용하시겠습니까?