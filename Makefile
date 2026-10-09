.PHONY: up down seed test scan k8s infra

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

k8s:
	bash k8s/apply.sh

infra:
	terraform -chdir=infra init
	terraform -chdir=infra apply
