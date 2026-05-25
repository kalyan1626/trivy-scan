name: Advanced Trivy Scan

on:
  push:
    branches:
      - main

  workflow_dispatch:

jobs:
  trivy-scan:
    runs-on: ubuntu-latest

    steps:

      - name: Checkout Code
        uses: actions/checkout@v4

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

      # Vulnerability scan
      - name: CVE Scan
        run: |
          trivy image --severity CRITICAL,HIGH vulnerable-image

      # Secret scan
      - name: Secret Scan
        run: |
          trivy image --scanners secret vulnerable-image

      # Misconfiguration scan
      - name: Misconfiguration Scan
        run: |
          trivy config .

      # Full scan
      - name: Full Scan
        run: |
          trivy image --scanners vuln,secret,misconfig vulnerable-image

      # Generate JSON report
      - name: Generate Report
        run: |
          trivy image -f json -o trivy-report.json vulnerable-image

      # Upload report
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: trivy-report
          path: trivy-report.json
