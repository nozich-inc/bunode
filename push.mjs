#!/usr/bin/env zx

const img = 'nozich/bunode'

async function main() {
  await $`docker pull ${img}:latest`

  const { stdout: inspect } = await $`docker buildx inspect | grep 'Platforms:' | sed 's/Platforms: //'`;

  const platforms = inspect.split(',').map(e => e.trim()).map((p) => ({
    platform: p,
    os: p.split('/')[0],
    arch: p.split('/')[1],
    tag: p.replace(/[^a-zA-Z0-9]/g, '-').toLowerCase()
  }));

  console.log(`platforms`, platforms.map((p) => p.tag).join(','));

  const built = (await Promise.all(platforms.map(async ({ platform, tag }) => {
    const build = await $`docker buildx build --platform=${platform} -t ${img}:${tag} --push .`
      .catch((e) => e);

    console.log(`[BUILD] [END] [${platform}] [${tag}] {code: ${build.code}}`);

    return (!build.code || build.code === 0) && tag
  }))).filter(Boolean);

  console.log(`built`, built);

  if (built.length === 0) {
    console.error('No images were built');
    return;
  }

  const currents = await fetch(`https://registry.hub.docker.com/v2/repositories/${img}/tags/`)
    .then((res) => res.json())
    .then((data) => data.results
      .find((r) => r.name === 'latest')
      .images.map((i) => ({
        ...i,
        arch: i.architecture,
        tag: i.variant ? `${i.os}-${i.architecture}-${i.variant}` : `${i.os}-${i.architecture}`
      })));

  const annotates = currents || []

  const news = platforms.filter((p) => built.includes(p.tag))

  news.forEach((p) => {
    if (annotates.find((a) => a.tag === p.tag)) return;
    annotates.push(p);
  });

  console.log(`annotates`, annotates.map(({ tag, os, arch }) => ({ tag, os, arch })));

  await $`docker manifest create --amend ${img}:latest ${annotates.map(({ tag }) => `${img}:${tag}`).join(' ')}`;

  await Promise.all(annotates.map(async ({ os, arch, tag }) => {
    return $`docker manifest annotate ${img} ${img}:${tag} --os ${os} --arch ${arch}`;
  }));

  await $`docker manifest push --purge ${img}:latest`
}

main();