# My PHR

個人の健康記録を管理する Rails アプリケーションです。プロフィール・健康ログ・運動記録・カスタム項目を登録し、日次/週次/月次サマリーで振り返りができます。UI は Bootstrap と Material Design のスタイルガイドに沿って構築しています。

## セットアップ

### 1. 依存関係のインストール

Docker を利用する場合は以下でイメージを構築します。

```bash
docker compose build
```

ローカルで実行する場合は Ruby 3.2.3 と Bundler を用意し、次のコマンドを実行します。

```bash
bundle install
bin/rails db:setup
```

### 2. アプリの起動

```bash
docker compose up
# もしくは
bin/rails server
```

ブラウザで `http://localhost:3000` を開くとダッシュボードが表示されます。

### 3. テストの実行

```bash
docker compose run --rm web bundle exec rspec
# または
bundle exec rspec
```

## 主な機能

- **ダッシュボード**: 最新の健康ログと週次サマリーをカード形式で表示。
- **基本情報管理**: プロフィールの編集とカスタム項目(JSON)の登録。
- **健康ログ入力**: 日付、スコア(1〜5)、メモ、運動記録を登録/編集/削除。
- **サマリー閲覧**: 日次・週次・月次を切り替えて平均指標や活動内訳を確認。
- **カスタム項目 API**: profile/health/activity の各カテゴリで選択肢や数値項目を定義可能。

## API エンドポイント

| メソッド | パス | 説明 |
| --- | --- | --- |
| GET | /api/v1/profile | プロフィール取得 |
| POST/PUT | /api/v1/profile | プロフィール作成・更新 |
| GET/POST/PATCH/DELETE | /api/v1/custom_fields | カスタム項目 CRUD |
| GET | /api/v1/health_logs | 日付範囲で健康ログ一覧 |
| POST/PUT/DELETE | /api/v1/health_logs | 健康ログ CRUD（運動記録をネスト） |
| GET | /api/v1/summaries?period=daily\|weekly\|monthly | サマリー取得 |

詳細な UI スタイルガイドは `design/Readme.md` を参照してください。

## 開発メモ

- モデル間の関連: User ⇔ Profile/HealthLog/CustomField、HealthLog ⇔ ActivityLog。
- サマリー集計は `SummaryCalculator` サービスで実装し、数値型カスタム項目も集計対象に含めています。
- HTML 画面は `app/views` 配下のダッシュボード・プロフィール・健康ログ・サマリーで構成されています。
