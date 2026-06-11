<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.push({ name: 'Boxes' })">← Zurück</button>
      <h1 v-if="box">{{ box.name }}</h1>
      <div class="header-actions" v-if="box">
        <router-link :to="`/boxes/${box.id}/edit`" class="btn btn-primary">Bearbeiten</router-link>
      </div>
    </div>

    <div v-if="loading" class="loading">Wird geladen...</div>

    <template v-else-if="box">
      <!-- Details -->
      <div class="card detail-card">
        <h2>Details</h2>
        <div class="detail-row"><span>ID</span><span class="id-badge">B{{ box.id }}</span></div>
        <div class="detail-row"><span>Raum</span><span>{{ box.room?.name || 'Inbox' }}</span></div>
        <div v-if="box.box_type" class="detail-row"><span>Typ</span><span>{{ box.box_type }}</span></div>
        <div v-if="box.description" class="detail-row detail-row--block">
          <span>Beschreibung</span><p>{{ box.description }}</p>
        </div>
        <div class="detail-row">
          <span>Items</span><span>{{ box.items_count ?? items.length }}</span>
        </div>
      </div>

      <!-- Images -->
      <div class="card detail-card">
        <h2>Bilder</h2>
        <ImageGallery type="boxes" :model-id="box.id" />
      </div>

      <!-- Items -->
      <div class="card detail-card" v-if="items.length > 0">
        <h2>Items ({{ items.length }})</h2>
        <div class="sub-list">
          <router-link v-for="item in items" :key="item.id" :to="`/items/${item.id}`" class="sub-item">
            <span class="sub-id">{{ item.display_id || 'I' + item.id }}</span>
            <span class="sub-name">{{ item.name }}</span>
            <span v-if="item.category" class="sub-meta">{{ item.category.name }}</span>
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="sub-chevron">
              <polyline points="9 18 15 12 9 6"></polyline>
            </svg>
          </router-link>
        </div>
      </div>

      <!-- Delete -->
      <div class="danger-zone">
        <button class="btn-delete" @click="confirmDelete = true">🗑 Box löschen</button>
      </div>
    </template>

    <!-- Delete confirmation -->
    <div v-if="confirmDelete" class="confirm-backdrop" @click.self="confirmDelete = false">
      <div class="confirm-dialog">
        <p>Box <strong>{{ box?.name }}</strong> wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="confirmDelete = false">Abbrechen</button>
          <button class="btn-danger" :disabled="deleting" @click="deleteBox">
            {{ deleting ? '…' : 'Löschen' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import ImageGallery from '@/components/ImageGallery.vue'

const route = useRoute()
const router = useRouter()
const toast = useToast()

const box = ref(null)
const items = ref([])
const loading = ref(true)
const confirmDelete = ref(false)
const deleting = ref(false)

onMounted(async () => {
  const id = route.params.id
  try {
    const [boxRes, itemsRes] = await Promise.all([
      api.get(`/boxes/${id}`),
      api.get(`/boxes/${id}/items`)
    ])
    box.value = boxRes.data.data
    items.value = itemsRes.data.data?.data || itemsRes.data.data
  } catch {
    router.push({ name: 'Boxes' })
  } finally {
    loading.value = false
  }
})

async function deleteBox() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/boxes/${box.value.id}`)
    toast.success('Box gelöscht')
    router.push({ name: 'Boxes' })
  } catch {
    // interceptor shows error
  } finally {
    deleting.value = false
    confirmDelete.value = false
  }
}
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }

.page-header {
  display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap;
}
.page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; flex: 1; }
.btn-back { flex-shrink: 0; }
.header-actions { flex-shrink: 0; }

.detail-card { padding: 1.5rem; margin-bottom: 1rem; }
.detail-card h2 { font-size: 1rem; font-weight: 600; margin: 0 0 1rem; color: #111827; }

.detail-row {
  display: flex; justify-content: space-between; align-items: baseline;
  padding: 0.5rem 0; border-bottom: 1px solid #f3f4f6; gap: 0.5rem;
  &:last-child { border-bottom: none; }
  & > span:first-child { color: #6b7280; font-size: 0.875rem; flex-shrink: 0; }
  & > span:last-child { font-size: 0.875rem; text-align: right; }
}
.detail-row--block { flex-direction: column; gap: 0.25rem; }
.detail-row--block p { margin: 0; font-size: 0.875rem; color: #374151; white-space: pre-wrap; }

.id-badge { font-size: 0.8rem; font-weight: 600; color: #7c3aed; background: #f5f3ff; padding: 0.1rem 0.5rem; border-radius: 99px; }

.sub-list { display: flex; flex-direction: column; }
.sub-item {
  display: flex; align-items: center; gap: 0.75rem;
  padding: 0.625rem 0; border-bottom: 1px solid #f3f4f6; text-decoration: none; color: inherit;
  &:last-child { border-bottom: none; }
  &:hover { background: #f9fafb; margin: 0 -1.5rem; padding: 0.625rem 1.5rem; }
}
.sub-id { font-size: 0.75rem; font-weight: 600; color: #3b82f6; flex-shrink: 0; min-width: 36px; }
.sub-name { flex: 1; font-size: 0.875rem; font-weight: 500; color: #111827; }
.sub-meta { font-size: 0.75rem; color: #9ca3af; flex-shrink: 0; }
.sub-chevron { color: #d1d5db; flex-shrink: 0; }

.danger-zone {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #fee2e2;
}
.btn-delete {
  width: 100%; padding: 0.75rem; background: none;
  border: 1px solid #ef4444; color: #ef4444;
  border-radius: 8px; font-size: 1rem; cursor: pointer; transition: background 0.15s;
  &:hover { background: #fef2f2; }
}

.btn-danger {
  display: inline-flex; align-items: center; gap: 0.4rem;
  padding: 0.5rem 0.875rem; background: #fee2e2; color: #991b1b;
  border: 1px solid #fca5a5; border-radius: 8px; font-size: 0.875rem;
  font-weight: 500; cursor: pointer; transition: background 0.15s;
  &:hover:not(:disabled) { background: #fecaca; }
  &:disabled { opacity: 0.5; cursor: not-allowed; }
}

.loading { padding: 2rem; text-align: center; color: #6b7280; }

.confirm-backdrop {
  position: fixed; inset: 0; background: rgba(0,0,0,0.4); z-index: 500;
  display: flex; align-items: center; justify-content: center;
}
.confirm-dialog {
  background: white; border-radius: 12px; padding: 1.5rem; margin: 1rem;
  min-width: 280px; text-align: center; box-shadow: 0 8px 32px rgba(0,0,0,0.2);
  p { margin: 0 0 1.25rem; font-size: 1rem; color: #111827; }
}
.confirm-actions { display: flex; gap: 0.75rem; justify-content: center; }

@media (max-width: 767px) {
  .detail-card { padding: 1rem; }
  .sub-item:hover { margin: 0 -1rem; padding: 0.625rem 1rem; }
}
</style>
