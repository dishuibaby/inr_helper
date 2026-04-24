import type { AppInstance } from './types/wechat';
import { apiConfig } from './utils/config';

App<AppInstance>({
  globalData: {
    apiBaseUrl: apiConfig.baseUrl
  }
});
