<template>
  <div class="rooms-page">
    <div class="page-header">
      <h1>Räume</h1>
      <button class="btn-primary" @click="showModal = true">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Neuer Raum
      </button>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Wird geladen...</p>
    </div>

    <div v-else-if="rooms.length === 0" class="empty-state">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
      </svg>
      <h3>Keine Räume angelegt</h3>
      <p>Erstellen Sie Ihren ersten Raum</p>
      <button class="btn-primary" @click="showModal = true">Raum erstellen</button>
    </div>

    <div v-else class="rooms-grid">
      <div v-for="room in rooms" :key="room.id" class="room-card card">
        <div class="room-header">
          <div class="room-id">R{{ room.id }}</div>
          <div class="room-info">
            <h3>{{ room.name }}</h3>
            <p v-if="room.description">{{ room.description }}</p>
          </div>
        </div>
        <div class="room-stats">
          <div class="stat">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
            </svg>
            <span>{{ room.items_count || 0 }} Items</span>
          </div>
          <div class="stat">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            </svg>
            <span>{{ room.boxes_count || 0 }} Boxen</span>
          </div>
        </div>
        <div class="room-actions">
          <router-link :to="`/rooms/${room.id}`" class="btn-secondary">Ansehen</router-link>
        </div>
      </div>
    </div>

    <!-- Modal for creating room -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <div class="modal-header">
          <h2>Neuer Raum</h2>
          <button class="btn-close" @click="showModal = false">×</button>
        </div>
        <form @submit.prevent="createRoom">
          <div class="modal-body">
            <div class="form-group">
              <label>Name *</label>
              <input v-model="newRoom.name" type="text" required placeholder="z.B. Keller, Garage">
            </div>
            <div class="form-group">
              <label>Beschreibung</label>
              <textarea v-model="newRoom.description" placeholder="Optional"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-secondary" @click="showModal = false">Abbrechen</button>
            <button type="submit" class="btn-primary" :disabled="saving">
              {{ saving ? 'Speichern...' : 'Erstellen' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const toast = useToast()
const rooms = ref([])
const loading = ref(true)
const showModal = ref(false)
const saving = ref(false)
const newRoom = ref({ name: '', description: '' })

onMounted(fetchRooms)

async function fetchRooms() {
  loading.value = true
  try {
    const response = await api.get('/rooms')
    rooms.value = response.data.data
  } catch (error) {
    toast.error('Fehler beim Laden der Räume')
  } finally {
    loading.value = false
  }
}

async function createRoom() {
  saving.value = true
  try {
    await api.post('/rooms', newRoom.value)
    toast.success('Raum erstellt')
    showModal.value = false
    newRoom.value = { name: '', description: '' }
    fetchRooms()
  } catch (error) {
    toast.error('Fehler beim Erstellen')
  } finally {
    saving.value = false
  }
}
</script>

<style lang="scss" scoped>
.rooms-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  
  h1 {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0;
  }
}

.rooms-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
}

.room-card {
  padding: 1.25rem;
}

.room-header {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1rem;
}

.room-id {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fef3c7;
  color: #92400e;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
}

.room-info {
  flex: 1;
  
  h3 {
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 0.25rem;
  }
  
  p {
    font-size: 0.875rem;
    color: #6b7280;
    margin: 0;
  }
}

.room-stats {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  
  .stat {
    display: flex;
    align-items: center;
    gap: 0.375rem;
    font-size: 0.875rem;
    color: #6b7280;
  }
}

.room-actions {
  display: flex;
  justify-content: flex-end;
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  
  svg {
    color: #d1d5db;
    margin-bottom: 1rem;
  }
  
  h3 {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0 0 0.5rem;
  }
  
  p {
    color: #6b7280;
    margin: 0 0 1rem;
  }
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  border-bottom: 1px solid #e5e7eb;
  
  h2 {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0;
  }
}

.btn-close {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  font-size: 1.5rem;
  color: #6b7280;
  cursor: pointer;
  
  &:hover {
    color: #1f2937;
  }
}

.modal-body {
  padding: 1.25rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  border-top: 1px solid #e5e7eb;
}
</style>