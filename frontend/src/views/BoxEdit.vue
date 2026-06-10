<template>
  <div class="page">
    <div class="page-header">
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
          <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
      </form>
    </div>
    <div v-if="id" class="card form-card" style="margin-top:1rem">
      <ImageGallery type="boxes" :model-id="id" />
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
  } catch (e) {}
  
  if (id) {
    try {
      const res = await api.get(`/boxes/${id}`)
      form.value = res.data.data
    } catch (e) {
      toast.error('Box nicht gefunden')
      router.push('/boxes')
    }
  }
})

async function save() {
  try {
    if (id) {
      await api.put(`/boxes/${id}`, form.value)
      toast.success('Aktualisiert')
      router.push('/boxes')
    } else {
      form.value.is_in_inbox = !form.value.room_id
      const res = await api.post('/boxes', form.value)
      toast.success('Erstellt')
      const newId = res.data.data?.id
      router.push(newId ? `/boxes/${newId}/edit` : '/boxes')
    }
  } catch (e) {
    toast.error('Fehler beim Speichern')
  }
}
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.form-card { padding: 1.5rem; }
.form-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1.5rem; }

@media (max-width: 767px) {
  .form-card { padding: 1rem; }
  .form-actions {
    flex-direction: column-reverse;
    .btn { width: 100%; justify-content: center; }
  }
}
</style>