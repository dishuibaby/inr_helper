async function fetchPreview(origin, previewPath, request, env) {
  const previewUrl = new URL(previewPath, origin);
  const previewRequest = new Request(previewUrl, {
    method: request.method,
    headers: request.headers,
    cf: { cacheTtl: 0, cacheEverything: false }
  });
  const previewResponse = await env.ASSETS.fetch(previewRequest);
  if (previewResponse.ok && (previewResponse.headers.get('content-type') || '').includes('text/html')) {
    const headers = new Headers(previewResponse.headers);
    headers.set('x-markdown-preview', '1');
    headers.set('cache-control', 'no-store, max-age=0');
    return new Response(previewResponse.body, { status: previewResponse.status, statusText: previewResponse.statusText, headers });
  }
  return null;
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.endsWith('.md') && url.searchParams.get('raw') !== '1') {
      return await fetchPreview(url.origin, `${url.pathname}/`, request, env)
        || await fetchPreview(url.origin, `${url.pathname.replace(/\.md$/i, '')}/`, request, env)
        || env.ASSETS.fetch(request);
    }
    return env.ASSETS.fetch(request);
  }
};
