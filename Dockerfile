FROM node:14-alpine3.16 as base

FROM base as build
RUN npm install pm2

# backend

FROM build as backend

WORKDIR /src/backend
COPY backend/package.json .
RUN npm install
COPY backend .
RUN npm run build

# frontend

FROM build as frontend

WORKDIR /src/frontend
COPY frontend/package.json .
RUN npm install
COPY frontend .
RUN npm run build

# final

FROM base as final

WORKDIR /src/backend
COPY --from=backend /src/backend .

WORKDIR /src/frontend
COPY --from=frontend /src/frontend .

WORKDIR /src
COPY package.json .
RUN npm install

ENV NODE_ENV=production
CMD ["npm", "run", "start"]

EXPOSE 3000