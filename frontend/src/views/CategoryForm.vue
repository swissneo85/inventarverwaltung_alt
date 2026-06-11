<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.back()">← Zurück</button>
      <h1>{{ isEdit ? 'Kategorie bearbeiten' : 'Neue Kategorie' }}</h1>
    </div>

    <div v-if="loading" class="loading">Wird geladen…</div>

    <template v-else>
      <div class="card form-card">
        <form @submit.prevent="save">
          <div class="form-group">
            <label>Name *</label>
            <input v-model="form.name" type="text" required placeholder="z.B. Elektronik, Möbel…">
          </div>
          <div class="form-group">
            <label>Beschreibung</label>
            <textarea v-model="form.description" rows="3" placeholder="Optional…"></textarea>
          </div>
          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
            <button type="submit" class="btn btn-primary" :disabled="saving || !form.name">
              {{ saving ? 'Wird gespeichert…' : (isEdit ? 'Speichern' : 'Erstellen') }}
            </button>
          </div>
        </form>
      </div>

      <!-- Delete (edit mode only) -->
      <div v-if="isEdit" class="danger-zone">
        <button type="button" class="btn-delete" @click="confirmDelete = true">🗑 Kategorie löschen</button>
      </div>
    </template>

    <!-- Delete confirmation -->
    <div v-if="confirmDelete" class="confirm-backdrop" @click.self="confirmDelete = false">
      <div class="confirm-dialog">
        <p>Kategorie <strong>{{ form.name }}</strong> wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="confirmDelete = false">Abbrechen</button>
          <button class="btn-danger" :disabled="deleting" @click="deleteCategory">
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

const route = useRoute()
const router = useRouter()
const toast = useToast()

const id = route.params.id
const isEdit = computed(() => !!id)

const saving = ref(false)
const deleting = ref(false)
const loading = ref(!!id)
const confirmDelete = ref(false)
const form = ref({ name: '', description: '' })

onMounted(async () => {
  if (!id) return
  try {
    const res = await api.get(`/categories/${id}`)
    const data = res.data.data
    form.value = { name: data.name, description: data.description || '' }
  } catch {
    toast.error('Kategorie nicht gefunden')
    router.push({ name: 'Categories' })
  } finally {
    loading.value = false
  }
})

async function save() {
  if (!form.value.name || saving.value) return
  saving.value = true
  try {
    if (isEdit.value) {
      await api.put(`/categories/${id}`, form.value)
      toast.success('Kategorie aktualisiert')
      router.push({ name: 'Categories' })
    } else {
      const res = await api.post('/categories', form.value)
      const newId = res.data.data?.id
      toast.success('Kategorie erstellt')
      const returnTo = route.query.returnTo
      if (returnTo) {
        router.push({ path: returnTo, query: { newCategoryId: newId } })
      } else {
        router.push({ name: 'Categories' })
      }
    }
  } catch {
    // interceptor shows error
  } finally {
    saving.value = false
  }
}

async function deleteCategory() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/categories/${id}`)
    toast.success('Kategorie gelöscht')
    router.push({ name: 'Categories' })
  } catch {
    // interceptor shows error
  } finally {
    deleting.value = false
    confirmDelete.value = false
  }
}
</script>

<style scoped>
.page { max-width: 700px; margin: 0 auto; }

.page-header {
  display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;
}
.page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }
.btn-back { flex-shrink: 0; }

.form-card { padding: 1.5rem; }

.form-group { margin-bottom: 1rem; }
.form-group label {
  display: block; font-size: 0.8rem; font-weight: 500; color: #374151; margin-bottom: 0.3rem;
}
.form-group input,
.form-group textarea {
  width: 100%; padding: 0.5rem 0.75rem; border: 1px solid #d1d5db; border-radius: 8px;
  font-size: 16px; background: white; font-family: inherit; box-sizing: border-box;
}
.form-group input:focus,
.form-group textarea:focus { outline: none; border-color: #3b82f6; }
.form-group textarea { resize: vertical; min-height: 70px; }

.form-actions {
  display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1.5rem;
}

.loading { padding: 2rem; text-align: center; color: #6b7280; }

.danger-zone {
  margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid #fee2e2;
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
  .form-card { padding: 1rem; }
  .form-actions { flex-direction: column-reverse; }
  .form-actions .btn { width: 100%; justify-content: center; }
}
</style>
