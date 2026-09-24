# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# Dockerfile corregido - INF384 Lab 3 (Parte A1)
# Build multi-etapa: la etapa final solo recibe el artefacto empaquetado.

# ---------- Etapa 1: build ----------
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# Manifiesto y lock file antes del código, para aprovechar la cache de capas
COPY package.json package-lock.json ./
RUN npm ci

# Código de la aplicación
COPY src ./src

# Empaqueta el handler y sus dependencias en dist/handler.js (esbuild)
RUN npm run build

# ---------- Etapa 2: imagen final ----------
FROM public.ecr.aws/lambda/nodejs:20

# Solo el artefacto empaquetado, sin node_modules ni código fuente suelto
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/

CMD ["handler.handler"]
