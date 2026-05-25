# 순간 메모 Android 출시 TODO

## 완료된 작업

- [x] **i18n 다국어 지원** — 한국어/영어 자동 전환 (기기 언어 기준)
  - `pubspec.yaml`: flutter_localizations, intl ^0.19.0, generate: true 추가
  - `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_ko.arb` 생성 (19개 키)
  - `lib/main.dart`: 모든 하드코딩 문자열 → `AppLocalizations` 교체
  - 위젯 테스트: `test/l10n_test.dart` (한/영 2개 테스트 통과)

- [x] **실제 AdMob ID 적용**
  - `lib/main.dart` 배너 유닛 ID: `ca-app-pub-4710152968528474/2033909610`
  - `android/app/src/main/AndroidManifest.xml` 앱 ID: `ca-app-pub-4710152968528474~1950149136`

- [x] **Release 서명 설정 (코드)**
  - `.gitignore`: 서명 파일 제외 설정
  - `android/app/build.gradle`: `signingConfigs.release` 추가
  - `android/key.properties.template`: keystore 설정 가이드 파일 생성

- [x] **GitHub 레포지토리 생성 및 푸시**
  - URL: https://github.com/jykim1011/instant-memo
  - 43개 파일, 공개(public) 레포

---

## 남은 작업

### 1. Keystore 생성 (직접 실행 필요)

PowerShell에서 실행:
```powershell
keytool -genkey -v -keystore C:/Users/junyoung/instant-memo-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias instant-memo
```

비밀번호와 이름 정보를 입력하면 `.jks` 파일이 생성됩니다.

### 2. key.properties 파일 생성 (직접 실행 필요)

`android/key.properties.template`을 복사해서 `android/key.properties`를 만들고 실제 값 입력:

```properties
storePassword=<keystore 비밀번호>
keyPassword=<key 비밀번호>
keyAlias=instant-memo
storeFile=C:/Users/junyoung/instant-memo-release.jks
```

> ⚠️ `key.properties`는 절대 git에 커밋하지 마세요 (.gitignore에 이미 등록됨)

### 3. AAB 빌드

```powershell
cd D:/app-creator-agent/apps/2026-05-24-instant-memo
flutter build appbundle --release
```

성공 시 출력:
```
Built build/app/outputs/bundle/release/app-release.aab
```

### 4. Play Store 제출

[play.google.com/console](https://play.google.com/console)에서:

| 항목 | 상태 | 내용 |
|------|------|------|
| AAB 파일 | 3번 완료 후 | `build/app/outputs/bundle/release/app-release.aab` |
| 앱 이름 (KO) | 준비됨 | 순간 메모 |
| 앱 이름 (EN) | 준비됨 | Instant Memo |
| 짧은 설명 (KO) | 준비됨 | 순간적인 생각을 빠르게 메모하세요 |
| 짧은 설명 (EN) | 준비됨 | Capture fleeting thoughts instantly |
| 전체 설명 | 준비됨 | 아래 참고 |
| 앱 아이콘 512×512 | ⚠️ 준비 필요 | PNG 파일 직접 준비 |
| 스크린샷 (최소 2장) | ⚠️ 준비 필요 | 에뮬레이터/기기에서 캡처 |
| 개인정보처리방침 URL | ⚠️ 준비 필요 | AdMob 사용으로 필수 |
| 콘텐츠 등급 설문 | ⚠️ 준비 필요 | Play Console에서 완료 |

---

## Play Store 앱 설명 초안

### 한국어 (전체 설명)
```
순간 메모는 복잡한 정리 없이 떠오르는 생각을 즉시 기록하는 앱입니다.

✓ 빠른 메모 작성 — 앱을 열고 바로 입력
✓ 진행 중/완료 탭으로 간편한 관리
✓ 스와이프로 삭제
✓ 심플하고 직관적인 UI
✓ 광고 지원 무료 앱

메모장처럼 가볍게, 할 일 목록처럼 체계적으로. 순간의 아이디어를 놓치지 마세요.
```

### 영어 (전체 설명)
```
Instant Memo helps you capture fleeting thoughts before they vanish — no complex organization needed.

✓ Quick capture — open the app and start typing instantly
✓ Active/Completed tabs for easy management
✓ Swipe to delete
✓ Clean and intuitive UI
✓ Free with ads

Light as a notepad, structured as a to-do list. Never lose a moment of inspiration.
```

---

## 참고 파일

- 스펙 문서: `docs/superpowers/specs/2026-05-25-android-release-design.md`
- 구현 계획: `docs/superpowers/plans/2026-05-25-android-release.md`
- GitHub: https://github.com/jykim1011/instant-memo
