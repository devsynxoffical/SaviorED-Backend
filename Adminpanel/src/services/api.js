import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'https://api.example.com';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
// Response interceptor for error handling & retries
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Retry configuration
    const MAX_RETRIES = 3;
    originalRequest._retryCount = originalRequest._retryCount || 0;

    // Check if error is retryable (Network Error, Timeout, or 503 Service Unavailable)
    const isRetryable =
      !originalRequest._retry &&
      originalRequest._retryCount < MAX_RETRIES &&
      (error.code === 'ECONNABORTED' || error.message.includes('Network Error') || error.response?.status === 503);

    if (isRetryable) {
      originalRequest._retry = true; // Mark as retrying to prevent infinite loops (though technically managed by count)
      originalRequest._retryCount += 1;

      console.log(`🔄 Connection retry attempt ${originalRequest._retryCount}/${MAX_RETRIES}...`);

      // Wait before retrying (exponential backoff: 1s, 2s, 4s)
      const delay = 1000 * Math.pow(2, originalRequest._retryCount - 1);
      await new Promise(resolve => setTimeout(resolve, delay));

      return api(originalRequest);
    }

    if (error.response?.status === 401) {
      // Unauthorized - clear token and redirect to login
      localStorage.removeItem('admin_token');
      // Only redirect if not already on login page
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (email, password) => api.post('/admin/login', { email, password }),
  logout: () => api.post('/admin/logout'),
  getProfile: () => api.get('/admin/profile'),
};

// Users API
export const usersAPI = {
  getAll: (page = 1, limit = 20) => api.get('/admin/users', { params: { page, limit } }),
  getById: (id) => api.get(`/admin/users/${id}`),
  update: (id, data) => api.put(`/admin/users/${id}`, data),
  delete: (id) => api.delete(`/admin/users/${id}`),
  search: (query) => api.get('/admin/users/search', { params: { q: query } }),
};

// Focus Sessions API
export const focusSessionsAPI = {
  getAll: (page = 1, limit = 20, filters = {}) =>
    api.get('/admin/focus-sessions', { params: { page, limit, ...filters } }),
  getById: (id) => api.get(`/admin/focus-sessions/${id}`),
  getByUserId: (userId, page = 1, limit = 20) =>
    api.get(`/admin/focus-sessions/user/${userId}`, { params: { page, limit } }),
  delete: (id) => api.delete(`/admin/focus-sessions/${id}`),
  getStats: () => api.get('/admin/focus-sessions/stats'),
};

// Castle Grounds API
export const castleGroundsAPI = {
  getAll: (page = 1, limit = 20) => api.get('/admin/castle-grounds', { params: { page, limit } }),
  getById: (id) => api.get(`/admin/castle-grounds/${id}`),
  getByUserId: (userId) => api.get(`/admin/castle-grounds/user/${userId}`),
  update: (id, data) => api.put(`/admin/castle-grounds/${id}`, data),
  getStats: () => api.get('/admin/castle-grounds/stats'),
};

// Leaderboard API
export const leaderboardAPI = {
  getGlobal: (page = 1, limit = 20) =>
    api.get('/admin/leaderboard/global', { params: { page, limit } }),
  getSchool: (page = 1, limit = 20) =>
    api.get('/admin/leaderboard/school', { params: { page, limit } }),
  updateEntry: (id, data) => api.put(`/admin/leaderboard/${id}`, data),
  refresh: (type = 'global') => api.post(`/admin/leaderboard/refresh`, { type }),
};

// Treasure Chests API
export const treasureChestsAPI = {
  getAll: (page = 1, limit = 20, filters = {}) =>
    api.get('/admin/treasure-chests', { params: { page, limit, ...filters } }),
  getById: (id) => api.get(`/admin/treasure-chests/${id}`),
  getByUserId: (userId) => api.get(`/admin/treasure-chests/user/${userId}`),
  update: (id, data) => api.put(`/admin/treasure-chests/${id}`, data),
  getStats: () => api.get('/admin/treasure-chests/stats'),
};

// Settings API
export const settingsAPI = {
  getAll: () => api.get('/admin/settings'),
  update: (key, data) => api.put(`/admin/settings/${key}`, data),
};

// Dashboard API
export const dashboardAPI = {
  getStats: () => api.get('/admin/dashboard/stats'),
  getRecentActivity: (limit = 10) =>
    api.get('/admin/dashboard/activity', { params: { limit } }),
};

export default api;

