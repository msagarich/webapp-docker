# デフォルトのプロジェクト名（指定がない場合）
include .env
export

PROJECT ?= ${PROJECT_NAME}

# 現在のプロジェクト名を取得（.env に書かれている PROJECT_NAME）
CURRENT_PROJECT := $(shell grep "^PROJECT_NAME=" .env 2>/dev/null | cut -d '=' -f2)

# 切り替え対象の .env ファイル
ENV_FILE := env/$(PROJECT).env

create-project: ## Laravel新規プロジェクトを作成して初期化（PROJECT=pj_x）
	@if [ -z "$(NEWPROJECT)" ]; then \
		echo "❌ NEWPROJECT変数が指定されていません。make create-project NEWPROJECT=pj_x のように使ってください。"; \
		exit 1; \
	fi
	@echo "🛑 Stopping running containers..."
	docker-compose down

	@echo "🔄 Switching current project to $(NEWPROJECT)..."
	@if [ -f env/$(NEWPROJECT).env ]; then \
		cp env/$(NEWPROJECT).env .env; \
		echo "✅ Switched to env/$(NEWPROJECT).env"; \
	else \
		echo "⚠ env/$(NEWPROJECT).env が見つかりません。テンプレートから作成します。"; \
		mkdir -p projects/$(NEWPROJECT) ; \
		sed "s/{project}/$(NEWPROJECT)/g" env/env-template > env/$(NEWPROJECT).env; \
		cp env/$(NEWPROJECT).env .env; \
	fi

	@echo "🚀 Creating Laravel project at projects/$(NEWPROJECT)"
	docker-compose up -d --build
	docker compose exec workspace bash -c "\
		composer create-project laravel/laravel . "

	@echo "🔧 Copying .env and generating APP_KEY..."
	docker compose exec workspace bash -c "\
		cp -n .env.example .env && php artisan key:generate"

	make refresh

	@echo "🔐 Fixing permissions..."
	docker exec laravel_app bash -c "\
		chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
		chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache"

	@echo "✅ Laravel project '$(NEWPROJECT)' setup complete and now active."

refresh: ## DBデータを再作成する
	make down-all

	@echo "Recreate Container"
	docker-compose up -d --build

	@echo "Running migration..."
	docker compose exec workspace bash -c "php artisan migrate"

	@echo "Fixing permissions..."
	docker exec laravel_app bash -c "\
		chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
		chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache"

switch: ## 別プロジェクトに切り替える（PROJECT=[project名]）
	@echo "Switching project to: $(PROJECT)"
	@if [ -f $(ENV_FILE) ]; then \
		cp $(ENV_FILE) .env; \
		echo "Switched to project: $(PROJECT)"; \
	else \
		echo "Error: $(ENV_FILE) not found!"; \
		exit 1; \
	fi

current: ## 現在のプロジェクトを表示
	@if [ -f .env ]; then \
		echo "Current project: $(CURRENT_PROJECT)"; \
	else \
		echo "No active .env file found."; \
	fi

list: ## 切り替え可能なプロジェクト一覧を表示
	@echo "Available projects:"
	@for f in env/*.env; do \
		name=$$(basename $$f .env); \
		if [ "$$name" = "$(CURRENT_PROJECT)" ]; then \
			echo "  - $$name (current)"; \
		else \
			echo "  - $$name"; \
		fi \
	done

up: ## docker-compose で起動
	docker-compose up -d

down: ## docker-compose を停止
	docker-compose down

down-all: ## すべてのコンテナ・ボリューム・ネットワークを削除（破壊的）
	@echo "🔥 WARNING: Removing all containers, volumes, and networks defined in docker-compose..."
	docker-compose down -v --remove-orphans

restart: ## プロジェクト切り替え＋再起動（PROJECT=[project名]）
	make down
	make switch PROJECT=$(PROJECT)
	make up
	make current

logs: ## ログ表示
	docker-compose logs -f

dbinfo: ## 現在設定されているDB情報を表示
	@echo "Database Engine: ${DB_ENGINE}"
	@echo "DB Image:        ${DB_IMAGE}"
	@echo "Container Name:  ${DB_CONTAINER_NAME}"
	@echo "Port:              ${DB_PORT}"
	@echo "Volume Name:       ${DB_VOLUME_NAME}"
	@echo "Volume Mount Path: ${DB_VOLUME_PATH}"

# Make targets with description for help
.PHONY: help

help: ## このヘルプを表示
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [PROJECT=pj_x]"
	@echo ""
	@echo "Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*## / {printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)