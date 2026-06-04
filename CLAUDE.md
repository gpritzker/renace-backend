# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Renace Backend is a Rails 7.1 API + admin backoffice. It uses:
- **Devise + devise-jwt** for authentication (JWT for the API, session-based for the admin)
- **PostgreSQL** as the database
- **Active Storage + S3** for file attachments
- **Sidekiq + Redis** for background jobs
- **IPFS (web3.storage) + Ethereum blockchain** for immutable memory registration
- **Active Model Serializers** for JSON responses
- **Tailwind CSS + Bootstrap** for the admin UI

## Commands

```bash
# Start all processes (web, Sidekiq, Redis)
foreman start -f Procfile.dev

# Or individually
bin/rails server
bundle exec sidekiq -C config/sidekiq.yml
redis-server

# Database
bin/rails db:create db:migrate db:seed

# Tests
bin/rails test                          # all tests
bin/rails test test/models/user_test.rb # single file
```

Required environment variables (use `.env` with dotenv-rails):
```
DEVISE_JWT_SECRET_KEY
S3_ACCESS_KEY_ID / S3_SECRET_ACCESS_KEY / S3_REGION / S3_BUCKET
BLOCKCHAIN_PROVIDER_URL / BLOCKCHAIN_PRIVATE_KEY / BLOCKCHAIN_CONTRACT_ADDRESS
WEB3_STORAGE_TOKEN
APP_HOST
```

## Architecture

### Dual authentication system
There are **two separate auth flows** that must not be conflated:

1. **API (JWT)** — `POST /login`, `POST /signup`, `DELETE /logout` handled by `Api::V1::SessionsController` and `Api::V1::RegistrationsController`. Token revocation uses `JwtDenylist` (JTI matcher). API controllers inherit from `ActionController::API`.

2. **Admin backoffice (session)** — `POST /admin/login` handled by `Admin::SessionsController`. It stores `user.id` in `session[:admin_user_id]` and checks `user.admin?`. All admin controllers inherit from `Admin::BaseController < ApplicationController`, which enforces `authenticate_admin_user!` via `before_action`.

### Domain model
- `User` → `has_many :capsules`
- `Capsule` → `has_many :memories`, `belongs_to :user`. Has `approved` boolean (toggled via `approve!`/`disapprove!` and admin endpoints `PATCH /admin/capsules/:id/approve|disapprove`).
- `Memory` → `belongs_to :capsule`, `has_one_attached :file`. Has `memory_type` enum (`text`, `image`, `video`, `audio`). Text memories require `content`; media memories rely on the attached file.

### File storage & media URLs
Active Storage is configured with the Amazon S3 service (`config/storage.yml`). `MemorySerializer` exposes two URL helpers:
- `rails_url` — Rails blob URL (internal)
- `s3_url` — direct signed S3 URL (10-minute expiry), generated via `blob.service.url(...)`.

### Background pipeline: IPFS + Blockchain
`RegisterRememberWorker` (Sidekiq) orchestrates the two-step immutable registration:
1. Uploads the file to IPFS via `IpfsUploader` (web3.storage API)
2. Registers the resulting CID on an Ethereum smart contract via `BlockchainService` (calls `storeCID(string)`)

### Serializers
All JSON output goes through Active Model Serializers. `ApplicationSerializer` provides a `default_host` helper used by serializers that build URLs.

### Admin backoffice
The admin is a standard Rails HTML app (not API-only) mounted under `/admin`. It uses the `admin` layout with Tailwind + Bootstrap. The `Admin::BaseController` gate means every admin controller action requires an active admin session.
