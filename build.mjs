import { $ } from 'bun';

await $`docker build --no-cache -t nozich/bunode:latest .`;
await $`docker buildx prune -f`;
await $`docker volume prune -f`;

