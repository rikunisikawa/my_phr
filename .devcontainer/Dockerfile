# Docker Hubからruby:3.0.6のイメージをプルする
FROM ruby:3.0.6

# debian系のためapt-getを使用してnode.jsとyarnをインストール
RUN apt-get update -qq && apt-get install -y \
    curl \
    build-essential \
    libpq-dev \
    mariadb-client && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install --global yarn && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# docker内の作業ディレクトリを作成＆設定
WORKDIR /my_phr

# Gemfile,Gemfile.lockをローカルからCOPY
COPY Gemfile Gemfile.lock /my_phr/

# コンテナ内にコピーしたGemfileを用いてbundle install
RUN gem install rubocop solargraph && \
    bundle install --jobs=4 --retry=3

# Font Awesome をインストール
RUN yarn add @fortawesome/fontawesome-free
RUN yarn add chartkick chart.js

# アプリケーションの全ファイルをコンテナにコピー
COPY . /my_phr/

# entrypoint.sh をコンテナ内にコピー
COPY entrypoint.sh /usr/bin/entrypoint.sh

# 実行権限を付与
RUN chmod +x /usr/bin/entrypoint.sh

# ENTRYPOINT を修正
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# 起動時に古いPIDファイルを削除 / デフォルトでrailsサーバーを起動
CMD ["rails", "server", "-b", "0.0.0.0"]
