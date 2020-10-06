.ONESHELL:
.SHELL := /usr/bin/bash
.PHONY: init plan apply fapply destroy
PROJECT=""
REGION="us-east-1"
AWS_PROFILE="default"

CURRENT_FOLDER=$(shell basename "$$(pwd)")
WORKSPACE="${PROJECT}-${CURRENT_FOLDER}"
TFSTATE_S3_BUCKET="${PROJECT}-terraform-state"
TFSTATE_DYNAMODB_TABLE = "${PROJECT}-terraform-state-lock"
TFSTATE_KEY = "terraform.tfstate"

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

init: # Init terraform project
	@terraform init \
		-force-copy \
		-input=false \
		-lock=true \
		-upgrade \
		-verify-plugins=true \
		-backend=true \
		-backend-config="profile=$(AWS_PROFILE)" \
		-backend-config="region=$(REGION)" \
		-backend-config="bucket=$(TFSTATE_S3_BUCKET)" \
		-backend-config="key=terraform.tfstate" \
		-backend-config="dynamodb_table=$(TFSTATE_DYNAMODB_TABLE)"\
		-backend-config="acl=private"
	@echo "$(BOLD)Switching to workspace $(WORKSPACE)$(RESET)"
	@terraform workspace select $(WORKSPACE) || terraform workspace new $(WORKSPACE)

plan: init #Show what terraform thinks it will do
	@terraform plan \
		-input=false \
		-lock=true \
		-refresh=true \
		-var "profile=$(AWS_PROFILE)" \
		-var "region=$(REGION)" \
		-var-file="variables.tfvars"

apply: init # Create stuff
	@terraform apply \
		-input=false \
		-lock=true \
		-refresh=true \
		-var "profile=$(AWS_PROFILE)" \
		-var "region=$(REGION)" \
		-var-file="variables.tfvars"

fapply: # Have terraform do the things quickly (skips init).
	@terraform apply \
		-input=false \
		-lock=true \
		-refresh=true \
		-var "profile=$(AWS_PROFILE)" \
		-var "region=$(REGION)" \
		-var-file="variables.tfvars"

destroy: init # Destroy stuff
	@terraform destroy \
		-input=false \
		-lock=true \
		-refresh=true \
		-var "profile=$(AWS_PROFILE)" \
		-var "region=$(REGION)" \
		-var-file="variables.tfvars"
