# -----------------------------
# Configs
# -----------------------------
CLUSTER_NAME := wikipedia-api-cluster
CHART_DIR := ./wiki-chart
APP_DIR := wiki-service
NAMESPACE := wikipedia-api
IMAGE_NAME := wikipedia-api:latest

# -----------------------------
# Targets
# -----------------------------

.PHONY: all cluster build import helm deploy clean

# Default
all: cluster build import helm deploy

# -----------------------------
# cluster k3d
# -----------------------------
cluster:
	k3d cluster create wikipedia-api-cluster \
	--servers 1 \
	--agents 1 \
	--kubeconfig-update-default \
	--kubeconfig-switch-context \
	-p "80:80@loadbalancer"


# -----------------------------
# Build docker image
# -----------------------------
build:
	docker build -t $(IMAGE_NAME) $(APP_DIR)

# -----------------------------
# Import image to cluster
# -----------------------------
import:
	k3d image import $(IMAGE_NAME) -c $(CLUSTER_NAME)

# -----------------------------
# Update helm dependency
# -----------------------------
helm:
	helm dependency update $(CHART_DIR)

# -----------------------------
# Deploy Helm chart full
# -----------------------------
deploy:
	helm upgrade --install wiki $(CHART_DIR) -n $(NAMESPACE) --create-namespace -f $(CHART_DIR)/values.yaml

# -----------------------------
# cleanup
# -----------------------------
clean:
	k3d cluster delete $(CLUSTER_NAME) || echo "No cluster to delete"
	docker rmi $(IMAGE_NAME) || echo "No image to remove"
