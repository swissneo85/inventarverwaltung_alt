<template>
  <div class="page">
    <div class="page-header">
      <button class="btn btn-secondary btn-back" @click="$router.back()">← Zurück</button>
      <h1>{{ isEdit ? 'Raum bearbeiten' : 'Neuer Raum' }}</h1>
    </div>

    <div v-if="loading" class="loading">Wird geladen...</div>

    <template v-else>
      <div class="card form-card">
        <form @submit.prevent="save">

          <!-- Fotos -->
          <div class="form-group">
            <label>Fotos</label>
            <template v-if="isEdit">
              <ImageGallery type="rooms" :model-id="id" />
            </template>
            <template v-else>
              <div class="pending-upload">
                <div class="upload-btns">
                  <label class="btn btn-secondary upload-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                      <circle cx="12" cy="13" r="4"/>
                    </svg>
                    Kamera
                    <input type="file" accept="image/*" capture="environment" @change="addPending" style="display:none">
                  </label>
                  <label class="btn btn-secondary upload-btn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>
                      <polyline points="21 15 16 10 5 21"/>
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
            </template>
          </div>

          <div class="form-group">
            <label>Name *</label>
            <input v-model="form.name" type="text" required placeholder="z.B. Keller, Garage, Wohnzimmer">
          </div>
          <div class="form-group">
            <label>Beschreibung</label>
            <textarea v-model="form.description" rows="3" placeholder="Optional…"></textarea>
          </div>

          <div class="form-actions">
            <button type="button" class="btn btn-secondary" @click="$router.back()">Abbrechen</button>
            <button type="submit" class="btn btn-primary" :disabled="saving || !form.name">
              {{ saving ? 'Wird gespeichert...' : (isEdit ? 'Speichern' : 'Erstellen') }}
            </button>
          </div>
        </form>
      </div>

      <!-- Delete (edit mode only) -->
      <div v-if="isEdit" class="actions">
        <button class="btn-danger" @click="confirmDelete = true">Löschen</button>
      </div>
    </template>

    <!-- Delete confirmation -->
    <div v-if="confirmDelete" class="confirm-backdrop" @click.self="confirmDelete = false">
      <div class="confirm-dialog">
        <p>Raum <strong>{{ form.name }}</strong> wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="confirmDelete = false">Abbrechen</button>
          <button class="btn-danger" :disabled="deleting" @click="deleteRoom">
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
const isEdit = computed(() => !!id)

const saving = ref(false)
const deleting = ref(false)
const loading = ref(!!id)
const confirmDelete = ref(false)
const pendingFiles = ref([])
const form = ref({ name: '', description: '' })

onMounted(async () => {
  if (!id) return
  try {
    const res = await api.get(`/rooms/${id}`)
    const data = res.data.data
    form.value = { name: data.name, description: data.description || '' }
  } catch {
    toast.error('Raum nicht gefunden')
    router.push({ name: 'Rooms' })
  } finally {
    loading.value = false
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
  if (file.size <= 500 * 1024) return file
  return new Promise(resolve => {
    const fallback = () => resolve(file)
    try {
      const reader = new FileReader()
      reader.onerror = fallback
      reader.onload = e => {
        const img = new Image()
        img.onerror = fallback
        img.onload = () => {
          try {
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
              if (!blob) { fallback(); return }
              resolve(new File([blob], file.name.replace(/\.[^.]+$/, '.jpg'), { type: 'image/jpeg', lastModified: Date.now() }))
            }, 'image/jpeg', 0.82)
          } catch { fallback() }
        }
        img.src = e.target.result
      }
      reader.readAsDataURL(file)
    } catch { fallback() }
  })
}

async function save() {
  if (!form.value.name || saving.value) return
  saving.value = true
  try {
    if (isEdit.value) {
      await api.put(`/rooms/${id}`, form.value)
      toast.success('Raum aktualisiert')
      router.push(`/rooms/${id}`)
    } else {
      const res = await api.post('/rooms', form.value)
      const newId = res.data.data?.id
      if (newId && pendingFiles.value.length) {
        for (const pf of pendingFiles.value) {
          try {
            const compressed = await compressImage(pf.file)
            const fd = new FormData()
            fd.append('image', compressed)
            await api.post(`/rooms/${newId}/images`, fd)
          } catch { /* einzelner Bild-Fehler überspringen */ }
        }
      }
      toast.success('Raum erstellt')
      const returnTo = route.query.returnTo
      if (returnTo) {
        router.push({ path: returnTo, query: { newRoomId: newId } })
      } else {
        router.push(`/rooms/${newId}`)
      }
    }
  } catch {
    // interceptor shows error
  } finally {
    saving.value = false
  }
}

async function deleteRoom() {
  if (deleting.value) return
  deleting.value = true
  try {
    await api.delete(`/rooms/${id}`)
    toast.success('Raum gelöscht')
    router.push({ name: 'Rooms' })
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
}
.pending-thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
.pending-remove {
  position: absolute; top: 2px; right: 2px;
  width: 20px; height: 20px; border-radius: 50%;
  background: rgba(239,68,68,0.85); color: #fff;
  border: none; font-size: 0.75rem; cursor: pointer;
  display: flex; align-items: center; justify-content: center; padding: 0;
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
  .upload-btns { flex-direction: row; }
  .upload-btn { flex: 1; justify-content: center; min-height: 44px; }
  .form-actions { flex-direction: column-reverse; }
  .form-actions .btn { width: 100%; justify-content: center; }
}
</style>
