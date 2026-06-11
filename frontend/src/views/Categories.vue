<template>
  <div class="categories-page">
    <div class="page-header">
      <h1>Kategorien</h1>
      <button class="btn btn-primary" @click="$router.push({ name: 'CategoryCreate' })">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
        Neue Kategorie
      </button>
    </div>

    <div v-if="loading" class="empty-state">Wird geladen…</div>

    <div v-else-if="categories.length === 0" class="empty-state">
      <p>Noch keine Kategorien vorhanden.</p>
      <button class="btn btn-primary" @click="$router.push({ name: 'CategoryCreate' })">Erste Kategorie anlegen</button>
    </div>

    <div v-else class="list-card card">
      <div
        v-for="cat in categories"
        :key="cat.id"
        class="cat-row"
        @click="$router.push({ name: 'CategoryEdit', params: { id: cat.id } })"
      >
        <div class="cat-info">
          <span class="cat-name">{{ cat.name }}</span>
          <span v-if="cat.description" class="cat-desc">{{ cat.description }}</span>
        </div>
        <span class="cat-count">{{ cat.items_count ?? 0 }} Items</span>
        <div class="cat-actions" @click.stop>
          <button
            class="row-btn"
            title="Bearbeiten"
            @click="$router.push({ name: 'CategoryEdit', params: { id: cat.id } })"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
              <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
            </svg>
          </button>
          <button
            class="row-btn row-btn--danger"
            title="Löschen"
            @click="confirmDelete(cat)"
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="3 6 5 6 21 6"/>
              <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
              <path d="M10 11v6"/><path d="M14 11v6"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Delete confirmation -->
    <div v-if="deleteTarget" class="confirm-backdrop" @click.self="deleteTarget = null">
      <div class="confirm-dialog">
        <p>Kategorie <strong>{{ deleteTarget.name }}</strong> wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="deleteTarget = null">Abbrechen</button>
          <button class="btn-danger" :disabled="deleting" @click="doDelete">
            {{ deleting ? '…' : 'Löschen' }}
          </button>
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
const categories = ref([])
const loading = ref(true)
const deleteTarget = ref(null)
const deleting = ref(false)

async function load() {
  try {
    const res = await api.get('/categories')
    categories.value = res.data.data
  } catch {
    toast.error('Fehler beim Laden')
  } finally {
    loading.value = false
  }
}

onMounted(load)

function confirmDelete(cat) {
  deleteTarget.value = cat
}

async function doDelete() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/categories/${deleteTarget.value.id}`)
    toast.success('Kategorie gelöscht')
    categories.value = categories.value.filter(c => c.id !== deleteTarget.value.id)
    deleteTarget.value = null
  } catch {
    // interceptor shows error
  } finally {
    deleting.value = false
  }
}
</script>

<style scoped>
.categories-page { max-width: 800px; margin: 0 auto; }

.page-header {
  display: flex; align-items: center; justify-content: space-between; margin-bottom: 1.5rem;
  h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
}

.empty-state {
  padding: 3rem; text-align: center; color: #6b7280;
  display: flex; flex-direction: column; align-items: center; gap: 1rem;
  p { margin: 0; }
}

.list-card { overflow: hidden; }

.cat-row {
  display: flex; align-items: center; gap: 1rem; padding: 0.875rem 1rem;
  border-bottom: 1px solid #f3f4f6; cursor: pointer; transition: background 0.12s;
  &:last-child { border-bottom: none; }
  &:hover { background: #f9fafb; }
}

.cat-info { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 0.1rem; }
.cat-name { font-weight: 600; font-size: 0.9rem; color: #111827; }
.cat-desc { font-size: 0.78rem; color: #9ca3af; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

.cat-count { font-size: 0.78rem; color: #6b7280; white-space: nowrap; }

.cat-actions { display: flex; gap: 0.25rem; }

.row-btn {
  display: flex; align-items: center; justify-content: center;
  width: 30px; height: 30px; border: none; background: none;
  border-radius: 6px; color: #9ca3af; cursor: pointer; transition: all 0.15s;
  &:hover { background: #eff6ff; color: #3b82f6; }
}
.row-btn--danger:hover { background: #fee2e2 !important; color: #dc2626 !important; }

.btn-danger {
  display: inline-flex; align-items: center; gap: 0.4rem;
  padding: 0.5rem 0.875rem; background: #fee2e2; color: #991b1b;
  border: 1px solid #fca5a5; border-radius: 8px; font-size: 0.875rem;
  font-weight: 500; cursor: pointer; transition: background 0.15s;
  &:hover:not(:disabled) { background: #fecaca; }
  &:disabled { opacity: 0.5; cursor: not-allowed; }
}

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
</style>
