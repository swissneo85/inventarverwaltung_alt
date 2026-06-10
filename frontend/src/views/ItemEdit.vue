<template>
  <div class="page">
    <div class="page-header">
      <h1>{{ id ? 'Gegenstand bearbeiten' : 'Neuer Gegenstand' }}</h1>
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
          <label>Kategorie</label>
          <select v-model="form.category_id">
            <option value="">Keine</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
          </select>
        </div>
        <div class="form-group">
          <label>Marke</label>
          <input v-model="form.brand" type="text">
        </div>
        <div class="form-group">
          <label>Modell</label>
          <input v-model="form.model" type="text">
        </div>
        <div class="form-group">
          <label>Seriennummer</label>
          <input v-model="form.serial_number" type="text">
        </div>
        <div class="form-group">
          <label>Menge</label>
          <input v-model="form.quantity" type="number" step="0.01">
        </div>
        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
          <button type="submit" class="btn btn-primary">Speichern</button>
        </div>
      </form>
    </div>
    <div v-if="id" class="card form-card" style="margin-top:1rem">
      <ImageGallery type="items" :model-id="id" />
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
const categories = ref([])
const form = ref({
  name: '',
  description: '',
  category_id: '',
  brand: '',
  model: '',
  serial_number: '',
  quantity: 1
})

onMounted(async () => {
  try {
    const res = await api.get('/categories')
    categories.value = res.data.data
  } catch (e) {}
  
  if (id) {
    try {
      const res = await api.get(`/items/${id}`)
      form.value = res.data.data
    } catch (e) {
      toast.error('Item nicht gefunden')
      router.push('/items')
    }
  }
})

async function save() {
  try {
    if (id) {
      await api.put(`/items/${id}`, form.value)
      toast.success('Aktualisiert')
      router.push('/items')
    } else {
      const res = await api.post('/items', form.value)
      toast.success('Erstellt')
      const newId = res.data.data?.id
      router.push(newId ? `/items/${newId}/edit` : '/items')
    }
  } catch (e) {
    toast.error('Fehler beim Speichern')
  }
}
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; font-weight: 600; }
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