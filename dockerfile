name: Trivy Security Scan

on:
  push:
    branches:
      - main

  pull_request:

  workflow_dispatch:

permissions:
  contents: read
  security-events: write

jobs:
  trivy-scan:
    runs-on: ubuntu-latest

    steps:

      # Checkout code
      - name: Checkout Repository
        uses: actions/checkout@v4

      # Build Docker image
      - name: Build Docker Image
        run: |
          docker build -t vulnerable-image .

      # Install Trivy
      - name: Install Trivy
        run: |
          sudo apt-get update
          sudo apt-get install -y wget apt-transport-https gnupg lsb-release

          wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
          gpg --dearmor | \
          sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

          echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
          sudo tee /etc/apt/sources.list.d/trivy.list

          sudo apt-get update
          sudo apt-get install -y trivy

      # Show Vulnerabilities in GitHub Actions logs
      - name: Trivy Vulnerability Scan
        run: |
          trivy image --severity CRITICAL,HIGH,MEDIUM vulnerable-image

      # Show Secrets in logs
      - name: Trivy Secret Scan
        run: |
          trivy image --scanners secret vulnerable-image

      # Show Misconfigurations in logs
      - name: Trivy Misconfiguration Scan
        run: |
          trivy config .

      # Create SARIF report for GitHub Security tab
      - name: Generate SARIF Report
        run: |
          trivy image \
            --format sarif \
            --output trivy-results.sarif \
            vulnerable-image

      # Upload SARIF to GitHub Security
      - name: Upload SARIF Report
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif
