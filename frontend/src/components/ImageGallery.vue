<template>
  <div
    class="image-gallery"
    v-if="!props.readonly || images.length > 0"
    @dragover.prevent="!props.readonly && (isDragging = true)"
    @dragleave.self="isDragging = false"
    @drop.prevent="!props.readonly && onDrop($event)"
  >
    <div class="gallery-header">
      <div v-if="!props.readonly" class="upload-buttons">
        <label class="btn btn-secondary btn-sm" title="Kamera">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
            <path d="M15 12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h1.172a3 3 0 0 0 2.12-.879l.83-.828A1 1 0 0 1 6.827 3h2.344a1 1 0 0 1 .707.293l.828.828A3 3 0 0 0 12.828 5H14a1 1 0 0 1 1 1zM2 4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-1.172a2 2 0 0 1-1.414-.586l-.828-.828A2 2 0 0 0 9.172 2H6.828a2 2 0 0 0-1.414.586l-.828.828A2 2 0 0 1 3.172 4z"/>
            <path d="M8 11a2.5 2.5 0 1 1 0-5 2.5 2.5 0 0 1 0 5m0 1a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7M3 6.5a.5.5 0 1 1-1 0 .5.5 0 0 1 1 0"/>
          </svg>
          Kamera
          <input type="file" accept="image/*" capture="environment" @change="onFileChange" class="hidden-input">
        </label>
        <label class="btn btn-secondary btn-sm" title="Datei auswählen">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
            <path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5"/>
            <path d="M7.646 1.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 2.707V11.5a.5.5 0 0 1-1 0V2.707L5.354 4.854a.5.5 0 1 1-.708-.708z"/>
          </svg>
          Galerie
          <input type="file" accept="image/*" multiple @change="onFileChange" class="hidden-input">
        </label>
      </div>
    </div>

    <!-- Edit mode: drop zone with full controls -->
    <div
      v-if="!props.readonly && (images.length > 0 || isDragging)"
      class="drop-zone"
      :class="{ 'drag-over': isDragging }"
      @dragover.prevent="isDragging = true"
      @dragleave="isDragging = false"
      @drop.prevent="onDrop"
    >
      <div class="image-grid">
        <div
          v-for="(image, index) in images"
          :key="image.id"
          class="image-item"
          :class="{ 'is-cover': index === 0 }"
        >
          <img :src="image.url" :alt="image.filename" @click="openLightbox(index)">
          <div v-if="index === 0" class="cover-badge">Titelbild</div>
          <div class="image-actions">
            <button v-if="index > 0" class="action-btn" title="Nach links" @click="moveImage(index, -1)">&#8592;</button>
            <button v-if="index < images.length - 1" class="action-btn" title="Nach rechts" @click="moveImage(index, 1)">&#8594;</button>
            <button class="action-btn action-btn--delete" title="Löschen" @click="confirmDelete(image)">&#10005;</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Readonly mode: plain image grid, no controls -->
    <div v-else-if="props.readonly" class="image-grid image-grid--readonly">
      <div
        v-for="(image, index) in images"
        :key="image.id"
        class="image-item"
        :class="{ 'is-cover': index === 0 }"
      >
        <img :src="image.url" :alt="image.filename" @click="openLightbox(index)">
        <div v-if="index === 0" class="cover-badge">Titelbild</div>
      </div>
    </div>

    <div v-if="error" class="error-message">{{ error }}</div>
    <div v-if="uploading" class="uploading">Wird hochgeladen...</div>

    <!-- Lightbox -->
    <div v-if="lightboxIndex !== null" class="lightbox" @click.self="closeLightbox">
      <button class="lightbox-close" @click="closeLightbox">&#10005;</button>
      <button v-if="lightboxIndex > 0" class="lightbox-nav lightbox-nav--prev" @click="lightboxIndex--">&#8592;</button>
      <img :src="images[lightboxIndex]?.url" :alt="images[lightboxIndex]?.filename" class="lightbox-img">
      <button v-if="lightboxIndex < images.length - 1" class="lightbox-nav lightbox-nav--next" @click="lightboxIndex++">&#8594;</button>
    </div>

    <!-- Delete confirmation -->
    <div v-if="deleteTarget" class="lightbox" @click.self="deleteTarget = null">
      <div class="confirm-dialog">
        <p>Bild wirklich löschen?</p>
        <div class="confirm-actions">
          <button class="btn btn-secondary" @click="deleteTarget = null">Abbrechen</button>
          <button class="btn btn-danger" @click="deleteImage">Löschen</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const props = defineProps({
  type: { type: String, required: true },
  modelId: { type: [String, Number], required: true },
  readonly: { type: Boolean, default: false }
})

const emit = defineEmits(['loaded'])

const toast = useToast()
const images = ref([])
const uploading = ref(false)
const isDragging = ref(false)
const lightboxIndex = ref(null)
const deleteTarget = ref(null)
const error = ref('')

const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/heic', 'image/heif']
const MAX_SIZE = 15 * 1024 * 1024
const TARGET_MAX_DIM = 1920
const TARGET_QUALITY = 0.82
const COMPRESS_THRESHOLD = 500 * 1024

async function compressImage(file) {
  if (file.size <= COMPRESS_THRESHOLD) return file
  return new Promise((resolve) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        let { width, height } = img
        if (width > TARGET_MAX_DIM || height > TARGET_MAX_DIM) {
          if (width >= height) {
            height = Math.round(height * TARGET_MAX_DIM / width)
            width = TARGET_MAX_DIM
          } else {
            width = Math.round(width * TARGET_MAX_DIM / height)
            height = TARGET_MAX_DIM
          }
        }
        const canvas = document.createElement('canvas')
        canvas.width = width
        canvas.height = height
        canvas.getContext('2d').drawImage(img, 0, 0, width, height)
        canvas.toBlob(
          (blob) => {
            const name = file.name.replace(/\.[^.]+$/, '.jpg')
            resolve(new File([blob], name, { type: 'image/jpeg', lastModified: Date.now() }))
          },
          'image/jpeg',
          TARGET_QUALITY
        )
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  })
}

