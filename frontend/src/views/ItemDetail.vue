<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.push({ name: 'Items' })">← Zurück</button>
      <h1 v-if="item">{{ item.display_id }} – {{ item.name }}</h1>
      <h1 v-else-if="!loading">Gegenstand</h1>
      <div class="header-actions" v-if="item">
        <button class="btn btn-primary" @click="$router.push({ name: 'ItemEdit', params: { id: item.id } })">
          Bearbeiten
        </button>
      </div>
    </div>

    <div v-if="loading" class="loading">Wird geladen...</div>

    <div v-else-if="item">
      <div class="card detail-card">
        <h2>Allgemein</h2>
        <div class="detail-row"><span>Kategorie</span><span>{{ item.category?.name || '–' }}</span></div>
        <div class="detail-row"><span>Zustand</span>
          <span v-if="item.condition" :class="['condition-badge', conditionClass(item.condition)]">{{ item.condition }}</span>
          <span v-else>–</span>
        </div>
        <div class="detail-row"><span>Marke</span><span>{{ item.brand || '–' }}</span></div>
        <div class="detail-row"><span>Modell</span><span>{{ item.model || '–' }}</span></div>
        <div class="detail-row"><span>Seriennummer</span><span>{{ item.serial_number || '–' }}</span></div>
        <div class="detail-row"><span>Menge</span><span>{{ item.quantity }} {{ item.unit || '' }}</span></div>
      </div>

      <div class="card detail-card">
        <h2>Standort</h2>
        <div class="detail-row"><span>Ort</span><span>{{ locationText }}</span></div>
      </div>

      <div class="card detail-card" v-if="item.purchase_price || item.purchased_at || item.warranty_until">
        <h2>Kauf &amp; Garantie</h2>
        <div v-if="item.purchase_price" class="detail-row">
          <span>Kaufpreis</span><span>CHF {{ Number(item.purchase_price).toFixed(2) }}</span>
        </div>
        <div v-if="item.purchased_at" class="detail-row">
          <span>Kaufdatum</span><span>{{ formatDate(item.purchased_at) }}</span>
        </div>
        <div v-if="item.warranty_until" class="detail-row">
          <span>Garantie bis</span><span>{{ formatDate(item.warranty_until) }}</span>
        </div>
      </div>

      <div class="card detail-card" v-if="item.description || item.notes">
        <h2>Beschreibung &amp; Notizen</h2>
        <div v-if="item.description" class="detail-row detail-row--block">
          <span>Beschreibung</span><p>{{ item.description }}</p>
        </div>
        <div v-if="item.notes" class="detail-row detail-row--block">
          <span>Notizen</span><p>{{ item.notes }}</p>
        </div>
      </div>

      <div class="card detail-card">
        <ImageGallery type="items" :model-id="id" />
      </div>

      <div class="danger-zone">
        <button class="btn-delete" @click="confirmDelete = true">🗑 Gegenstand löschen</button>
      </div>
    </div>

    <!-- Delete confirmation -->
    <div v-if="confirmDelete" class="confirm-backdrop" @click.self="confirmDelete = false">
      <div class="confirm-dialog">
        <p>Gegenstand wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="confirmDelete = false">Abbrechen</button>
          <button class="btn btn-danger" :disabled="deleting" @click="deleteItem">
            {{ deleting ? '…' : 'Löschen' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import ImageGallery from '@/components/ImageGallery.vue'

const route = useRoute()
const router = useRouter()
const toast = useToast()

const id = route.params.id
const item = ref(null)
const loading = ref(true)
const confirmDelete = ref(false)
const deleting = ref(false)

const locationText = computed(() => {
  if (!item.value) return '–'
  if (item.value.is_in_inbox) return 'Inbox'
  if (item.value.box) return `Box: ${item.value.box.name}`
  if (item.value.room) return `Raum: ${item.value.room.name}`
  return '–'
})

function conditionClass(condition) {
  const map = { 'Neu': 'cond-new', 'Gut': 'cond-good', 'Gebraucht': 'cond-used', 'Defekt': 'cond-broken' }
  return map[condition] || 'cond-default'
}

function formatDate(val) {
  if (!val) return '–'
  return new Date(val).toLocaleDateString('de-CH')
}

async function loadItem() {
  try {
    const res = await api.get(`/items/${id}`)
    item.value = res.data.data
  } catch {
    router.push({ name: 'Items' })
  } finally {
    loading.value = false
  }
}

async function deleteItem() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/items/${id}`)
    toast.success('Gegenstand gelöscht')
    router.push({ name: 'Items' })
  } catch {
    toast.error('Fehler beim Löschen')
  } finally {
    deleting.value = false
    confirmDelete.value = false
  }
}

onMounted(loadItem)
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }

.page-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.page-header h1 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0;
  flex: 1;
}

.btn-back { flex-shrink: 0; }
.header-actions { flex-shrink: 0; }

.detail-card { padding: 1.5rem; margin-bottom: 1rem; }
.detail-card h2 { font-size: 1rem; font-weight: 600; margin: 0 0 1rem; color: #111827; }

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  padding: 0.5rem 0;
  border-bottom: 1px solid #f3f4f6;
  gap: 0.5rem;
}
.detail-row:last-child { border-bottom: none; }
.detail-row > span:first-child { color: #6b7280; font-size: 0.875rem; flex-shrink: 0; }
.detail-row > span:last-child { text-align: right; font-size: 0.875rem; }

.detail-row--block { flex-direction: column; gap: 0.25rem; }
.detail-row--block > span:first-child { font-size: 0.8rem; }
.detail-row--block p { margin: 0; font-size: 0.875rem; color: #374151; white-space: pre-wrap; }

.condition-badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 500;
}
.cond-new     { background: #d1fae5; color: #065f46; }
.cond-good    { background: #dbeafe; color: #1e40af; }
.cond-used    { background: #fef3c7; color: #92400e; }
.cond-broken  { background: #fee2e2; color: #991b1b; }
.cond-default { background: #f3f4f6; color: #6b7280; }

.loading { padding: 2rem; text-align: center; color: #6b7280; }

.danger-zone {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid #fee2e2;
}
.btn-delete {
  width: 100%; padding: 0.75rem; background: none;
  border: 1px solid #ef4444; color: #ef4444;
  border-radius: 8px; font-size: 1rem; cursor: pointer; transition: background 0.15s;
}
.btn-delete:hover { background: #fef2f2; }

.btn-danger {
  display: flex; align-items: center; justify-content: center; gap: 0.4rem;
  padding: 0.5rem 0.875rem;
  background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5;
  border-radius: 8px; font-size: 0.875rem; font-weight: 500;
  cursor: pointer; transition: background 0.15s;
}
.btn-danger:hover:not(:disabled) { background: #fecaca; }
.btn-danger:disabled { opacity: 0.5; cursor: not-allowed; }

.confirm-backdrop {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.4); z-index: 500;
  display: flex; align-items: center; justify-content: center;
}
.confirm-dialog {
  background: white; border-radius: 12px;
  padding: 1.5rem; margin: 1rem;
  text-align: center; box-shadow: 0 8px 32px rgba(0,0,0,0.2);
  min-width: 260px;
}
.confirm-dialog p { margin: 0 0 1.25rem; font-size: 1rem; font-weight: 500; color: #111827; }
.confirm-actions { display: flex; gap: 0.75rem; justify-content: center; }

@media (max-width: 767px) {
  .detail-card { padding: 1rem; }
  .page-header { flex-wrap: nowrap; }
  .page-header h1 { font-size: 1.1rem; }
  .actions { flex-direction: column; }
  .actions .btn { width: 100%; justify-content: center; }
}
</style>
