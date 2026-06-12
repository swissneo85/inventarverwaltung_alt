<template>
  <div class="loans-page">
    <div class="page-header">
      <h1>Ausgeliehene Gegenstände</h1>
      <p class="page-subtitle">Alle aktuell ausgeliehenen Gegenstände, gruppiert nach Person</p>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Wird geladen...</p>
    </div>

    <div v-else-if="totalCount === 0" class="empty-card">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
        <path d="M20 12V22H4V12"></path>
        <path d="M22 7H2v5h20V7z"></path>
        <path d="M12 22V7"></path>
        <path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"></path>
        <path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"></path>
      </svg>
      <p>Keine ausgeliehenen Gegenstände</p>
    </div>

    <div v-else class="groups">
      <div v-for="(groupItems, personName) in grouped" :key="personName" class="person-group card">
        <div class="person-header">
          <div class="person-avatar">{{ initials(personName) }}</div>
          <div class="person-info">
            <h2>{{ personName }}</h2>
            <span class="item-count">{{ groupItems.length }} {{ groupItems.length === 1 ? 'Gegenstand' : 'Gegenstände' }}</span>
          </div>
        </div>

        <div class="items-list">
          <div v-for="item in groupItems" :key="item.id" class="loan-item">
            <div class="item-info" @click="$router.push({ name: 'ItemDetail', params: { id: item.id } })" style="cursor:pointer">
              <span class="item-id">I{{ item.id }}</span>
              <div class="item-details">
                <h3>{{ item.name }}</h3>
                <p v-if="item.room">{{ item.room.name }}</p>
                <p v-else-if="item.box">{{ item.box.name }}</p>
                <p v-else class="no-location">Kein Standort</p>
              </div>
            </div>
            <div class="item-actions">
              <router-link :to="{ name: 'ItemDetail', params: { id: item.id } }" class="btn btn-secondary btn-sm">
                Details
              </router-link>
              <button
                v-if="canEdit"
                class="btn btn-primary btn-sm"
                :disabled="returning[item.id]"
                @click="markReturned(item)"
              >
                {{ returning[item.id] ? '...' : 'Zurückgegeben' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'

const toast = useToast()
const authStore = useAuthStore()
const canEdit = computed(() => authStore.isEditor)

const items = ref([])
const loading = ref(true)
const returning = ref({})

const grouped = computed(() => {
  const groups = {}
  items.value.forEach(item => {
    const name = item.loaned_to_person?.name || 'Unbekannt'
    if (!groups[name]) groups[name] = []
    groups[name].push(item)
  })
  return groups
})

const totalCount = computed(() => items.value.length)

function initials(name) {
  return name
    .split(' ')
    .slice(0, 2)
    .map(p => p[0]?.toUpperCase() || '')
    .join('')
}

onMounted(async () => {
  await fetchLoans()
  loading.value = false
})

async function fetchLoans() {
  try {
    const res = await api.get('/loans')
    items.value = res.data.data
  } catch {
    toast.error('Fehler beim Laden der ausgeliehenen Gegenstände')
  }
}

async function markReturned(item) {
  returning.value[item.id] = true
  try {
    await api.put(`/items/${item.id}`, { loaned_to_person_id: null })
    items.value = items.value.filter(i => i.id !== item.id)
    toast.success(`"${item.name}" als zurückgegeben markiert`)
  } catch {
    toast.error('Fehler beim Zurückgeben')
  } finally {
    returning.value[item.id] = false
  }
}
</script>

<style lang="scss" scoped>
.loans-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 1.5rem;

  h1 { font-size: 1.5rem; font-weight: 600; margin: 0 0 0.25rem; }
  .page-subtitle { color: #6b7280; margin: 0; }
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
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem 2rem;
  text-align: center;
  color: #6b7280;
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

  svg { opacity: 0.3; }
}

.groups {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.person-group {
  padding: 0;
  overflow: hidden;
}

.person-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.person-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  flex-shrink: 0;
  background: #3b82f6;
  color: white;
  border-radius: 50%;
  font-size: 0.875rem;
  font-weight: 600;
}

.person-info {
  h2 { font-size: 1rem; font-weight: 600; margin: 0 0 0.125rem; }
  .item-count { font-size: 0.8125rem; color: #6b7280; }
}

.items-list {
  display: flex;
  flex-direction: column;
}

.loan-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.875rem 1.25rem;
  border-bottom: 1px solid #f3f4f6;
  flex-wrap: wrap;

  &:last-child { border-bottom: none; }
  &:hover { background: #fafafa; }
}

.item-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  min-width: 0;
  flex: 1;
}

.item-id {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  background: #dbeafe;
  color: #1e40af;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
}

.item-details {
  min-width: 0;
  h3 { font-size: 0.9375rem; font-weight: 600; margin: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  p { font-size: 0.8125rem; color: #6b7280; margin: 0; }
  .no-location { color: #d1d5db; font-style: italic; }
}

.item-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-shrink: 0;
}

.btn-sm {
  padding: 0.4375rem 0.875rem;
  font-size: 0.8125rem;
  white-space: nowrap;
}

@media (max-width: 640px) {
  .loan-item {
    flex-direction: column;
    align-items: stretch;
  }

  .item-actions {
    flex-direction: column;
    align-items: stretch;

    .btn { width: 100%; justify-content: center; }
  }
}
</style>
