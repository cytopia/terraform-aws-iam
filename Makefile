ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: help gen lint test _gen-main _gen-examples _gen-modules _lint-files _lint-fmt _lint-json _pull-tf _pull-tfdocs _pull-fl _pull-jl

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_EXAMPLES = $(sort $(dir $(wildcard $(CURRENT_DIR)examples/*/)))
TF_MODULES  = $(sort $(dir $(wildcard $(CURRENT_DIR)modules/*/)))

# -------------------------------------------------------------------------------------------------
# Container versions
# -------------------------------------------------------------------------------------------------
TF_VERSION      = 1.3.9
TFDOCS_VERSION  = 0.16.0-0.34
FL_VERSION      = latest-0.8
JL_VERSION      = 1.6.0-0.14


# -------------------------------------------------------------------------------------------------
# Enable linter (file-lint, terraform fmt, jsonlint)
# -------------------------------------------------------------------------------------------------
LINT_FL_ENABLE = 1
LINT_TF_ENABLE = 1
LINT_JL_ENABLE = 1


# -------------------------------------------------------------------------------------------------
# terraform-docs defines
# -------------------------------------------------------------------------------------------------
# Adjust your delimiter here or overwrite via make arguments
DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# What arguments to append to terraform-docs command
TFDOCS_ARGS = --sort=false


# -------------------------------------------------------------------------------------------------
# Default target
# -------------------------------------------------------------------------------------------------
help:
	@echo "gen        Generate terraform-docs output and replace in README.md's"
	@echo "lint       Static source code analysis"
	@echo "test       Integration tests"


# -------------------------------------------------------------------------------------------------
# Standard targets
# -------------------------------------------------------------------------------------------------
gen: _pull-tfdocs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@$(MAKE) --no-print-directory _gen-main
	@$(MAKE) --no-print-directory _gen-examples
	@$(MAKE) --no-print-directory _gen-modules

lint:
	@if [ "$(LINT_FL_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-files; \
	fi
	@if [ "$(LINT_TF_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-fmt; \
	fi
	@if [ "$(LINT_JL_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-json; \
	fi

test: _pull-tf
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="/t/examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "################################################################################"; \
		echo "# examples/$$( basename $${DOCKER_PATH} )"; \
		echo "################################################################################"; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform init"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm --network host -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			init \
				-lock=false \
				-upgrade \
				-reconfigure \
				-input=false \
				-get=true; \
		then \
			echo "OK"; \
		else \
			echo "Failed"; \
			docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform validate"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			validate \
				$(ARGS) \
				.; then \
			echo "OK"; \
			docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
		else \
			echo "Failed"; \
			docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
	)


# -------------------------------------------------------------------------------------------------
# Helper Targets
# -------------------------------------------------------------------------------------------------
_gen-main:
	@echo "------------------------------------------------------------"
	@echo "# Main module"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='<!-- TFDOCS_HEADER_START -->' \
		-e DELIM_CLOSE='<!-- TFDOCS_HEADER_END -->' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace --show header markdown tbl --indent 2 --sort README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='<!-- TFDOCS_PROVIDER_START -->' \
		-e DELIM_CLOSE='<!-- TFDOCS_PROVIDER_END -->' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace --show providers markdown tbl --indent 2 --sort README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='<!-- TFDOCS_REQUIREMENTS_START -->' \
		-e DELIM_CLOSE='<!-- TFDOCS_REQUIREMENTS_END -->' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace --show requirements markdown tbl --indent 2 --sort README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='<!-- TFDOCS_INPUTS_START -->' \
		-e DELIM_CLOSE='<!-- TFDOCS_INPUTS_END -->' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace --show inputs markdown doc --indent 2 $(TFDOCS_ARGS) README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi
	@if docker run $$(tty -s && echo "-it" || echo) --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='<!-- TFDOCS_OUTPUTS_START -->' \
		-e DELIM_CLOSE='<!-- TFDOCS_OUTPUTS_END -->' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace --show outputs markdown tbl --indent 2 --sort README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi

_gen-examples:
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TFDOCS_VERSION) \
			terraform-docs-replace $(TFDOCS_ARGS) markdown $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_gen-modules:
	@$(foreach module,\
		$(TF_MODULES),\
		DOCKER_PATH="modules/$(notdir $(patsubst %/,%,$(module)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run $$(tty -s && echo "-it" || echo) --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TFDOCS_VERSION) \
			terraform-docs-replace $(TFDOCS_ARGS) markdown $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_lint-files: _pull-fl
	@# Basic file linting
	@echo "################################################################################"
	@echo "# File-lint"
	@echo "################################################################################"
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run $$(tty -s && echo "-it" || echo) --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '.git/,.github/,.terraform/' --path .

_lint-fmt: _pull-tf
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tf files"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		fmt -recursive -check=true -diff=true -write=false -list=true .; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tfvars files"
	@echo "------------------------------------------------------------"
	@if docker run $$(tty -s && echo "-it" || echo) --rm --entrypoint=/bin/sh -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		-c "find . -name '*.tfvars' -type f -print0 | xargs -0 -n1 terraform fmt -check=true -write=false -diff=true -list=true"; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

_lint-json: _pull-jl
	@# Lint all JSON files
	@echo "################################################################################"
	@echo "# Jsonlint"
	@echo "################################################################################"
	@if docker run $$(tty -s && echo "-it" || echo) --rm -v "$(CURRENT_DIR):/data:ro" cytopia/jsonlint:$(JL_VERSION) \
		-t '  ' -i '*.terraform/*' '*.json'; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

_pull-tf:
	docker pull hashicorp/terraform:$(TF_VERSION)

_pull-tfdocs:
	docker pull cytopia/terraform-docs:$(TFDOCS_VERSION)

_pull-fl:
	docker pull cytopia/file-lint:$(FL_VERSION)
