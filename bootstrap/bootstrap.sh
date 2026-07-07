#!/usr/bin/env bash
set -euo pipefail

project="${1:?usage: bootstrap.sh <project-id> [region]}"
region="${2:-asia-northeast1}"
bucket="${project}-tfstate"

gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project="$project"

if ! gcloud storage buckets describe "gs://${bucket}" >/dev/null 2>&1; then
  gcloud storage buckets create "gs://${bucket}" \
    --project="$project" \
    --location="$region" \
    --uniform-bucket-level-access \
    --public-access-prevention
fi

gcloud storage buckets update "gs://${bucket}" --versioning
