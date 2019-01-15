CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_EXAMPLES = $(sort $(dir $(wildcard $(CURRENT_DIR)examples/*/)))

.PHONY: test

help:
	@echo "lint       Static source code analysis"
	@echo "test       Integration tests"


lint:
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@if docker run -it --rm -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:light \
		fmt -check=true -diff=true -write=false -list=true .; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo


test:
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="/t/examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "################################################################################"; \
		echo "# Terraform init:  $${DOCKER_PATH}"; \
		echo "################################################################################"; \
		if docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:light \
			init \
				-verify-plugins=true \
				-lock=false \
				-upgrade=true \
				-reconfigure \
				-input=false \
				-get-plugins=true \
				-get=true \
				.; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:light -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
	)
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="/t/examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "################################################################################"; \
		echo "# Terraform validate:  $${DOCKER_PATH}"; \
		echo "################################################################################"; \
		if docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:light \
			validate \
				-check-variables=true $(ARGS) \
				.; then \
			echo "OK"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:light -rf .terraform/ || true; \
		else \
			echo "Failed"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:light -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
	)
