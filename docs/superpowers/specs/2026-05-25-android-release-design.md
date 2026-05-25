# 순간 메모 Android 출시 계획

## 개요

Flutter 앱 "순간 메모(Instant Memo)"를 Google Play Store에 출시하기 위한 단계별 작업 계획.
한국어/영어 다국어 지원(i18n), Release 서명 설정, AdMob 실제 ID 적용, GitHub 푸시를 포함한다.

---

## 앱 기본 정보

| 항목 | 값 |
|------|-----|
| 앱 이름 (KO) | 순간 메모 |
| 앱 이름 (EN) | Instant Memo |
| 패키지명 | `com.appcreator.instant_memo` |
| 버전 | 1.0.0+1 |
| 플랫폼 | Android (Flutter) |
| AdMob 앱 ID | `ca-app-pub-4710152968528474~1950149136` |
| 배너 광고 유닛 ID | `ca-app-pub-4710152968528474/2033909610` |

---

## 1단계: i18n 다국어 지원

### 목표
기기 언어에 따라 한국어/영어 자동 전환. 단일 앱, 단일 Play Store 등록.

### 작업 내용
- `pubspec.yaml`에 `flutter_localizations`, `intl` 추가
- `flutter.generate: true` 설정
- `lib/l10n/app_ko.arb` — 한국어 문자열
- `lib/l10n/app_en.arb` — 영어 문자열 (기본값)
- `MaterialApp`에 `localizationsDelegates`, `supportedLocales` 추가
- 모든 하드코딩 한국어 문자열을 `AppLocalizations.of(context)!.xxx`로 교체

### 번역 대상 문자열
| Key | 한국어 | 영어 |
|-----|--------|------|
| `appTitle` | 순간 메모 | Instant Memo |
| `myMemos` | 내 메모 | My Memos |
| `active` | 활성 | Active |
| `completed` | 완료 | Completed |
| `addMemo` | 메모 추가 | Add Memo |
| `editMemo` | 메모 편집 | Edit Memo |
| `deleteMemo` | 메모 삭제 | Delete Memo |
| `deleteConfirm` | 이 메모를 삭제하시겠습니까? | Delete this memo? |
| `deleteConfirmPermanent` | 이 메모를 영구적으로 삭제하시겠습니까? | Permanently delete this memo? |
| `cancel` | 취소 | Cancel |
| `delete` | 삭제 | Delete |
| `save` | 저장 | Save |
| `hintText` | 지금 떠오르는 생각을 적어보세요... | Write down what comes to mind... |
| `emptyActive` | 아직 메모가 없습니다.\n+ 버튼을 눌러 첫 메모를 작성해보세요. | No memos yet.\nTap + to write your first memo. |
| `emptyCompleted` | 완료된 메모가 없습니다. | No completed memos. |
| `memoDeleted` | 메모가 삭제되었습니다. | Memo deleted. |
| `emptyContent` | 메모 내용을 입력해 주세요. | Please enter memo content. |
| `deleteThisMemo` | 이 메모 삭제 | Delete this memo |

---

## 2단계: Release 서명 설정

### 목표
Play Store 제출용 서명된 AAB 빌드 생성.

### 작업 내용

**Keystore 생성 (사용자 실행):**
```bash
keytool -genkey -v -keystore ~/instant-memo-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias instant-memo
```

**`android/key.properties` 생성 (Git 제외):**
```
storePassword=<keystore 비밀번호>
keyPassword=<key 비밀번호>
keyAlias=instant-memo
storeFile=<keystore 파일 절대 경로>
```

**`android/app/build.gradle` 수정:**
- `signingConfigs.release` 블록 추가
- `buildTypes.release`에 `signingConfig signingConfigs.release` 적용

**`.gitignore` 추가:**
```
android/key.properties
*.jks
*.keystore
```

---

## 3단계: AdMob 실제 ID 적용

### 작업 내용
- `android/app/src/main/AndroidManifest.xml`에 메타데이터 추가:
  ```xml
  <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="ca-app-pub-4710152968528474~1950149136"/>
  ```
- `lib/main.dart` 배너 광고 유닛 ID 교체:
  ```dart
  adUnitId: 'ca-app-pub-4710152968528474/2033909610',
  ```

---

## 4단계: GitHub 푸시

### 작업 내용
- `gh repo create instant-memo --public --description "Quick memo app for Flutter"` 실행
- 앱 디렉토리를 루트로 초기화 후 푸시
- `key.properties`, `*.jks` 등 민감 파일은 `.gitignore`로 제외

---

## 5단계: Play Store 제출 준비

### AAB 빌드
```bash
flutter build appbundle --release
```
출력: `build/app/outputs/bundle/release/app-release.aab`

### Play Console 등록 체크리스트

| 항목 | 내용 | 상태 |
|------|------|------|
| 앱 아이콘 | 512×512 PNG | 준비 필요 |
| 스크린샷 | 최소 2장 (폰) | 준비 필요 |
| 앱 이름 (KO) | 순간 메모 | 완료 |
| 앱 이름 (EN) | Instant Memo | 완료 |
| 짧은 설명 (KO) | 순간적인 생각을 빠르게 메모하세요 | 완료 |
| 짧은 설명 (EN) | Capture fleeting thoughts instantly | 완료 |
| 전체 설명 (KO) | 아래 참조 | 완료 |
| 전체 설명 (EN) | 아래 참조 | 완료 |
| 개인정보처리방침 | URL 필요 (AdMob 사용으로 필수) | 준비 필요 |
| 콘텐츠 등급 | 설문 완료 필요 | 준비 필요 |
| 가격 | 무료 | 완료 |

### 앱 설명 초안

**한국어 (전체 설명):**
```
순간 메모는 복잡한 정리 없이 떠오르는 생각을 즉시 기록하는 앱입니다.

✓ 빠른 메모 작성 — 앱을 열고 바로 입력
✓ 활성/완료 탭으로 간편한 관리
✓ 스와이프로 삭제
✓ 심플하고 직관적인 UI
✓ 광고 지원 무료 앱

메모장처럼 가볍게, 할 일 목록처럼 체계적으로. 순간의 아이디어를 놓치지 마세요.
```

**영어 (전체 설명):**
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

## 진행 순서 요약

1. [x] 설계 문서 작성
2. [ ] i18n 코드 작업 (ARB 파일 + MaterialApp 설정)
3. [ ] AdMob 실제 ID 적용 (AndroidManifest + main.dart)
4. [ ] Keystore 생성 및 서명 설정
5. [ ] `.gitignore` 업데이트
6. [ ] GitHub 레포 생성 및 푸시
7. [ ] `flutter build appbundle --release` 빌드 확인
8. [ ] Play Console 제출
