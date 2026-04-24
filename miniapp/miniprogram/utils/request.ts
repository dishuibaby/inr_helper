import { apiConfig } from './config';

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  data?: unknown;
}

interface ApiEnvelope<T> {
  code: number;
  message: string;
  data?: T;
}

function isEnvelope<T>(value: unknown): value is ApiEnvelope<T> {
  return typeof value === 'object' && value !== null && 'code' in value && 'message' in value;
}

export class RequestError extends Error {
  readonly statusCode?: number;

  constructor(message: string, statusCode?: number) {
    super(message);
    this.name = 'RequestError';
    this.statusCode = statusCode;
  }
}

function joinUrl(baseUrl: string, path: string): string {
  const normalizedBase = baseUrl.replace(/\/+$/, '');
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  return `${normalizedBase}${normalizedPath}`;
}

export function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const url = joinUrl(apiConfig.baseUrl, path);

  return new Promise<T>((resolve, reject) => {
    wx.request<ApiEnvelope<T> | T>({
      url,
      method: options.method ?? 'GET',
      data: options.data,
      header: {
        'content-type': 'application/json'
      },
      success(result) {
        if (result.statusCode >= 200 && result.statusCode < 300) {
          if (isEnvelope<T>(result.data)) {
            if (result.data.code === 0) {
              resolve(result.data.data as T);
              return;
            }
            reject(new RequestError(result.data.message || '请求失败', result.statusCode));
            return;
          }
          resolve(result.data as T);
          return;
        }
        reject(new RequestError(`请求失败（${result.statusCode}）`, result.statusCode));
      },
      fail(error) {
        reject(new RequestError(error.errMsg || '网络请求失败'));
      }
    });
  });
}
