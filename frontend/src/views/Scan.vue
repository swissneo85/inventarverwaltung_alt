<template>
  <div class="scan-page">
    <div class="page-header">
      <h1>QR-Code scannen</h1>
      <p>Scannen Sie einen QR-Code, um direkt zum entsprechenden Eintrag zu gelangen.</p>
    </div>

    <!-- Manual Input -->
    <div class="card scan-card">
      <h2>QR-Code eingeben</h2>
      <p>Geben Sie die ID manuell ein (z.B. I123, B45, R12)</p>
      
      <form @submit.prevent="handleScan" class="scan-form">
        <div class="form-group">
          <input
            v-model="scanCode"
            type="text"
            placeholder="z.B. I123 oder QR-Token"
            class="scan-input"
          />
        </div>
        <button type="submit" class="btn-primary" :disabled="loading || !scanCode">
          <span v-if="loading">Suchen...</span>
          <span v-else>Suchen</span>
        </button>
      </form>
    </div>

    <!-- Recent Scans -->
    <div class="card recent-scans">
      <h3>Letzte Scans</h3>
      <div v-if="recentScans.length === 0" class="empty">
        Noch keine Scans durchgeführt
      </div>
      <div v-else class="scan-list">
        <div v-for="scan in recentScans" :key="scan.id" class="scan-item" @click="goToItem(scan)">
          <span class="scan-type">{{ scan.type }}</span>
          <span class="scan-name">{{ scan.name }}</span>
          <span class="scan-time">{{ formatTime(scan.time) }}</span>
        </div>
      </div>
    </div>

    <!-- Result -->
    <div v-if="result" class="result-card card">
      <div class="result-header">
        <span class="result-type">{{ result.type }}</span>
        <h2>{{ result.data.name }}</h2>
      </div>
      
      <div class="result-details">
        <div class="detail-row">
          <span class="label">ID:</span>
          <span class="value">{{ result.display_id }}</span>
        </div>
        <div v-if="result.data.category" class="detail-row">
          <span class="label">Kategorie:</span>
          <span class="value">{{ result.data.category?.name }}</span>
        </div>
        <div v-if="result.data.location" class="detail-row">
          <span class="label">Standort:</span>
          <span class="value">{{ result.data.location }}</span>
        </div>
      </div>

      <div class="result-actions">
        <router-link :to="result.url" class="btn-primary">
          Details öffnen
        </router-link>
        <router-link :to="result.editUrl" class="btn-secondary">
          Bearbeiten
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const router = useRouter()
const route = useRoute()
const toast = useToast()

const scanCode = ref('')
const loading = ref(false)
const result = ref(null)
const recentScans = ref([])

onMounted(async () => {
  // Check if token is in URL
  if (route.params.token) {
    scanCode.value = route.params.token
    await handleScan()
  }
  
  // Load recent scans from localStorage
  const saved = localStorage.getItem('recentScans')
  if (saved) {
    recentScans.value = JSON.parse(saved)
  }
})

async function handleScan() {
  if (!scanCode.value) return
  
  loading.value = true
  result.value = null
  
  try {
    // Check if it's a display ID
    const displayMatch = scanCode.value.match(/^([RBI])(\d+)$/i)
    
    if (displayMatch) {
      const type = displayMatch[1].toUpperCase()
      const id = displayMatch[2]
      await handleDisplayId(type, id)
    } else {
      // Assume it's a QR token
      const response = await api.post('/scan', { token: scanCode.value })
      result.value = formatResult(response.data.data)
      addToRecent(result.value)
    }
  } catch (error) {
    toast.error('Nicht gefunden')
  } finally {
    loading.value = false
  }
}

