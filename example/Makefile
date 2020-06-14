TASK=test-definition.json
YAML=docker-compose.ecs-local.yml
STAGE=dev

default: ## ヘルプを表示する
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

yaml: ## create docker-compose.yml
	ecs-cli local create --task-def-file=${TASK} ${YAML}

service: ## create service 
	ecs-cli local up --task-def-compose=${YAML}

down: ## remove service
	ecs-cli local down --task-def-file=${TASK} --all

list: ## list services
	@ecs-cli local ps --task-def-file=${TASK}

kobanzame: ## build kobanzame container
	@cd _kobanzame && ./build.sh ${STAGE} batch

worker: ## build worker container
	@cd _worker && ./build.sh ${STAGE} batch

task: ## execute run-task.sh
	@./run-task.sh ${STAGE}

disable_insights: ## Disable container insights
	@aws ecs update-cluster-settings --cluster kobanzame-sample-${STAGE}-batch-worker --settings name=containerInsights,value=disabled

enable_insights: ## Enable container insights
	@aws ecs update-cluster-settings --cluster kobanzame-sample-${STAGE}-batch-worker --settings name=containerInsights,value=enabled