async function fetchImages() {
  try {
    const res = await api.get(`/${props.type}/${props.modelId}/images`)
    images.value = res.data.data
  } catch (e) {
    toast.error('Bilder konnten nicht geladen werden')
  } finally {
    emit('loaded', images.value.length)
  }
}

async function uploadFiles(files) {
  error.value = ''
  for (const file of files) {
    const mimeOk = ALLOWED_TYPES.includes(file.type) || file.type.startsWith('image/')
    if (!mimeOk) {
      error.value = `Ungültiges Dateiformat: ${file.name}. Erlaubt: JPEG, PNG, GIF, WebP`
      continue
    }
    if (file.size > MAX_SIZE) {
      error.value = `Datei zu gross: ${file.name}. Maximal 15 MB erlaubt.`
      continue
    }

    uploading.value = true
    try {
      const compressed = await compressImage(file)
      const formData = new FormData()
      formData.append('image', compressed)
      const res = await api.post(`/${props.type}/${props.modelId}/images`, formData)
      images.value.push(res.data.data)
    } catch (e) {
      toast.error(`Fehler beim Hochladen von ${file.name}`)
    } finally {
      uploading.value = false
    }
  }
}

function onFileChange(e) {
  uploadFiles(Array.from(e.target.files))
  e.target.value = ''
}

function onDrop(e) {
  isDragging.value = false
  const files = Array.from(e.dataTransfer.files).filter(f => f.type.startsWith('image/'))
  if (files.length) uploadFiles(files)
}

async function moveImage(index, direction) {
  const newIndex = index + direction
  if (newIndex < 0 || newIndex >= images.value.length) return

  const arr = [...images.value]
  ;[arr[index], arr[newIndex]] = [arr[newIndex], arr[index]]
  images.value = arr

  try {
    await api.post(`/${props.type}/${props.modelId}/images/reorder`, {
      order: arr.map(img => img.id)
    })
  } catch (e) {
    toast.error('Reihenfolge konnte nicht gespeichert werden')
    await fetchImages()
  }
}

function confirmDelete(image) {
  deleteTarget.value = image
}

async function deleteImage() {
  if (!deleteTarget.value) return
  try {
    await api.delete(`/images/${deleteTarget.value.id}`)
    images.value = images.value.filter(img => img.id !== deleteTarget.value.id)
    toast.success('Bild gelöscht')
  } catch (e) {
    toast.error('Fehler beim Löschen')
  } finally {
    deleteTarget.value = null
  }
}

function openLightbox(index) {
  lightboxIndex.value = index
}

function closeLightbox() {
  lightboxIndex.value = null
}

onMounted(fetchImages)
</script>

<style scoped>
.image-gallery { margin-top: 1.5rem; }
.gallery-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.75rem; }
.gallery-header h3 { font-size: 1rem; font-weight: 600; margin: 0; }
.upload-buttons { display: flex; gap: 0.5rem; }
.btn-sm { padding: 0.3rem 0.6rem; font-size: 0.8rem; display: inline-flex; align-items: center; gap: 0.3rem; cursor: pointer; }
.hidden-input { display: none; }

.drop-zone {
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  padding: 1rem;
  min-height: 120px;
  transition: border-color 0.2s, background 0.2s;
}
.drop-zone.drag-over { border-color: #3b82f6; background: #eff6ff; }

.image-grid { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.image-grid--readonly { margin-top: 0; }

.image-item {
  position: relative;
  width: 120px;
  height: 120px;
  border-radius: 6px;
  overflow: hidden;
  border: 2px solid transparent;
  cursor: pointer;
}
.image-item.is-cover { border-color: #3b82f6; }
.image-item img { width: 100%; height: 100%; object-fit: cover; display: block; }

.cover-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  background: #3b82f6;
  color: #fff;
  font-size: 0.65rem;
  padding: 2px 6px;
  border-radius: 4px;
  pointer-events: none;
}

.image-actions {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  justify-content: center;
  gap: 4px;
  background: rgba(0,0,0,0.5);
  padding: 4px;
  opacity: 0;
  transition: opacity 0.15s;
}
.image-item:hover .image-actions { opacity: 1; }

.action-btn {
  background: rgba(255,255,255,0.85);
  border: none;
  border-radius: 4px;
  width: 24px;
  height: 24px;
  font-size: 0.75rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}
.action-btn--delete { background: rgba(239,68,68,0.85); color: #fff; }

.error-message { color: #ef4444; font-size: 0.85rem; margin-top: 0.5rem; }
.uploading { color: #6b7280; font-size: 0.85rem; margin-top: 0.5rem; }

.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.8);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lightbox-img { max-width: 90vw; max-height: 90vh; object-fit: contain; border-radius: 4px; }
.lightbox-close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(255,255,255,0.2);
  border: none;
  color: #fff;
  font-size: 1.5rem;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lightbox-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255,255,255,0.2);
  border: none;
  color: #fff;
  font-size: 2rem;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}
.lightbox-nav--prev { left: 1rem; }
.lightbox-nav--next { right: 1rem; }

.confirm-dialog {
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
  min-width: 280px;
}
.confirm-dialog p { margin-bottom: 1.5rem; font-size: 1rem; }
.confirm-actions { display: flex; gap: 1rem; justify-content: center; }
.btn-danger { background: #ef4444; color: #fff; border: none; padding: 0.5rem 1.25rem; border-radius: 6px; cursor: pointer; }
</style>
