#!/usr/bin/env python3
"""Gera o documento de entrega da fase 2 no formato do PDF da fase 1."""

import zlib
from pathlib import Path

VIDEO_URL = "A publicar. Roteiro em ROTEIRO-VIDEO-FASE2.md"
OUT = Path(__file__).resolve().parents[1] / "Grupo110-Fase2-Derek-TechChallenge.pdf"

PAGE_W = 595.28
PAGE_H = 841.89
MARGIN = 48
BOTTOM = 46
CONTENT_W = PAGE_W - 2 * MARGIN


def enc(text):
    return text.encode("cp1252", errors="replace")


def pdf_escape(text):
    raw = enc(text)
    return raw.replace(b"\\", b"\\\\").replace(b"(", b"\\(").replace(b")", b"\\)")


class Doc:
    def __init__(self):
        self.pages = []
        self.ops = []
        self.y = 50

    def new_page(self):
        if self.ops:
            self.pages.append(self.ops)
        self.ops = []
        self.y = 50

    def ensure(self, height):
        if self.y + height > PAGE_H - BOTTOM:
            self.new_page()

    def cmd(self, line):
        self.ops.append(line)

    def text(self, x, y, text, font="F1", size=11, color=(0, 0, 0)):
        r, g, b = color
        escaped = pdf_escape(text).decode("cp1252")
        self.cmd(f"{r:.3f} {g:.3f} {b:.3f} rg")
        self.cmd(f"BT /{font} {size:.2f} Tf {x:.2f} {PAGE_H - y:.2f} Td ({escaped}) Tj ET")

    def fill_rect(self, x, y, w, h, color):
        r, g, b = color
        self.cmd(f"{r:.3f} {g:.3f} {b:.3f} rg")
        self.cmd(f"{x:.2f} {PAGE_H - y - h:.2f} {w:.2f} {h:.2f} re f")

    def stroke_rect(self, x, y, w, h, color=(0.75, 0.75, 0.75), width=0.6):
        r, g, b = color
        self.cmd(f"{width:.2f} w {r:.3f} {g:.3f} {b:.3f} RG")
        self.cmd(f"{x:.2f} {PAGE_H - y - h:.2f} {w:.2f} {h:.2f} re S")

    def line(self, x1, y1, x2, y2, color=(0.12, 0.31, 0.47), width=1):
        r, g, b = color
        self.cmd(f"{width:.2f} w {r:.3f} {g:.3f} {b:.3f} RG")
        self.cmd(f"{x1:.2f} {PAGE_H - y1:.2f} m {x2:.2f} {PAGE_H - y2:.2f} l S")

    def wrap(self, text, width, size, bold=False):
        factor = 0.52 if bold else 0.47
        max_chars = max(8, int(width / (size * factor)))
        words = []
        for word in text.split():
            if len(word) <= max_chars:
                words.append(word)
                continue
            words.extend(word[i : i + max_chars] for i in range(0, len(word), max_chars))
        if not words:
            return [""]
        lines = []
        current = words[0]
        for word in words[1:]:
            trial = current + " " + word
            if len(trial) <= max_chars:
                current = trial
            else:
                lines.append(current)
                current = word
        lines.append(current)
        return lines

    def heading(self, text):
        self.ensure(28)
        self.y += 12
        self.text(MARGIN, self.y, text, "F2", 13, (0.12, 0.31, 0.47))
        self.y += 6
        self.line(MARGIN, self.y, MARGIN + CONTENT_W, self.y, width=1.1)
        self.y += 12

    def paragraph(self, text, size=10.5, gap=4):
        lines = self.wrap(text, CONTENT_W, size)
        self.ensure(len(lines) * (size + 3) + gap)
        for line in lines:
            self.text(MARGIN, self.y, line, "F1", size)
            self.y += size + 3
        self.y += gap

    def bullet(self, text, size=10.5):
        lines = self.wrap(text, CONTENT_W - 16, size)
        self.ensure(len(lines) * (size + 3) + 2)
        self.text(MARGIN, self.y, "•", "F1", size, (0.12, 0.31, 0.47))
        for index, line in enumerate(lines):
            self.text(MARGIN + 14, self.y, line, "F1", size)
            self.y += size + 3
        self.y += 1

    def table(self, rows, widths):
        size = 9.5
        prepared = []
        for index, row in enumerate(rows):
            bold = index == 0
            wrapped = [self.wrap(cell, width - 10, size, bold) for cell, width in zip(row, widths)]
            height = max(len(lines) for lines in wrapped) * 12 + 8
            prepared.append((wrapped, height, bold))
        if prepared and self.y + prepared[0][1] + 8 > PAGE_H - BOTTOM:
            self.new_page()
        for wrapped, height, bold in prepared:
            self.ensure(height)
            x = MARGIN
            for lines, width in zip(wrapped, widths):
                if bold:
                    self.fill_rect(x, self.y, width, height, (0.12, 0.31, 0.47))
                    color = (1, 1, 1)
                    font = "F2"
                else:
                    self.fill_rect(x, self.y, width, height, (0.96, 0.97, 0.98))
                    color = (0.1, 0.1, 0.1)
                    font = "F1"
                self.stroke_rect(x, self.y, width, height, (0.78, 0.82, 0.86))
                text_y = self.y + 12
                for line in lines:
                    self.text(x + 5, text_y, line, font, size, color)
                    text_y += 12
                x += width
            self.y += height
        self.y += 8

    def box(self, x, y, w, h, title, body, fill=(0.93, 0.96, 0.98)):
        self.fill_rect(x, y, w, h, fill)
        self.stroke_rect(x, y, w, h, (0.12, 0.31, 0.47), 1)
        self.text(x + 8, y + 14, title, "F2", 9, (0.12, 0.31, 0.47))
        text_y = y + 28
        for line in body:
            self.text(x + 8, text_y, line, "F1", 8.5)
            text_y += 11

    def finish(self):
        if self.ops:
            self.pages.append(self.ops)
        total = len(self.pages)
        for number, ops in enumerate(self.pages, start=1):
            footer = (
                f"0.35 0.35 0.35 rg BT /F1 9 Tf {MARGIN:.2f} 28 Td "
                f"(Grupo 110  |  Tech Challenge - Fase 2  |  Página {number} de {total}) Tj ET"
            )
            ops.append(footer)
        return self.pages