async function handleDisplayId(type, id) {
  let response
  
  if (type === 'I') {
    response = await api.get(`/items/${id}`)
    result.value = {
      type: 'Gegenstand',
      display_id: `I${id}`,
      data: response.data.data,
      url: `/items/${id}`,
      editUrl: `/items/${id}/edit`,
    }
  } else if (type === 'B') {
    response = await api.get(`/boxes/${id}`)
    result.value = {
      type: 'Box',
      display_id: `B${id}`,
      data: response.data.data,
      url: `/boxes/${id}`,
      editUrl: `/boxes/${id}`,
    }
  } else if (type === 'R') {
    response = await api.get(`/rooms/${id}`)
    result.value = {
      type: 'Raum',
      display_id: `R${id}`,
      data: response.data.data,
      url: `/rooms/${id}`,
      editUrl: `/rooms/${id}`,
    }
  }
  
  if (result.value) {
    result.value.name = result.value.data.name
    addToRecent(result.value)
  }
}

function formatResult(data) {
  const typeMap = {
    item: { type: 'Gegenstand', prefix: 'I' },
    box: { type: 'Box', prefix: 'B' },
    room: { type: 'Raum', prefix: 'R' },
  }
  
  const { type, prefix } = typeMap[data.type] || { type: 'Unbekannt', prefix: '' }
  
  return {
    type,
    display_id: `${prefix}${data.data.id}`,
    name: data.data.name,
    data: data.data,
    url: `/${data.type === 'item' ? 'items' : data.type === 'box' ? 'boxes' : 'rooms'}/${data.data.id}`,
    editUrl: `/${data.type === 'item' ? 'items' : data.type === 'box' ? 'boxes' : 'rooms'}/${data.data.id}/edit`,
  }
}

function addToRecent(item) {
  const scan = {
    ...item,
    id: Date.now(),
    time: new Date().toISOString(),
  }
  
  recentScans.value.unshift(scan)
  recentScans.value = recentScans.value.slice(0, 10)
  localStorage.setItem('recentScans', JSON.stringify(recentScans.value))
}

function formatTime(isoString) {
  const date = new Date(isoString)
  return date.toLocaleTimeString('de-CH', { hour: '2-digit', minute: '2-digit' })
}

function goToItem(scan) {
  router.push(scan.url)
}
</script>

<style lang="scss" scoped>
.scan-page {
  max-width: 600px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 2rem;
  
  h1 {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0 0 0.5rem;
  }
  
  p {
    color: #6b7280;
    margin: 0;
  }
}

.scan-card {
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  
  h2 {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0 0 0.5rem;
  }
  
  p {
    color: #6b7280;
    margin: 0 0 1rem;
  }
}

.scan-form {
  display: flex;
  gap: 0.75rem;
}

.scan-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 1rem;
  
  &:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }
}

.recent-scans {
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  
  h3 {
    font-size: 1rem;
    font-weight: 600;
    margin: 0 0 1rem;
  }
  
  .empty {
    color: #9ca3af;
    text-align: center;
    padding: 1rem;
  }
  
  .scan-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .scan-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.15s;
    
    &:hover {
      background: #f3f4f6;
    }
  }
  
  .scan-type {
    padding: 0.25rem 0.5rem;
    background: #dbeafe;
    color: #1e40af;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 500;
  }
  
  .scan-name {
    flex: 1;
    font-weight: 500;
  }
  
  .scan-time {
    color: #9ca3af;
    font-size: 0.875rem;
  }
}

.result-card {
  padding: 1.5rem;
  
  .result-header {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
    
    .result-type {
      padding: 0.25rem 0.75rem;
      background: #dbeafe;
      color: #1e40af;
      border-radius: 4px;
      font-size: 0.75rem;
      font-weight: 500;
    }
    
    h2 {
      font-size: 1.25rem;
      font-weight: 600;
      margin: 0;
    }
  }
  
  .result-details {
    margin-bottom: 1.5rem;
  }
  
  .detail-row {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #f3f4f6;
    
    &:last-child {
      border-bottom: none;
    }
    
    .label {
      color: #6b7280;
    }
    
    .value {
      font-weight: 500;
    }
  }
  
  .result-actions {
    display: flex;
    gap: 0.75rem;
  }
}
</style>