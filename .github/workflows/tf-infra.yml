name: Terraform Infrastructure

# Este es el flujo de promoción de la infraestructura:
#   - Los cambios en develop se despliegan automáticamente a dev.
#   - Para llegar a laboratory (lab), es necesaria una aprobación en GitHub Environments.
#   - Los despliegues a main (producción) también requieren aprobación antes de ejecutarse.

on:
  push:
    branches: [develop, laboratory, main]
    paths: ["infraestructura/**"]
  pull_request:
    branches: [develop, laboratory, main]
    paths: ["infraestructura/**"]
  workflow_dispatch:
    inputs:
      environment:
        description: "Ambiente destino (sobreescribe la rama)"
        required: true
        type: choice
        options: [dev, lab, prod]
      action:
        description: "Acción a ejecutar"
        required: true
        default: plan
        type: choice
        options: [plan, apply]

permissions:
  id-token: write
  contents: read
  pull-requests: write
  security-events: write

env:
  AWS_REGION: us-east-1
  TF_VERSION: "1.8.0"

jobs:
  # ── 0. Resolver ambiente desde rama o dispatch ───────────────────────────────
  resolve:
    name: "Resolver ambiente"
    runs-on: ubuntu-latest
    outputs:
      env_name: ${{ steps.map.outputs.env_name }}
      tf_dir:   ${{ steps.map.outputs.tf_dir }}
    steps:
      - name: Mapear rama → ambiente
        id: map
        run: |
          if [ -n "${{ github.event.inputs.environment }}" ]; then
            ENV="${{ github.event.inputs.environment }}"
          else
            case "${{ github.ref_name }}" in
              develop)    ENV=dev  ;;
              laboratory) ENV=lab  ;;
              main)       ENV=prod ;;
              *)
                echo "Rama '${{ github.ref_name }}' no mapeada a ningún ambiente"
                exit 1
                ;;
            esac
          fi
          echo "env_name=${ENV}"          >> "$GITHUB_OUTPUT"
          echo "tf_dir=infraestructura/environments/${ENV}" >> "$GITHUB_OUTPUT"
          echo "### Ambiente resuelto: \`${ENV}\`" >> "$GITHUB_STEP_SUMMARY"

  # ── 1. Seguridad IaC (Checkov) ───────────────────────────────────────────────
  security-scan:
    name: "Checkov — IaC Security Scan"
    runs-on: ubuntu-latest
    needs: resolve
    steps:
      - uses: actions/checkout@v4

      - name: Run Checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: ${{ needs.resolve.outputs.tf_dir }}
          framework: terraform
          output_format: cli,sarif
          output_file_path: console,checkov-results.sarif
          soft_fail: false
          skip_check: CKV_AWS_260,CKV2_AWS_28


  # ── 2. Terraform Plan ────────────────────────────────────────────────────────
  terraform-plan:
    name: "Plan [${{ needs.resolve.outputs.env_name }}]"
    runs-on: ubuntu-latest
    needs: [resolve, security-scan]
    environment: ${{ needs.resolve.outputs.env_name }}

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_OIDC_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Terraform Init
        run: |
          ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
          terraform init -input=false \
            -backend-config="bucket=microservicio-echo-tfstate-${ACCOUNT_ID}" \
            -backend-config="dynamodb_table=microservicio-echo-tf-locks"
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Terraform Validate
        run: terraform validate
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Terraform Plan
        id: plan
        run: |
          terraform plan \
            -input=false \
            -out=tfplan \
            -var="container_image=${{ secrets.CONTAINER_IMAGE || 'public.ecr.aws/nginx/nginx:alpine' }}"
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Upload plan artifact
        uses: actions/upload-artifact@v4
        with:
          name: tfplan-${{ needs.resolve.outputs.env_name }}-${{ github.run_id }}
          path: ${{ needs.resolve.outputs.tf_dir }}/tfplan
          retention-days: 1

      - name: Comentar plan en el PR
        uses: actions/github-script@v7
        if: github.event_name == 'pull_request'
        env:
          PLAN_OUTPUT: ${{ steps.plan.outputs.stdout }}
        with:
          script: |
            const env = "${{ needs.resolve.outputs.env_name }}";
            const body = `#### Terraform Plan \`${{ steps.plan.outcome }}\` → \`${env}\`
            <details><summary>Ver plan completo</summary>

            \`\`\`terraform
            ${process.env.PLAN_OUTPUT}
            \`\`\`
            </details>`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body
            });

  # ── 3. Terraform Apply ───────────────────────────────────────────────────────
  terraform-apply:
    name: "Apply [${{ needs.resolve.outputs.env_name }}]"
    runs-on: ubuntu-latest
    needs: [resolve, terraform-plan]
    environment: ${{ needs.resolve.outputs.env_name }}
    # Aplica solo en push directo a las ramas protegidas (no en PRs)
    if: |
      github.event_name == 'push' ||
      (github.event_name == 'workflow_dispatch' && github.event.inputs.action == 'apply')

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_OIDC_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        run: |
          ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
          terraform init -input=false \
            -backend-config="bucket=microservicio-echo-tfstate-${ACCOUNT_ID}" \
            -backend-config="dynamodb_table=microservicio-echo-tf-locks"
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Download plan artifact
        uses: actions/download-artifact@v4
        with:
          name: tfplan-${{ needs.resolve.outputs.env_name }}-${{ github.run_id }}
          path: ${{ needs.resolve.outputs.tf_dir }}

      - name: Terraform Apply
        run: terraform apply -input=false -auto-approve tfplan
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Exportar outputs
        id: tf-out
        run: |
          echo "alb_url=$(terraform output -raw alb_url)"            >> "$GITHUB_OUTPUT"
          echo "ecr_url=$(terraform output -raw ecr_repository_url)" >> "$GITHUB_OUTPUT"
          echo "cluster=$(terraform output -raw ecs_cluster_name)"   >> "$GITHUB_OUTPUT"
          echo "service=$(terraform output -raw ecs_service_name)"   >> "$GITHUB_OUTPUT"
        working-directory: ${{ needs.resolve.outputs.tf_dir }}

      - name: Resumen
        run: |
          ENV="${{ needs.resolve.outputs.env_name }}"
          echo "## Terraform Apply — \`${ENV}\` completado" >> "$GITHUB_STEP_SUMMARY"
          echo "| Output | Valor |" >> "$GITHUB_STEP_SUMMARY"
          echo "|--------|-------|" >> "$GITHUB_STEP_SUMMARY"
          echo "| ALB URL    | ${{ steps.tf-out.outputs.alb_url }} |" >> "$GITHUB_STEP_SUMMARY"
          echo "| ECR URL    | ${{ steps.tf-out.outputs.ecr_url }} |" >> "$GITHUB_STEP_SUMMARY"
          echo "| Cluster    | ${{ steps.tf-out.outputs.cluster }} |" >> "$GITHUB_STEP_SUMMARY"
          echo "| Servicio   | ${{ steps.tf-out.outputs.service }} |" >> "$GITHUB_STEP_SUMMARY"
