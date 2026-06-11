<template>
  <div class="document-gallery">

    <!-- Bestehende Dokumente -->
    <div v-if="documents.length > 0" class="document-list">
      <div v-for="doc in documents" :key="doc.id" class="document-item">
        <span class="document-icon">{{ mimeIcon(doc.mime_type) }}</span>
        <div class="document-info">
          <span class="document-name">{{ doc.name }}</span>
          <span class="document-type">{{ typeLabel(doc.type) }}</span>
        </div>
        <div class="document-actions">
          <a :href="`/storage/${doc.file_path}`" target="_blank" rel="noopener" class="btn-doc-open">
            Öffnen
          </a>
          <button v-if="!readonly" class="btn-doc-delete" title="Löschen" @click="deleteDoc(doc)">✕</button>
        </div>
      </div>
    </div>

    <p v-else-if="readonly" class="doc-empty">Keine Dokumente vorhanden</p>

    <!-- Upload -->
    <div v-if="!readonly" class="document-upload">
      <div class="upload-row">
        <select v-model="newType" class="doc-type-select">
          <option value="">Typ wählen…</option>
          <option value="quittung">Quittung</option>
          <option value="anleitung">Bedienungsanleitung</option>
          <option value="garantie">Garantieschein</option>
          <option value="foto">Foto (Typenschild/SN)</option>
          <option value="sonstiges">Sonstiges</option>
        </select>
        <label class="btn-doc-upload-label">
          📎 Dokument hinzufügen
          <input ref="fileInput" type="file" accept=".pdf,image/*" style="display:none" @change="onFileChange">
        </label>
      </div>

      <div v-if="pendingFile" class="pending-row">
        <span class="pending-name">{{ pendingFile.name }}</span>
        <button class="btn-upload-confirm" :disabled="!newType || uploading" @click="upload">
          {{ uploading ? 'Lädt…' : 'Hochladen' }}
        </button>
        <button class="btn-upload-cancel" @click="cancel">Abbrechen</button>
      </div>
      <p v-if="pendingFile && !newType" class="upload-hint">Bitte zuerst einen Typ wählen</p>
    </div>

  </div>
</template>

<script setup>
import { ref } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const props = defineProps({
  itemId:    { type: [String, Number], required: true },
  documents: { type: Array, default: () => [] },
  readonly:  { type: Boolean, default: false },
})

const emit = defineEmits(['update'])
const toast = useToast()

const newType     = ref('')
const pendingFile = ref(null)
const uploading   = ref(false)
const fileInput   = ref(null)

const TYPE_LABELS = {
  quittung:  'Quittung',
  anleitung: 'Bedienungsanleitung',
  garantie:  'Garantieschein',
  foto:      'Foto (Typenschild/SN)',
  sonstiges: 'Sonstiges',
}

function typeLabel(type) { return TYPE_LABELS[type] || type }

function mimeIcon(mime) {
  if (!mime) return '📄'
  if (mime === 'application/pdf') return '📕'
  if (mime.startsWith('image/')) return '🖼️'
  return '📄'
}

function onFileChange(e) {
  pendingFile.value = e.target.files[0] || null
  e.target.value = ''
}

function cancel() {
  pendingFile.value = null
  newType.value = ''
}

async function upload() {
  if (!pendingFile.value || !newType.value || uploading.value) return
  uploading.value = true
  try {
    const fd = new FormData()
    fd.append('file', pendingFile.value)
    fd.append('type', newType.value)
    await api.post(`/items/${props.itemId}/documents`, fd)
    pendingFile.value = null
    newType.value = ''
    emit('update')
  } catch {
    toast.error('Upload fehlgeschlagen')
  } finally {
    uploading.value = false
  }
}

async function deleteDoc(doc) {
  if (!confirm(`„${doc.name}" wirklich löschen?`)) return
  try {
    await api.delete(`/items/${props.itemId}/documents/${doc.id}`)
    emit('update')
  } catch {
    toast.error('Fehler beim Löschen')
  }
}
</script>

<style scoped>
.document-list { display: flex; flex-direction: column; }

.document-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.625rem 0;
  border-bottom: 1px solid #f3f4f6;
}
.document-item:last-child { border-bottom: none; }

.document-icon { font-size: 1.4rem; flex-shrink: 0; }

.document-info { flex: 1; min-width: 0; }
.document-name { display: block; font-size: 0.875rem; font-weight: 500; color: #111827; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.document-type { font-size: 0.75rem; color: #9ca3af; }

.document-actions { display: flex; gap: 0.375rem; align-items: center; flex-shrink: 0; }

.btn-doc-open {
  font-size: 0.8rem; padding: 0.25rem 0.625rem;
  border: 1px solid #d1d5db; border-radius: 6px;
  text-decoration: none; color: #374151; background: white;
  transition: background 0.12s;
}
.btn-doc-open:hover { background: #f9fafb; }

.btn-doc-delete {
  background: none; border: none; color: #ef4444;
  cursor: pointer; font-size: 0.9rem; padding: 0.25rem 0.375rem;
  border-radius: 4px; line-height: 1; transition: background 0.12s;
}
.btn-doc-delete:hover { background: #fee2e2; }

.doc-empty { color: #9ca3af; font-size: 0.875rem; margin: 0; }

/* Upload */
.document-upload { margin-top: 0.875rem; padding-top: 0.75rem; border-top: 1px solid #f3f4f6; }

.upload-row { display: flex; gap: 0.5rem; flex-wrap: wrap; align-items: center; }

.doc-type-select {
  padding: 0.4rem 0.625rem;
  border: 1px solid #d1d5db; border-radius: 8px;
  font-size: 0.875rem; background: white; font-family: inherit;
}

.btn-doc-upload-label {
  display: inline-flex; align-items: center; gap: 0.25rem;
  padding: 0.4rem 0.75rem;
  border: 1px dashed #d1d5db; border-radius: 8px;
  font-size: 0.875rem; color: #6b7280; cursor: pointer;
  background: white; transition: border-color 0.12s, color 0.12s;
}
.btn-doc-upload-label:hover { border-color: #3b82f6; color: #3b82f6; }

.pending-row {
  display: flex; align-items: center; gap: 0.5rem;
  margin-top: 0.5rem; flex-wrap: wrap;
}
.pending-name { font-size: 0.875rem; color: #374151; min-width: 0; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }

.btn-upload-confirm {
  padding: 0.375rem 0.875rem;
  background: #3b82f6; color: white;
  border: none; border-radius: 8px;
  font-size: 0.875rem; cursor: pointer; transition: background 0.12s;
  white-space: nowrap;
}
.btn-upload-confirm:hover:not(:disabled) { background: #2563eb; }
.btn-upload-confirm:disabled { opacity: 0.5; cursor: not-allowed; }

.btn-upload-cancel {
  padding: 0.375rem 0.75rem;
  background: white; border: 1px solid #d1d5db;
  border-radius: 8px; font-size: 0.875rem; cursor: pointer; transition: background 0.12s;
  white-space: nowrap;
}
.btn-upload-cancel:hover { background: #f9fafb; }

.upload-hint { font-size: 0.8rem; color: #ef4444; margin: 0.25rem 0 0; }
</style>
