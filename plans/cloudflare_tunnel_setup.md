# Cloudflare Tunnel 公開手順計画（A方式）

## 目的
Windows 上で稼働させたローカル Rails アプリを Cloudflare Tunnel（Quick Tunnel / Named Tunnel）経由でスマートフォンから利用できるようにする。

## 対応範囲
- リポジトリ内の Rails 設定変更（ホスト許可 / HTTPS / Cookie / CSP / Action Cable）。
- Windows ローカル環境での Docker・cloudflared セットアップ手順整理。
- 不明点: 本番公開用独自ドメイン（`yourapp.example.com` の実値）と CDN ドメイン（`your-cdn.example.com`）は未確定のため、確定後に置き換えること。

## 実施内容
1. Rails 設定
   - `config/environments/development.rb`
     - `config.hosts` に `*.trycloudflare.com` を許可。
     - Web Console へ外部アクセスを許可。
     - Action Cable の許可オリジンに Quick Tunnel ドメインを追加。
   - `config/environments/production.rb`
     - `config.force_ssl = true` を有効化。
     - `config.hosts` に独自ドメインを追加（要実ドメイン更新）。
     - Action Cable の許可オリジンに Quick Tunnel・独自ドメインを設定。
   - `config/initializers/session_store.rb`
     - Cookie を `secure: true` / `same_site: :lax` で設定。
   - `config/initializers/content_security_policy.rb`
     - Cloudflare 経由で利用する CDN を許可。
     - フォント / スタイル / スクリプト / 画像ソースを明示。
2. Windows ローカル手順
   - `compose.yml` で Rails を `0.0.0.0:3000` で起動。
   - Docker でアプリ起動確認後、`cloudflared` をインストール。
   - Quick Tunnel で一時公開 (`cloudflared tunnel --url http://localhost:3000`)。
   - Named Tunnel で独自ドメイン運用する場合の手順（`cloudflared tunnel create`, `config.yaml`, DNS route, `cloudflared tunnel run`）。
3. 運用ポイント
   - Windows のスリープ抑止。
   - `cloudflared` の自動起動（タスクスケジューラ等）。
   - ファイアウォールの許可設定。

## チェックリスト
- [ ] `http://localhost:3000` が Docker 経由で開ける。
- [ ] `cloudflared tunnel --url http://localhost:3000` で Quick Tunnel URL が取得できる。
- [ ] スマートフォンで Quick Tunnel URL にアクセスできる。
- [ ] Named Tunnel + 独自ドメインで常時公開できる。
- [ ] 独自ドメインと CDN ドメインが確定し、設定に反映されている。
