export interface ApiConfig {
  baseUrl: string;
}

const fallbackApiBaseUrl = 'http://127.0.0.1:8080/api/v1';

function readInjectedBaseUrl(): string | undefined {
  const env = typeof __wxConfig === 'undefined' ? undefined : __wxConfig.env;
  return env?.API_BASE_URL;
}

function normalizeBaseUrl(baseUrl: string | undefined): string {
  const candidate = baseUrl?.trim() || fallbackApiBaseUrl;
  return candidate.replace(/\/+$/, '');
}

export const apiConfig: ApiConfig = {
  baseUrl: normalizeBaseUrl(readInjectedBaseUrl())
};
