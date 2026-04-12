<template>
  <div class="inbox-page">
    <div class="page-header">
      <h1>Inbox</h1>
      <p class="page-subtitle">Noch nicht zugeordnete Elemente</p>
    </div>

    <div class="inbox-tabs">
      <button
        :class="['tab', { active: activeTab === 'items' }]"
        @click="activeTab = 'items'"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
        </svg>
        Gegenstände ({{ items.length }})
      </button>
      <button
        :class="['tab', { active: activeTab === 'boxes' }]"
        @click="activeTab = 'boxes'"
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
        </svg>
        Boxen ({{ boxes.length }})
      </button>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Wird geladen...</p>
    </div>

    <!-- Items Tab -->
    <div v-else-if="activeTab === 'items'">
      <div v-if="items.length === 0" class="empty-card">
        <p>Keine Gegenstände in der Inbox</p>
      </div>
      <div v-else class="items-list">
        <div v-for="item in items" :key="item.id" class="inbox-item card">
          <div class="item-info">
            <span class="item-id">I{{ item.id }}</span>
            <div class="item-details">
              <h3>{{ item.name }}</h3>
              <p v-if="item.category">{{ item.category.name }}</p>
            </div>
          </div>
          <div class="item-actions">
            <select v-model="item._targetRoom" class="assign-select">
              <option value="">Raum wählen...</option>
              <option v-for="room in rooms" :key="room.id" :value="room.id">
                {{ room.name }} (R{{ room.id }})
              </option>
            </select>
            <button
              class="btn-primary btn-sm"
              :disabled="!item._targetRoom && !item._targetBox"
              @click="assignItem(item)"
            >
              Zuweisen
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Boxes Tab -->
    <div v-else-if="activeTab === 'boxes'">
      <div v-if="boxes.length === 0" class="empty-card">
        <p>Keine Boxen in der Inbox</p>
      </div>
      <div v-else class="items-list">
        <div v-for="box in boxes" :key="box.id" class="inbox-item card">
          <div class="item-info">
            <span class="item-id box">B{{ box.id }}</span>
            <div class="item-details">
              <h3>{{ box.name }}</h3>
              <p>{{ box.items_count || 0 }} Items</p>
            </div>
          </div>
          <div class="item-actions">
            <select v-model="box._targetRoom" class="assign-select">
              <option value="">Raum wählen...</option>
              <option v-for="room in rooms" :key="room.id" :value="room.id">
                {{ room.name }} (R{{ room.id }})
              </option>
            </select>
            <button
              class="btn-primary btn-sm"
              :disabled="!box._targetRoom"
              @click="assignBox(box)"
            >
              Zuweisen
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const toast = useToast()
const activeTab = ref('items')
const items = ref([])
const boxes = ref([])
const rooms = ref([])
const loading = ref(true)

onMounted(async () => {
  await Promise.all([fetchInbox(), fetchRooms()])
  loading.value = false
})

async function fetchInbox() {
  try {
    const response = await api.get('/dashboard/inbox')
    items.value = response.data.data.items.map(i => ({ ...i, _targetRoom: '' }))
    boxes.value = response.data.data.boxes.map(b => ({ ...b, _targetRoom: '' }))
  } catch (error) {
    toast.error('Fehler beim Laden der Inbox')
  }
}

async function fetchRooms() {
  try {
    const response = await api.get('/rooms')
    rooms.value = response.data.data
  } catch (error) {
    console.error('Fehler beim Laden der Räume')
  }
}

async function assignItem(item) {
  try {
    await api.post(`/items/${item.id}/assign-room`, { room_id: item._targetRoom })
    toast.success('Item zugewiesen')
    items.value = items.value.filter(i => i.id !== item.id)
  } catch (error) {
    toast.error('Fehler beim Zuweisen')
  }
}

async function assignBox(box) {
  try {
    await api.post(`/boxes/${box.id}/assign-room`, { room_id: box._targetRoom })
    toast.success('Box zugewiesen')
    boxes.value = boxes.value.filter(b => b.id !== box.id)
  } catch (error) {
    toast.error('Fehler beim Zuweisen')
  }
}
</script>

<style lang="scss" scoped>
.inbox-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 1.5rem;
  
  h1 {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 0.25rem;
  }
  
  .page-subtitle {
    color: #6b7280;
    margin: 0;
  }
}

.inbox-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
}

.tab {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 1px solid #e5e7eb;
  background: white;
  border-radius: 8px;
  font-size: 0.875rem;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
  
  &.active {
    background: #3b82f6;
    border-color: #3b82f6;
    color: white;
  }
  
  &:hover:not(.active) {
    background: #f3f4f6;
  }
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
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

.empty-card {
  padding: 2rem;
  text-align: center;
  color: #6b7280;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.items-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.inbox-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
}

.item-info {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.item-id {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: #dbeafe;
  color: #1e40af;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
  
  &.box {
    background: #dcfce7;
    color: #166534;
  }
}

.item-details {
  h3 {
    font-size: 1rem;
    font-weight: 600;
    margin: 0;
  }
  
  p {
    font-size: 0.875rem;
    color: #6b7280;
    margin: 0;
  }
}

.item-actions {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.assign-select {
  padding: 0.5rem 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.875rem;
  min-width: 180px;
}

.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.75rem;
}

@media (max-width: 640px) {
  .inbox-item {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .item-actions {
    flex-direction: column;
    
    .assign-select {
      width: 100%;
    }
  }
}
</style>