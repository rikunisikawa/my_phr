# T3. カスタム項目管理 API

- **目的**: カスタム項目を CRUD 管理する API を実装する。
- **前提**: T2 完了。
- **作業内容**:
  - `CustomField` モデル（`name`, `field_type`, `category`, `options`）の作成。
  - 対象カテゴリ: profile / health / activity。
  - RESTful コントローラとルーティングを追加。
  - Strong Parameters、バリデーション（名称必須、フィールド型の制約）を実装。
  - リクエストスペックを追加。
- **完了条件**: CRUD API が動作しテストが成功。
- **参考**: 要件定義 5.4、7.2、9。
