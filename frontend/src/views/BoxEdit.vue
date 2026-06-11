<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.back()">← Zurück</button>
      <h1>{{ id ? 'Box bearbeiten' : 'Neue Box' }}</h1>
    </div>
    <div class="card form-card">
      <form @submit.prevent="save">
        <div class="form-group">
          <label>Name *</label>
          <input v-model="form.name" type="text" required>
        </div>
        <div class="form-group">
          <label>Beschreibung</label>
          <textarea v-model="form.description"></textarea>
        </div>
        <div class="form-group">
          <label>Raum</label>
          <select v-model="form.room_id">
            <option value="">Inbox</option>
            <option v-for="room in rooms" :key="room.id" :value="room.id">{{ room.name }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Typ</label>
          <input v-model="form.box_type" type="text" placeholder="z.B. Kiste, Regal, Schublade">
        </div>
        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
          <button type="submit" class="btn btn-primary" :disabled="saving || !form.name">
            {{ saving ? 'Wird gespeichert...' : (id ? 'Speichern' : 'Erstellen') }}
          </button>
        </div>
      </form>
    </div>
    <div v-if="id" class="card form-card" style="margin-top:1rem">
      <ImageGallery type="boxes" :model-id="id" />
    </div>

    <div v-if="id" class="actions">
      <button class="btn-danger" @click="confirmDelete = true">Löschen</button>
    </div>

    <!-- Delete confirmation -->
    <div v-if="confirmDelete" class="confirm-backdrop" @click.self="confirmDelete = false">
      <div class="confirm-dialog">
        <p>Box <strong>{{ form.name }}</strong> wirklich löschen?</p>
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

const id = route.params.id
const saving = ref(false)
const deleting = ref(false)
const confirmDelete = ref(false)
const rooms = ref([])
const form = ref({
  name: '',
  description: '',
  room_id: '',
  box_type: ''
})

onMounted(async () => {
  try {
    const res = await api.get('/rooms')
    rooms.value = res.data.data
  } catch {}

  if (id) {
    try {
      const res = await api.get(`/boxes/${id}`)
      form.value = res.data.data
    } catch {
      toast.error('Box nicht gefunden')
      router.push('/boxes')
    }
  }
})

async function deleteBox() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/boxes/${id}`)
    toast.success('Box gelöscht')
    router.push({ name: 'Boxes' })
  } catch {
    // interceptor shows error
  } finally {
    deleting.value = false
    confirmDelete.value = false
  }
}

async function save() {
  if (!form.value.name || saving.value) return
  saving.value = true
  try {
    if (id) {
      await api.put(`/boxes/${id}`, form.value)
      toast.success('Aktualisiert')
      router.push(`/boxes/${id}`)
    } else {
      form.value.is_in_inbox = !form.value.room_id
      const res = await api.post('/boxes', form.value)
      const newId = res.data.data?.id
      toast.success('Erstellt')
      const returnTo = route.query.returnTo
      if (returnTo) {
        router.push({ path: returnTo, query: { newBoxId: newId } })
      } else {
        router.push(newId ? `/boxes/${newId}` : '/boxes')
      }
    }
  } catch {
    toast.error('Fehler beim Speichern')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }

.page-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.page-header h1 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0;
}

.btn-back { flex-shrink: 0; }
.form-card { padding: 1.5rem; }

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  font-size: 0.8rem;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.3rem;
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 16px;
  background: white;
  font-family: inherit;
  box-sizing: border-box;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3b82f6;
}

.form-group textarea { resize: vertical; min-height: 60px; }

.form-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1.5rem;
}

.actions { margin-top: 1rem; }

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
  .form-actions {
    flex-direction: column-reverse;
  }
  .form-actions .btn { width: 100%; justify-content: center; }
}
</style>