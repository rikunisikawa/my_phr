# T4. 健康ログ記録機能

- **目的**: 日次の健康状態と運動内容を保存する機能を実装する。
- **前提**: T2, T3 完了。
- **作業内容**:
  - `HealthLog` モデルとマイグレーションを作成し、`mood`, `stress_level`, `fatigue_level`, `notes`, `logged_on`, `custom_fields`(JSON) を定義。
  - `ActivityLog` モデルを作成し、`activity_type`, `duration`, `intensity`, `custom_fields`(JSON) を定義。
  - モデル間の関連 (`HealthLog has_many ActivityLogs`) を設定。
  - API コントローラで作成・更新・取得・削除を実装。
  - 時系列取得のため `GET /health_logs?from=&to=` を実装。
  - モデル/リクエストテストを追加。
- **完了条件**: API 経由で健康ログを登録・更新・参照できテスト成功。
- **参考**: 要件定義 5.2、7.1、9。
