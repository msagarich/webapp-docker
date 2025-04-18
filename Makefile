# デフォルトのプロジェクト名（指定がない場合）
include .env
export

PROJECT ?= pj_a

# 現在のプロジェクト名を取得（.env に書かれている PROJECT_NAME）
CURRENT_PROJECT := $(shell grep "^PROJECT_NAME=" .env 2>/dev/null | cut -d '=' -f2)

# 切り替え対象の .env ファイル
ENV_FILE := env/$(PROJECT).env

switch: ## 別プロジェクトに切り替える（PROJECT=pj_x）
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
	docker-compose up -d --build

down: ## docker-compose を停止
	docker-compose down

restart: ## プロジェクト切り替え＋再起動（PROJECT=pj_x）
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

help:
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'