.PHONY: up down seed test scan

up:
	docker compose up --build

down:
	docker compose down

seed:
	docker compose exec app bundle exec rails db:seed

test:
	docker compose --profile test run --rm test

scan:
	docker compose run --rm --no-deps app bundle exec brakeman -q
