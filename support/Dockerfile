FROM augurproject/augur-core-base:latest
WORKDIR /app

# Install basics of the application
COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json
RUN npm install

COPY .soliumrc.json /app/.soliumrc.json
COPY tsconfig.json /app/tsconfig.json
COPY typings/ /app/typings/
COPY source/contracts/ /app/source/contracts/
COPY source/deployment/compileContracts.ts /app/source/deployment/compileContracts.ts
COPY source/libraries/Configuration.ts /app/source/libraries/Configuration.ts
COPY source/libraries/ContractCompiler.ts /app/source/libraries/ContractCompiler.ts

# Build first chunk
RUN npm run build:source
RUN npm run build:contracts

COPY source/libraries/ContractInterfacesGenerator.ts /app/source/libraries/ContractInterfacesGenerator.ts
COPY source/tools/generateContractInterfaces.ts /app/source/tools/generateContractInterfaces.ts

# Build contract interfaces
RUN npm run build:source
RUN npm run build:interfaces

# Copy source
COPY source/ /app/source/
COPY tests/ /app/tests/

COPY ./support/deploy/deploy.sh /app/support/deploy/deploy.sh
COPY ./support/artifacts/run.sh /app/support/artifacts/run.sh
COPY ./support/.npmrc /root/.npmrc.deploy

# Copy the git info so ContractDeployer can read the hash on deploy
COPY .git/ /app/.git/
RUN npm run build:source
