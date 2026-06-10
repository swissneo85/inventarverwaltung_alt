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

        <!-- Bilder: nur im Erstellungsmodus als Pending-Queue -->
        <div v-if="!id" class="form-group">
          <label>Bilder</label>
          <div class="pending-upload">
            <div class="upload-btns">
              <label class="btn btn-secondary upload-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                  <path d="M15 12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h1.172a3 3 0 0 0 2.12-.879l.83-.828A1 1 0 0 1 6.827 3h2.344a1 1 0 0 1 .707.293l.828.828A3 3 0 0 0 12.828 5H14a1 1 0 0 1 1 1zM2 4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-1.172a2 2 0 0 1-1.414-.586l-.828-.828A2 2 0 0 0 9.172 2H6.828a2 2 0 0 0-1.414.586l-.828.828A2 2 0 0 1 3.172 4z"/>
                  <path d="M8 11a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5m0 1a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M3 6.5a.5.5 0 1 1-1 0 .5.5 0 0 1 1 0"/>
                </svg>
                Kamera
                <input type="file" accept="image/*" capture="environment" @change="addPending" style="display:none">
              </label>
              <label class="btn btn-secondary upload-btn">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                  <path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5"/>
                  <path d="M7.646 1.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 2.707V11.5a.5.5 0 0 1-1 0V2.707L5.354 4.854a.5.5 0 1 1-.708-.708z"/>
                </svg>
                Galerie
                <input type="file" accept="image/*" multiple @change="addPending" style="display:none">
              </label>
            </div>
            <div v-if="pendingFiles.length" class="pending-grid">
              <div v-for="(pf, i) in pendingFiles" :key="i" class="pending-thumb">
                <img :src="pf.preview" :alt="pf.file.name">
                <button type="button" class="pending-remove" @click="pendingFiles.splice(i, 1)">×</button>
              </div>
            </div>
            <p v-else class="pending-hint">Fotos auswählen – werden beim Speichern hochgeladen</p>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
          <button type="submit" class="btn btn-primary" :disabled="saving">
            {{ saving ? 'Wird gespeichert...' : 'Speichern' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Bilder im Bearbeitungsmodus -->
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
const saving = ref(false)
const pendingFiles = ref([])

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

function addPending(e) {
  Array.from(e.target.files).forEach(file => {
    if (!file.type.startsWith('image/')) return
    const reader = new FileReader()
    reader.onload = ev => pendingFiles.value.push({ file, preview: ev.target.result })
    reader.readAsDataURL(file)
  })
  e.target.value = ''
}

async function compressImage(file) {
  const THRESHOLD = 500 * 1024
  if (file.size <= THRESHOLD) return file
  return new Promise(resolve => {
    const reader = new FileReader()
    reader.onload = e => {
      const img = new Image()
      img.onload = () => {
        const MAX = 1920
        let { width, height } = img
        if (width > MAX || height > MAX) {
          if (width >= height) { height = Math.round(height * MAX / width); width = MAX }
          else { width = Math.round(width * MAX / height); height = MAX }
        }
        const canvas = document.createElement('canvas')
        canvas.width = width; canvas.height = height
        canvas.getContext('2d').drawImage(img, 0, 0, width, height)
        canvas.toBlob(blob => {
          const name = file.name.replace(/\.[^.]+$/, '.jpg')
          resolve(new File([blob], name, { type: 'image/jpeg', lastModified: Date.now() }))
        }, 'image/jpeg', 0.82)
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  })
}

async function uploadPending(itemId) {
  for (const pf of pendingFiles.value) {
    try {
      const compressed = await compressImage(pf.file)
      const fd = new FormData()
      fd.append('image', compressed)
      await api.post(`/items/${itemId}/images`, fd)
    } catch (e) {
      toast.error(`Bild konnte nicht hochgeladen werden: ${pf.file.name}`)
    }
  }
}

async function save() {
  saving.value = true
  try {
    if (id) {
      await api.put(`/items/${id}`, form.value)
      toast.success('Aktualisiert')
      router.push('/items')
    } else {
      const res = await api.post('/items', form.value)
      const newId = res.data.data?.id
      if (newId && pendingFiles.value.length) {
        await uploadPending(newId)
      }
      toast.success('Erstellt')
      router.push(newId ? `/items/${newId}/edit` : '/items')
    }
  } catch (e) {
    toast.error('Fehler beim Speichern')
  } finally {
    saving.value = false
  }
}
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; font-weight: 600; }
.form-card { padding: 1.5rem; }
.form-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1.5rem; }

.pending-upload { display: flex; flex-direction: column; gap: 0.75rem; }
.upload-btns { display: flex; gap: 0.75rem; flex-wrap: wrap; }
.upload-btn {
  display: inline-flex; align-items: center; gap: 0.4rem;
  padding: 0.5rem 1rem; font-size: 0.875rem; cursor: pointer;
}
.pending-hint { font-size: 0.8rem; color: #9ca3af; margin: 0; }

.pending-grid { display: flex; flex-wrap: wrap; gap: 0.5rem; }
.pending-thumb {
  position: relative; width: 80px; height: 80px;
  border-radius: 6px; overflow: hidden;
  img { width: 100%; height: 100%; object-fit: cover; display: block; }
}
.pending-remove {
  position: absolute; top: 2px; right: 2px;
  width: 20px; height: 20px; border-radius: 50%;
  background: rgba(239,68,68,0.85); color: #fff;
  border: none; font-size: 0.75rem; cursor: pointer;
  display: flex; align-items: center; justify-content: center; padding: 0;
}

@media (max-width: 767px) {
  .form-card { padding: 1rem; }
  .upload-btns { flex-direction: row; }
  .upload-btn { flex: 1; justify-content: center; min-height: 44px; }
  .form-actions {
    flex-direction: column-reverse;
    .btn { width: 100%; justify-content: center; }
  }
}
</style>
