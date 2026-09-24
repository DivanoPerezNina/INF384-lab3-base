# Dockerfile del repositorio base.
# Contiene cinco malas practicas deliberadas. Cada una lleva su numero en la
# linea anterior. Corregirlas es el bloque A1 de la guia del laboratorio.

# defecto 1 corregido: version fija en vez de "latest"
FROM public.ecr.aws/lambda/nodejs:20 AS build

WORKDIR /build

# defecto 2 corregido: manifiesto y lock file antes del codigo
COPY package.json package-lock.json ./

# defecto 3 corregido: instalar desde el lock file
RUN npm ci

# Codigo de la aplicacion, copiado despues de instalar dependencias
COPY src ./src

# defecto 4: eliminado (credencial en texto plano)
# defecto 5: eliminado (herramientas de depuracion en la etapa final)

### NO TOCAR DE ACA EN ADELANTE, CONSIDEREN QUE EL WORKDIR DEBE SER /build
RUN npx esbuild src/handler.js \
      --bundle --platform=node --target=node20 \
      --outfile=dist/handler.js

# Etapa final: recibe unicamente el artefacto empaquetado.
# El arbol de node_modules se queda en la etapa anterior.
FROM public.ecr.aws/lambda/nodejs:20 AS runtime
COPY --from=build /build/dist/handler.js ${LAMBDA_TASK_ROOT}/
CMD ["handler.handler"]
