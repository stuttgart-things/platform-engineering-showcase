# BACKSTAGE

## INIT

```bash

node?
npx?

npm install --global yarn
npx @backstage/create-app


```

## CONFIGURE GITHUB AUTH

https://backstage.io/docs/auth/github/provider

export AUTH_GITHUB_CLIENT_ID=Ov23li7kfy0tfiKKsZzp
export AUTH_GITHUB_CLIENT_SECRET=88d15cecb26c2d35c9c2218cf917a8e7347d8c42


Homepage URL: http://localhost:3000
Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame

### AUTH CONFIG

```yaml
auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        ## uncomment if using GitHub Enterprise
        # enterpriseInstanceUrl: ${AUTH_GITHUB_ENTERPRISE_INSTANCE_URL}
        ## uncomment to set lifespan of user session
        # sessionDuration: { hours: 24 } # supports `ms` library format (e.g. '24h', '2 days'), ISO duration, "human duration" as used in code
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
```

### BACKEND

```bash
yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-github-provider
```

# vi /packages/backend/src/index.ts
backend.add(import('@backstage/plugin-auth-backend'));
backend.add(import('@backstage/plugin-auth-backend-module-github-provider'));



### FRONTEND

# vi packages/app/src/App.tsx

import { githubAuthApiRef } from '@backstage/core-plugin-api';
import { SignInPage } from '@backstage/core-components';


## CONFIGURE GITHUB AUTH
