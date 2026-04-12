import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token'))
  const loading = ref(false)
  const error = ref(null)

  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role === 'admin')

  async function login(username, password) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.post('/login', { username, password })
      token.value = response.data.data.token
      user.value = response.data.data.user
      localStorage.setItem('token', token.value)
      
      // API Token setzen
      api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Login fehlgeschlagen'
      return false
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    try {
      await api.post('/logout')
    } catch {
      // Ignorieren
    }
    
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    delete api.defaults.headers.common['Authorization']
  }

  async function fetchUser() {
    if (!token.value) return false
    
    api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
    
    try {
      const response = await api.get('/me')
      user.value = response.data.data
      return true
    } catch {
      token.value = null
      user.value = null
      localStorage.removeItem('token')
      return false
    }
  }

  async function updateProfile(data) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.put('/profile', data)
      user.value = response.data.data
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Aktualisierung fehlgeschlagen'
      return false
    } finally {
      loading.value = false
    }
  }

  // Initial Token setzen falls vorhanden
  if (token.value) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
  }

  return {
    user,
    token,
    loading,
    error,
    isAuthenticated,
    isAdmin,
    login,
    logout,
    fetchUser,
    updateProfile,
  }
})