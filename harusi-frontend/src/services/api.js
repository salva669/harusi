import axios from 'axios';

const API_BASE_URL = 'http://localhost:8000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Token ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Auth endpoints
export const authAPI = {
  login: (username, password) =>
    api.post('/auth/login/', { username, password }),
  register: (username, email, password) =>
    api.post('/auth/register/', { username, email, password }),
  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
};

// Wedding endpoints
export const weddingAPI = {
  getAll: () => api.get('/weddings/'),
  getOne: (id) => api.get(`/weddings/${id}/`),
  create: (data) => api.post('/weddings/', data),
  update: (id, data) => api.put(`/weddings/${id}/`, data),
  delete: (id) => api.delete(`/weddings/${id}/`),
  getSummary: (id) => api.get(`/weddings/${id}/summary/`),
};

// Guest endpoints
export const guestAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/guests/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/guests/`, data),
  update: (weddingId, guestId, data) =>
    api.put(`/weddings/${weddingId}/guests/${guestId}/`, data),
  delete: (weddingId, guestId) =>
    api.delete(`/weddings/${weddingId}/guests/${guestId}/`),
};

// Task endpoints
export const taskAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/tasks/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/tasks/`, data),
  update: (weddingId, taskId, data) =>
    api.put(`/weddings/${weddingId}/tasks/${taskId}/`, data),
  delete: (weddingId, taskId) =>
    api.delete(`/weddings/${weddingId}/tasks/${taskId}/`),
};

// Budget endpoints
export const budgetAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/budget/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/budget/`, data),
  update: (weddingId, budgetId, data) =>
    api.put(`/weddings/${weddingId}/budget/${budgetId}/`, data),
  delete: (weddingId, budgetId) =>
    api.delete(`/weddings/${weddingId}/budget/${budgetId}/`),
};

export default api;