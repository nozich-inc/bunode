import { $ } from 'bun';

const inspect = await $`docker buildx inspect | grep 'Platforms:' | sed 's/Platforms: //'`.text();

console.log('inspect', inspect);