def build():
    doc = Doc()
    doc.text(MARGIN, 42, "Tech Challenge - Fase 2", "F2", 20, (0.12, 0.31, 0.47))
    doc.y = 64
    doc.text(MARGIN, doc.y, "Oficina Mecânica", "F2", 14)
    doc.y += 18
    doc.text(MARGIN, doc.y, "Documento de Entrega", "F1", 12, (0.25, 0.25, 0.25))
    doc.y += 16
    doc.text(MARGIN, doc.y, "Pós Tech - 17SOAT - Software Architecture", "F1", 11)
    doc.y += 14
    doc.text(MARGIN, doc.y, "Data: 08/10/2026", "F1", 11)
    doc.y += 8
    doc.line(MARGIN, doc.y, MARGIN + CONTENT_W, doc.y, width=1.4)
    doc.y += 8

    doc.heading("1. Identificação do grupo")
    doc.table(
        [
            ["Campo", "Informação"],
            ["Nome do grupo", "Grupo 110"],
            ["Disciplina / Fase", "Tech Challenge - Fase 2"],
            ["Participante", "Derek  |  Derek rm375085"],
        ],
        [170, CONTENT_W - 170],
    )

    doc.heading("2. Links de entrega")
    doc.table(
        [
            ["Item", "Link"],
            ["Repositório GitHub (acesso soat-architecture)", "https://github.com/derektsc/Oficina-Tech-Challenge"],
            ["Vídeo demonstrativo (até 15 min)", VIDEO_URL],
            ["Swagger / API Docs (Docker Compose)", "http://localhost:3000/api-docs"],
            ["Swagger no cluster local", "http://localhost:30080/api-docs"],
            ["E-mails de status (Mailpit)", "http://localhost:8025 e http://localhost:30025"],
            ["Roteiro do vídeo", "ROTEIRO-VIDEO-FASE2.md"],
            ["Diagramas DDD da fase 1 (Miro)", "https://miro.com/app/board/uXjVHsDM-SM="],
        ],
        [210, CONTENT_W - 210],
    )

    doc.heading("3. Resumo do projeto")
    doc.paragraph(
        "A fase 2 evolui o back-end da oficina entregue na fase 1. O monolito Ruby on Rails 8 "
        "e o PostgreSQL 16 permanecem. O que entra agora é a operação em escala: fila de ordens "
        "de serviço, notificação externa de orçamento, e-mail a cada mudança de status, "
        "Kubernetes com autoscaling, provisionamento com Terraform e pipeline de CI/CD."
    )
    doc.paragraph(
        "Não há conta na AWS. O cluster é local, criado com kind dentro do Docker. "
        "O docker compose continua sendo o ambiente de desenvolvimento, na porta 3000. "
        "O Kubernetes publica a API na porta 30080."
    )

    doc.heading("4. Entregáveis da Fase 2 - checklist")
    for item in [
        "Código da fase 1 mantido em camadas: domínio, casos de uso, persistência e HTTP.",
        "Abertura da OS com cliente, veículo, serviços e peças, devolvendo o identificador.",
        "Consulta pública do status pelo token da OS.",
        "Endpoint de notificação externa para aprovar ou recusar o orçamento.",
        "Listagem operacional: Em execução, Aguardando aprovação, Em diagnóstico, Recebida; mais antigas primeiro.",
        "Finalizada e entregue saem da listagem sem apagar o registro.",
        "E-mail ao cliente em toda mudança de status, visível no Mailpit.",
        "Testes RSpec dos fluxos críticos da fase 2.",
        "Dockerfile em estágios e docker-compose com API, PostgreSQL e Mailpit.",
        "Manifestos em /k8s: Deployment, Service, ConfigMap, Secret, banco, HPA e metrics-server.",
        "Terraform em /infra: cluster kind local e PostgreSQL.",
        "GitHub Actions: testes, imagem, Terraform, deploy dos manifestos e consumo da API.",
        "README com arquitetura, execução local, Kubernetes e Terraform.",
        "Vídeo de até 15 minutos: deploy, CI/CD, APIs e escalabilidade.",
    ]:
        doc.bullet(item)

    doc.heading("5. Stack técnica")
    doc.table(
        [
            ["Componente", "Escolha / versão"],
            ["Linguagem", "Ruby 3.3.6"],
            ["Framework", "Ruby on Rails 8.0"],
            ["Banco de dados", "PostgreSQL 16"],
            ["Autenticação", "JWT + bcrypt; token de integração no webhook"],
            ["E-mail", "Action Mailer + Mailpit (SMTP)"],
            ["Documentação API", "OpenAPI / Swagger (rswag)"],
            ["Testes", "RSpec + FactoryBot + SimpleCov"],
            ["Container", "Docker em múltiplos estágios + Docker Compose"],
            ["Orquestração", "Kubernetes local com kind"],
            ["Autoscaling", "Horizontal Pod Autoscaler (CPU 60% e memória 80%)"],
            ["IaC", "Terraform 1.5+ (provider null + CLI kind)"],
            ["CI/CD", "GitHub Actions"],
        ],
        [160, CONTENT_W - 160],
    )

    doc.heading("6. Arquitetura proposta")
    doc.paragraph(
        "O desenho abaixo é o ambiente da fase 2. Terraform e GitHub Actions provisionam "
        "o mesmo tipo de cluster. A API só conversa com o banco e com o SMTP."
    )
    doc.ensure(198)
    top = doc.y
    gap = 8
    box_w = (CONTENT_W - 2 * gap) / 3
    doc.box(MARGIN, top, box_w, 52, "Terraform", ["Cria o cluster kind", "Aplica o PostgreSQL"])
    doc.box(MARGIN + box_w + gap, top, box_w, 52, "GitHub Actions", ["Testa e gera a imagem", "Aplica os manifestos"])
    doc.box(MARGIN + 2 * (box_w + gap), top, box_w, 52, "Quem chama a API", ["Operador com JWT", "Sistema externo com token"])
    cluster_y = top + 64
    doc.fill_rect(MARGIN, cluster_y, CONTENT_W, 122, (0.96, 0.97, 0.98))
    doc.stroke_rect(MARGIN, cluster_y, CONTENT_W, 122, (0.12, 0.31, 0.47), 1.2)
    doc.text(MARGIN + 10, cluster_y + 16, "Cluster Kubernetes local (kind)  -  sem provedor cloud", "F2", 10, (0.12, 0.31, 0.47))
    inner_y = cluster_y + 28
    inner_w = (CONTENT_W - 40) / 3
    doc.box(MARGIN + 10, inner_y, inner_w, 78, "API Rails", ["Deployment oficina-api", "Service NodePort 30080", "HPA de 1 a 5 pods"])
    doc.box(MARGIN + 18 + inner_w, inner_y, inner_w, 78, "PostgreSQL 16", ["Deployment e Service", "Volume persistente", "Banco oficina_production"])
    doc.box(MARGIN + 26 + 2 * inner_w, inner_y, inner_w, 78, "Mailpit", ["SMTP interno", "Interface NodePort 30025", "E-mail de cada status"])
    doc.y = cluster_y + 134
    doc.paragraph(
        "Componentes da aplicação: domínio (CPF, placa, status, fila, estoque e orçamento), "
        "casos de uso (abrir OS, transições, notificação externa e e-mail), ActiveRecord e "
        "controllers REST. ConfigMap guarda o ambiente. Secret guarda a URL do banco, o JWT "
        "e o token de integração."
    )
    doc.paragraph(
        "Fluxo de deploy: a pipeline roda os testes, constrói a imagem oficina-api:local, "
        "executa terraform apply, carrega a imagem no kind e aplica os YAML de /k8s. "
        "No computador, os mesmos comandos estão no README. O entrypoint da API roda "
        "db:prepare antes de subir o servidor."
    )

    doc.heading("7. Evolução das APIs")
    doc.table(
        [
            ["Fluxo", "Contrato"],
            ["Abertura da OS", "POST /api/v1/admin/service_orders, com JWT. Devolve id, number e public_token."],
            ["Consulta de status", "GET /api/v1/public/service_orders/{public_token}, sem JWT."],
            ["Notificação externa", "POST /api/v1/integrations/budget_notifications. Header X-Integration-Token. decision approved ou rejected."],
            ["Fila operacional", "GET /api/v1/admin/service_orders. Prioridade de status e mais antigas primeiro. Sem finalizada e entregue."],
            ["E-mail de status", "Disparado na abertura e em cada transição. Caixa local no Mailpit."],
        ],
        [130, CONTENT_W - 130],
    )
    doc.paragraph(
        "Aprovar pela notificação externa, com a OS em Aguardando aprovação, muda o status "
        "para Em execução e debita o estoque na mesma transação. Recusar devolve a OS para "
        "Em diagnóstico, sem debitar. A API pública de approve e reject da fase 1 permanece."
    )

    doc.heading("8. Infraestrutura")
    doc.paragraph(
        "Docker Compose, para o desenvolvimento: API na porta 3000, PostgreSQL 16 e Mailpit "
        "na porta 8025. É o ambiente já usado para seed e testes. Não substitui o Kubernetes."
    )
    doc.paragraph(
        "Kubernetes, pasta /k8s: namespace oficina, ConfigMap, Secret, PostgreSQL com PVC, "
        "Mailpit, Deployment e Service da API, HPA e metrics-server. O HPA usa CPU e memória. "
        "O metrics-server leva o argumento kubelet-insecure-tls porque o kind não assina "
        "o kubelet com uma CA pública."
    )
    doc.paragraph(
        "Terraform, pasta /infra: cria o cluster kind chamado oficina, com as portas 30080 "
        "e 30025 no host, e aplica namespace, Secret e PostgreSQL. terraform destroy remove "
        "o cluster. Os recursos estão descritos no README, com os comandos init, apply e destroy."
    )
    doc.paragraph(
        "CI/CD, arquivo .github/workflows/ci-cd.yml: em todo push, testa a aplicação, "
        "constrói a imagem, provisiona cluster e banco, aplica os manifestos e consulta "
        "a API dentro do cluster. Pull request executa somente os testes."
    )

    doc.heading("9. Escalabilidade na demonstração")
    doc.paragraph(
        "script/simulate_peak.sh abre várias ordens de serviço em paralelo, no cenário de pico "
        "da oficina. script/stress_cpu.sh eleva a CPU do pod para o HPA criar réplicas. "
        "O acompanhamento é kubectl -n oficina get hpa oficina-api -w. O mínimo é 1 réplica "
        "e o máximo é 5."
    )

    doc.heading("10. Como reproduzir")
    doc.paragraph("Desenvolvimento, sem cluster:")
    doc.bullet("docker compose up --build")
    doc.bullet("docker compose exec app bundle exec rails db:seed")
    doc.bullet("docker compose --profile test run --rm test")
    doc.paragraph("Cluster local, depois das ferramentas kind, kubectl e terraform:")
    doc.bullet("docker build --target runtime --build-arg BUNDLE_WITHOUT=\"development test\" -t oficina-api:local .")
    doc.bullet("terraform -chdir=infra init && terraform -chdir=infra apply")
    doc.bullet("kind load docker-image oficina-api:local --name oficina")
    doc.bullet("bash k8s/apply.sh")
    doc.bullet("kubectl -n oficina exec deploy/oficina-api -- env SEED_DEMO=true bundle exec rails db:seed")
    doc.paragraph(
        "Login administrativo: admin@oficina.test / oficina123. "
        "Token de integração: local-dev-integration-token."
    )

    pages = doc.finish()
    write_pdf(pages, OUT)
    print(f"{OUT} ({len(pages)} páginas)")


