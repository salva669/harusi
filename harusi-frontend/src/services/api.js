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
    api.post('/auth-token/', { username, password }),
  register: (username, email, password) =>
    api.post('/register/', { username, email, password }),
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

// Gallery endpoints 
export const galleryAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/galleries/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/galleries/`, data),
  update: (weddingId, galleryId, data) =>
    api.put(`/weddings/${weddingId}/galleries/${galleryId}/`, data),
  delete: (weddingId, galleryId) =>
    api.delete(`/weddings/${weddingId}/galleries/${galleryId}/`),
};

// Photo endpoints 
export const photoAPI = {
  getAll: (weddingId, albumId) => api.get(`/weddings/${weddingId}/galleries/${albumId}/photos/`),
  create: (weddingId, albumId, data) => api.post(`/weddings/${weddingId}/galleries/${albumId}/photos/`, data),
  update: (weddingId, albumId, photoId, data) =>
    api.put(`/weddings/${weddingId}/galleries/${albumId}/photos/${photoId}/`, data),
  delete: (weddingId, albumId, photoId) =>
    api.delete(`/weddings/${weddingId}/galleries/${albumId}/photos/${photoId}/`),
};

// Timeline endpoints 
export const timelineAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/timeline/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/timeline/`, data),
  update: (weddingId, eventId, data) =>
    api.put(`/weddings/${weddingId}/timeline/${eventId}/`, data),
  delete: (weddingId, eventId) =>
    api.delete(`/weddings/${weddingId}/timeline/${eventId}/`),
  toggleCompleted: (weddingId, eventId) =>
    api.post(`/weddings/${weddingId}/timeline/${eventId}/toggle_completed/`),
};

// Vendor endpoints 
export const vendorAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/vendors/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/vendors/`, data),
  update: (weddingId, vendorId, data) =>
    api.put(`/weddings/${weddingId}/vendors/${vendorId}/`, data),
  delete: (weddingId, vendorId) =>
    api.delete(`/weddings/${weddingId}/vendors/${vendorId}/`),
  addNote: (weddingId, vendorId, data) =>
    api.post(`/weddings/${weddingId}/vendors/${vendorId}/add_note/`, data),
};

// Analytics endpoints 
export const analyticsAPI = {
  getAnalytics: (weddingId) => api.get(`/weddings/${weddingId}/analytics/`),
  getTrends: (weddingId) => api.get(`/weddings/${weddingId}/analytics/trends/`),
  getHealthScores: (weddingId) => api.get(`/weddings/${weddingId}/analytics/health-scores/`),
  getCategoryBreakdown: (weddingId) => api.get(`/weddings/${weddingId}/analytics/budget-breakdown/`),
  getTimelineStatus: (weddingId) => api.get(`/weddings/${weddingId}/analytics/timeline-status/`),
  getGuestAnalytics: (weddingId) => api.get(`/weddings/${weddingId}/analytics/guest-analytics/`),
};

// Pledge endpoints
export const pledgeAPI = {
  getAll: (weddingId) => api.get(`/weddings/${weddingId}/pledges/`),
  getOne: (weddingId, pledgeId) => api.get(`/weddings/${weddingId}/pledges/${pledgeId}/`),
  create: (weddingId, data) => api.post(`/weddings/${weddingId}/pledges/`, data),
  update: (weddingId, pledgeId, data) => api.put(`/weddings/${weddingId}/pledges/${pledgeId}/`, data),
  delete: (weddingId, pledgeId) => api.delete(`/weddings/${weddingId}/pledges/${pledgeId}/`),
  getSummary: (weddingId) => api.get(`/weddings/${weddingId}/pledges/summary/`),
  recordPayment: (weddingId, pledgeId, data) => 
    api.post(`/weddings/${weddingId}/pledges/${pledgeId}/record_payment/`, data),
};

// Payment endpoints
export const pledgePaymentAPI = {
  getAll: (weddingId, pledgeId) => api.get(`/weddings/${weddingId}/pledges/${pledgeId}/payments/`),
  create: (weddingId, pledgeId, data) => api.post(`/weddings/${weddingId}/pledges/${pledgeId}/payments/`, data),
  delete: (weddingId, pledgeId, paymentId) => 
    api.delete(`/weddings/${weddingId}/pledges/${pledgeId}/payments/${paymentId}/`),
};

export default api;