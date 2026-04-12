import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'

export const useItemsStore = defineStore('items', () => {
  const items = ref([])
  const current = ref(null)
  const inbox = ref([])
  const loading = ref(false)
  const error = ref(null)
  const pagination = ref({
    total: 0,
    per_page: 50,
    current_page: 1,
    last_page: 1,
  })

  async function fetch(params = {}) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.get('/items', { params })
      items.value = response.data.data.data || response.data.data
      if (response.data.data.meta) {
        pagination.value = {
          total: response.data.data.meta.total,
          per_page: response.data.data.meta.per_page,
          current_page: response.data.data.meta.current_page,
          last_page: response.data.data.meta.last_page,
        }
      }
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Laden'
      return false
    } finally {
      loading.value = false
    }
  }

  async function fetchInbox() {
    loading.value = true
    try {
      const response = await api.get('/inbox/items')
      inbox.value = response.data.data
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Laden'
      return false
    } finally {
      loading.value = false
    }
  }

  async function fetchOne(id) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.get(`/items/${id}`)
      current.value = response.data.data
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Laden'
      return false
    } finally {
      loading.value = false
    }
  }

  async function create(data) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.post('/items', data)
      items.value.unshift(response.data.data)
      return response.data.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Erstellen'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function update(id, data) {
    loading.value = true
    error.value = null
    
    try {
      const response = await api.put(`/items/${id}`, data)
      const index = items.value.findIndex(i => i.id === id)
      if (index !== -1) {
        items.value[index] = response.data.data
      }
      if (current.value?.id === id) {
        current.value = response.data.data
      }
      return response.data.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Aktualisieren'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function remove(id) {
    loading.value = true
    error.value = null
    
    try {
      await api.delete(`/items/${id}`)
      items.value = items.value.filter(i => i.id !== id)
      if (current.value?.id === id) {
        current.value = null
      }
      return true
    } catch (err) {
      error.value = err.response?.data?.message || 'Fehler beim Löschen'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function assignToRoom(id, roomId) {
    try {
      const response = await api.post(`/items/${id}/assign-room`, { room_id: roomId })
      const index = items.value.findIndex(i => i.id === id)
      if (index !== -1) {
        items.value[index] = response.data.data
      }
      return response.data.data
    } catch (err) {
      throw err
    }
  }

  async function assignToBox(id, boxId) {
    try {
      const response = await api.post(`/items/${id}/assign-box`, { box_id: boxId })
      const index = items.value.findIndex(i => i.id === id)
      if (index !== -1) {
        items.value[index] = response.data.data
      }
      return response.data.data
    } catch (err) {
      throw err
    }
  }

  async function moveToInbox(id) {
    try {
      const response = await api.post(`/items/${id}/move-to-inbox`)
      const index = items.value.findIndex(i => i.id === id)
      if (index !== -1) {
        items.value[index] = response.data.data
      }
      return response.data.data
    } catch (err) {
      throw err
    }
  }

  async function generateQrCode(id) {
    try {
      const response = await api.post(`/items/${id}/qr-code`)
      if (current.value?.id === id) {
        current.value.qr_code_image = response.data.data.qr_code_image
        current.value.qr_token = response.data.data.qr_token
      }
      return response.data.data
    } catch (err) {
      throw err
    }
  }

  return {
    items,
    current,
    inbox,
    loading,
    error,
    pagination,
    fetch,
    fetchInbox,
    fetchOne,
    create,
    update,
    remove,
    assignToRoom,
    assignToBox,
    moveToInbox,
    generateQrCode,
  }
})