def write_pdf(pages, path):
    objects = []

    def add(data):
        objects.append(data)
        return len(objects)

    font_regular = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>")
    font_bold = add(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>")
    page_ids = []
    content_ids = []
    for ops in pages:
        stream = ("\n".join(ops)).encode("cp1252", errors="replace")
        compressed = zlib.compress(stream)
        content_ids.append(
            add(
                b"<< /Length %d /Filter /FlateDecode >>\nstream\n" % len(compressed)
                + compressed
                + b"\nendstream"
            )
        )
        page_ids.append(None)
    pages_id_placeholder = len(objects) + 1 + len(page_ids)
    for index, content_id in enumerate(content_ids):
        page = (
            f"<< /Type /Page /Parent {pages_id_placeholder} 0 R "
            f"/MediaBox [0 0 {PAGE_W:.2f} {PAGE_H:.2f}] "
            f"/Contents {content_id} 0 R "
            f"/Resources << /Font << /F1 {font_regular} 0 R /F2 {font_bold} 0 R >> >> >>"
        ).encode("ascii")
        page_ids[index] = add(page)
    kids = " ".join(f"{page_id} 0 R" for page_id in page_ids)
    pages_id = add(f"<< /Type /Pages /Count {len(page_ids)} /Kids [{kids}] >>".encode("ascii"))
    assert pages_id == pages_id_placeholder
    catalog_id = add(f"<< /Type /Catalog /Pages {pages_id} 0 R >>".encode("ascii"))

    out = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for index, obj in enumerate(objects, start=1):
        offsets.append(len(out))
        out.extend(f"{index} 0 obj\n".encode("ascii"))
        out.extend(obj)
        out.extend(b"\nendobj\n")
    xref = len(out)
    out.extend(f"xref\n0 {len(objects) + 1}\n".encode("ascii"))
    out.extend(b"0000000000 65535 f \n")
    for offset in offsets[1:]:
        out.extend(f"{offset:010d} 00000 n \n".encode("ascii"))
    out.extend(
        f"trailer << /Size {len(objects) + 1} /Root {catalog_id} 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode(
            "ascii"
        )
    )
    path.write_bytes(out)


if __name__ == "__main__":
    build()
