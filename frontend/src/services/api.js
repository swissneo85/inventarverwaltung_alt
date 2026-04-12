import axios from 'axios'
import { useToast } from 'vue-toastification'

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  withCredentials: true,
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const toast = useToast()
    
    if (error.response) {
      const { status, data } = error.response
      
      if (status === 401) {
        localStorage.removeItem('token')
        if (window.location.pathname !== '/login') {
          window.location.href = '/login'
        }
      } else if (status === 403) {
        toast.error('Keine Berechtigung für diese Aktion')
      } else if (status === 404) {
        toast.error('Nicht gefunden')
      } else if (status === 422) {
        const errors = data.errors
        if (errors) {
          Object.values(errors).forEach((msgs) => {
            msgs.forEach((msg) => toast.error(msg))
          })
        } else {
          toast.error(data.message || 'Validierungsfehler')
        }
      } else if (status >= 500) {
        toast.error('Serverfehler. Bitte versuchen Sie es später erneut.')
      } else {
        toast.error(data.message || 'Ein Fehler ist aufgetreten')
      }
    } else {
      toast.error('Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.')
    }
    
    return Promise.reject(error)
  }
)

export default api