<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.back()">← Zurück</button>
      <h1>Neuer Raum</h1>
    </div>

    <div class="card form-card">
      <form @submit.prevent="save">
        <div class="form-group">
          <label>Name *</label>
          <input v-model="form.name" type="text" required placeholder="z.B. Keller, Garage, Wohnzimmer">
        </div>
        <div class="form-group">
          <label>Beschreibung</label>
          <textarea v-model="form.description" rows="2" placeholder="Optional…"></textarea>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
          <button type="submit" class="btn btn-primary" :disabled="saving || !form.name">
            {{ saving ? 'Wird erstellt...' : 'Erstellen' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const route = useRoute()
const router = useRouter()
const toast = useToast()

const saving = ref(false)
const form = ref({ name: '', description: '' })

async function save() {
  if (!form.value.name || saving.value) return
  saving.value = true
  try {
    const res = await api.post('/rooms', form.value)
    const newId = res.data.data?.id
    toast.success('Raum erstellt')
    const returnTo = route.query.returnTo
    if (returnTo) {
      router.push({ path: returnTo, query: { newRoomId: newId } })
    } else {
      router.push({ name: 'Rooms' })
    }
  } catch {
    toast.error('Fehler beim Erstellen')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.page { max-width: 600px; margin: 0 auto; }

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

@media (max-width: 767px) {
  .form-card { padding: 1rem; }
  .form-actions {
    flex-direction: column-reverse;
  }
  .form-actions .btn { width: 100%; justify-content: center; }
}
</style>
