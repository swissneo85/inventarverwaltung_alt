<template>
  <div class="items-page">
    <div class="page-header">
      <h1>Gegenstände</h1>
      <button class="btn btn-primary" @click="openCreate">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Neuer Gegenstand
      </button>
    </div>
    
    <!-- Filters -->
    <div class="filters-card card">
      <div class="filters-row">
        <div class="search-field">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"></circle>
            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Suchen..."
            @input="handleSearch"
          />
        </div>
        
        <select v-model="filters.category_id" @change="fetchItems" class="filter-select">
          <option value="">Alle Kategorien</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>
        
        <select v-model="filters.room_id" @change="fetchItems" class="filter-select">
          <option value="">Alle Räume</option>
          <option v-for="room in rooms" :key="room.id" :value="room.id">
            {{ room.name }}
          </option>
        </select>
        
        <button @click="showFilters = !showFilters" class="btn-secondary">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
          </svg>
          Filter
        </button>
      </div>
      
      <div v-if="showFilters" class="filters-expanded">
        <label class="filter-checkbox">
          <input type="checkbox" v-model="filters.in_inbox" @change="fetchItems">
          Nur Inbox
        </label>
        
        <label class="filter-checkbox">
          <input type="checkbox" v-model="filters.warranty_expiring" @change="fetchItems">
          Garantie läuft ab
        </label>
      </div>
    </div>
    
    <!-- View Toggle -->
    <div class="view-toggle">
      <button :class="['toggle-btn', { active: viewMode === 'list' }]" @click="viewMode = 'list'" title="Listenansicht">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line>
          <line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line>
        </svg>
        Liste
      </button>
      <button :class="['toggle-btn', { active: viewMode === 'gallery' }]" @click="viewMode = 'gallery'" title="Galerieansicht">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect>
        </svg>
        Galerie
      </button>
      <button :class="['toggle-btn', { active: viewMode === 'table' }]" @click="viewMode = 'table'" title="Tabellenansicht">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
          <line x1="3" y1="9" x2="21" y2="9"></line><line x1="3" y1="15" x2="21" y2="15"></line><line x1="9" y1="3" x2="9" y2="21"></line>
        </svg>
        Tabelle
      </button>
    </div>
    
    <!-- Results -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Wird geladen...</p>
    </div>
    
    <div v-else-if="items.length === 0" class="empty-state">
      <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
      </svg>
      <h3>Keine Gegenstände gefunden</h3>
      <p>Legen Sie Ihren ersten Gegenstand an</p>
      <router-link to="/items/create" class="btn-primary">
        Neuer Gegenstand
      </router-link>
    </div>
    
    <!-- List View -->
    <div v-else-if="viewMode === 'list'" class="items-list">
      <ItemCard v-for="item in items" :key="item.id" :item="item" />
    </div>

    <!-- Gallery View -->
    <div v-else-if="viewMode === 'gallery'" class="items-gallery">
      <router-link
        v-for="item in items"
        :key="item.id"
        :to="`/items/${item.id}`"
        class="gallery-card"
      >
        <div class="gallery-img-wrap">
          <img v-if="item.cover_image" :src="item.cover_image.url" :alt="item.name" class="gallery-img">
          <div v-else class="gallery-placeholder">
            <span>{{ item.display_id || 'I' + item.id }}</span>
          </div>
        </div>
        <div class="gallery-info">
          <div class="gallery-id">{{ item.display_id || 'I' + item.id }}</div>
          <div class="gallery-name">{{ item.name }}</div>
          <div v-if="item.category" class="gallery-cat">{{ item.category.name }}</div>
          <div class="gallery-loc">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle>
            </svg>
            {{ getLocationText(item) }}
          </div>
        </div>
      </router-link>
    </div>

    <!-- Table View -->
    <div v-else class="table-card">
      <!-- Desktop table -->
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th style="width:56px"></th>
              <th>Gegenstand</th>
              <th>Kategorie</th>
              <th>Standort</th>
              <th>Zustand</th>
              <th style="width:80px"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in items" :key="item.id" class="table-row">
              <td class="td-thumb">
                <div class="row-thumb">
                  <img v-if="item.cover_image" :src="item.cover_image.url" :alt="item.name" class="row-thumb-img">
                  <span v-else class="row-thumb-id">{{ item.display_id || 'I' + item.id }}</span>
                </div>
              </td>
              <td class="td-main">
                <router-link :to="`/items/${item.id}`" class="row-name">{{ item.name }}</router-link>
                <span class="row-id">{{ item.display_id || 'I' + item.id }}</span>
              </td>
              <td>
                <span v-if="item.category" class="chip">{{ item.category.name }}</span>
                <span v-else class="muted">—</span>
              </td>
              <td class="td-loc">{{ getLocationText(item) || '—' }}</td>
              <td>
                <span v-if="item.condition" :class="['condition-badge', conditionClass(item.condition)]">{{ item.condition }}</span>
                <span v-else class="muted">—</span>
              </td>
              <td class="td-actions">
                <router-link :to="`/items/${item.id}`" class="row-btn" title="Details">
                  <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle>
                  </svg>
                </router-link>
                <router-link :to="`/items/${item.id}/edit`" class="row-btn" title="Bearbeiten">
                  <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                  </svg>
                </router-link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <!-- Mobile card-stack (replaces table on small screens) -->
      <div class="mobile-stack">
        <router-link
          v-for="item in items"
          :key="'ms-' + item.id"
          :to="`/items/${item.id}`"
          class="mobile-row"
        >
          <div class="mobile-row-thumb">
            <img v-if="item.cover_image" :src="item.cover_image.url" :alt="item.name" class="row-thumb-img">
            <span v-else class="row-thumb-id">{{ item.display_id || 'I' + item.id }}</span>
          </div>
          <div class="mobile-row-body">
            <div class="mobile-row-name">{{ item.name }}</div>
            <div class="mobile-row-meta">
              <span class="row-id">{{ item.display_id || 'I' + item.id }}</span>
              <span v-if="item.category" class="chip">{{ item.category.name }}</span>
              <span v-if="item.condition" :class="['condition-badge', conditionClass(item.condition)]">{{ item.condition }}</span>
            </div>
            <div v-if="getLocationText(item)" class="mobile-row-loc">{{ getLocationText(item) }}</div>
          </div>
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="mobile-row-chevron">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        </router-link>
      </div>
    </div>
    
    <!-- Pagination -->
    <div v-if="pagination.last_page > 1" class="pagination">
      <button
        class="btn-secondary"
        :disabled="pagination.current_page === 1"
        @click="changePage(pagination.current_page - 1)"
      >
        Zurück
      </button>
      <span class="page-info">
        Seite {{ pagination.current_page }} von {{ pagination.last_page }}
      </span>
      <button
        class="btn-secondary"
        :disabled="pagination.current_page === pagination.last_page"
        @click="changePage(pagination.current_page + 1)"
      >
        Weiter
      </button>
    </div>

    <!-- ── Create Modal ── -->
    <Teleport to="body">
      <div v-if="createModal.show" class="modal-backdrop" @click.self="closeCreate">
        <div class="modal-sheet">
          <div class="modal-header">
            <span class="modal-title">Neuer Gegenstand</span>
            <button class="modal-close" @click="closeCreate">
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>

          <div class="modal-body">
            <!-- Photo row -->
            <div class="photo-row">
              <div class="photo-previews">
                <div v-for="(pf, i) in createModal.pendingFiles" :key="i" class="photo-thumb">
                  <img :src="pf.preview" alt="">
                  <button type="button" class="photo-remove" @click="createModal.pendingFiles.splice(i,1)">×</button>
                </div>
                <label class="photo-add-btn">
                  <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2v11z"></path>
                    <circle cx="12" cy="13" r="4"></circle>
                  </svg>
                  <span>Foto</span>
                  <input type="file" accept="image/*" capture="environment" @change="addPhoto" style="display:none">
                </label>
                <label class="photo-add-btn">
                  <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/>
                    <polyline points="21 15 16 10 5 21"/>
                  </svg>
                  <span>Galerie</span>
                  <input type="file" accept="image/*" multiple @change="addPhoto" style="display:none">
                </label>
              </div>
            </div>

            <div class="form-group">
              <label>Name *</label>
              <input v-model="createModal.form.name" type="text" placeholder="z.B. Laptop, Stuhl..." required autofocus>
            </div>
            <div class="form-group">
              <label>Kategorie</label>
              <select v-model="createModal.form.category_id">
                <option value="">Keine</option>
                <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
              </select>
            </div>
            <div class="form-group">
              <label>Beschreibung</label>
              <textarea v-model="createModal.form.description" rows="2" placeholder="Optional..."></textarea>
            </div>
          </div>

          <div class="modal-footer">
            <button class="btn btn-secondary" @click="closeCreate">Abbrechen</button>
            <button class="btn btn-primary" :disabled="createModal.saving || !createModal.form.name" @click="saveCreate">
              {{ createModal.saving ? 'Wird gespeichert…' : 'Speichern' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useItemsStore } from '@/stores/items'
import api from '@/services/api'
import ItemCard from '@/components/ItemCard.vue'
import { useToast } from 'vue-toastification'
import { debounce } from 'lodash'

const STORAGE_KEY = 'items-view-mode'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const itemsStore = useItemsStore()

const items = ref([])
const categories = ref([])
const rooms = ref([])
const loading = ref(false)
const showFilters = ref(false)
const viewMode = ref(localStorage.getItem(STORAGE_KEY) || 'list')
watch(viewMode, val => localStorage.setItem(STORAGE_KEY, val))
const searchQuery = ref('')
const filters = ref({
  category_id: '',
  room_id: '',
  in_inbox: false,
  warranty_expiring: false,
})

const pagination = ref({
  current_page: 1,
  last_page: 1,
  total: 0,
  per_page: 50,
})

onMounted(async () => {
  try {
    const [catRes, roomRes] = await Promise.all([
      api.get('/categories'),
      api.get('/rooms'),
    ])
    categories.value = catRes.data.data
    rooms.value = roomRes.data.data
  } catch (error) {
    console.error('Fehler beim Laden:', error)
  }

  await fetchItems()

  // Auto-open modal when navigating from Dashboard (?new=1)
  if (route.query.new) {
    openCreate()
    router.replace({ path: '/items' })
  }
})

const handleSearch = debounce(() => {
  fetchItems()
}, 300)

async function fetchItems() {
  loading.value = true
  
  try {
    const params = {
      ...filters.value,
      search: searchQuery.value || undefined,
      page: pagination.value.current_page,
      per_page: pagination.value.per_page,
    }
    
    // Remove empty filters
    Object.keys(params).forEach(key => {
      if (params[key] === '' || params[key] === false || params[key] === undefined) {
        delete params[key]
      }
    })
    
    const response = await api.get('/items', { params })
    items.value = response.data.data.data || response.data.data
    
    if (response.data.data.meta) {
      pagination.value = {
        current_page: response.data.data.meta.current_page,
        last_page: response.data.data.meta.last_page,
        total: response.data.data.meta.total,
        per_page: response.data.data.meta.per_page,
      }
    }
  } catch (error) {
    console.error('Fehler beim Laden:', error)
  } finally {
    loading.value = false
  }
}

function changePage(page) {
  pagination.value.current_page = page
  fetchItems()
}

function getLocationText(item) {
  if (item.is_in_inbox) return 'Inbox'
  if (item.box) return item.box.name ? `${item.box.name}` : `B${item.box.id}`
  if (item.room) return item.room.name ? `${item.room.name}` : `R${item.room.id}`
  return ''
}

function conditionClass(condition) {
  const map = { 'Neu': 'cond-new', 'Gut': 'cond-good', 'Gebraucht': 'cond-used', 'Defekt': 'cond-broken' }
  return map[condition] || 'cond-default'
}

// ── Create Modal ──
const createModal = ref({
  show: false,
  saving: false,
  pendingFiles: [],
  form: { name: '', description: '', category_id: '' }
})

function openCreate() {
  createModal.value = { show: true, saving: false, pendingFiles: [], form: { name: '', description: '', category_id: '' } }
}

function closeCreate() {
  if (createModal.value.saving) return
  createModal.value.show = false
}

function addPhoto(e) {
  Array.from(e.target.files).forEach(file => {
    if (!file.type.startsWith('image/')) return
    const reader = new FileReader()
    reader.onload = ev => createModal.value.pendingFiles.push({ file, preview: ev.target.result })
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

async function saveCreate() {
  if (!createModal.value.form.name || createModal.value.saving) return
  createModal.value.saving = true
  try {
    const res = await api.post('/items', createModal.value.form)
    const newId = res.data.data?.id
    if (newId && createModal.value.pendingFiles.length) {
      for (const pf of createModal.value.pendingFiles) {
        try {
          const compressed = await compressImage(pf.file)
          const fd = new FormData()
          fd.append('image', compressed)
          await api.post(`/items/${newId}/images`, fd)
        } catch { /* einzelner Bild-Fehler überspringen */ }
      }
    }
    toast.success('Gegenstand erstellt')
    await fetchItems()
  } catch {
    toast.error('Fehler beim Speichern')
  } finally {
    createModal.value.show = false   // immer schliessen
    createModal.value.saving = false
  }
}
</script>

<style lang="scss" scoped>
.items-page {
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.5rem;
  
  h1 {
    font-size: 1.5rem;
    font-weight: 600;
    margin: 0;
  }
}

.filters-card {
  padding: 1rem;
  margin-bottom: 1.5rem;
}

.filters-row {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.search-field {
  flex: 1;
  min-width: 200px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  background: #f3f4f6;
  border-radius: 8px;
  
  svg {
    color: #9ca3af;
    flex-shrink: 0;
  }
  
  input {
    flex: 1;
    border: none;
    background: transparent;
    outline: none;
    font-size: 0.875rem;
  }
}

.filter-select {
  padding: 0.5rem 0.75rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 0.875rem;
  background: white;
  cursor: pointer;
  
  &:focus {
    outline: none;
    border-color: #3b82f6;
  }
}

.filters-expanded {
  display: flex;
  gap: 1.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.filter-checkbox {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  cursor: pointer;
}

.view-toggle {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.toggle-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border: 1px solid #e5e7eb;
  background: white;
  border-radius: 8px;
  font-size: 0.875rem;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
  
  &.active {
    background: #3b82f6;
    border-color: #3b82f6;
    color: white;
  }
  
  &:hover:not(.active) {
    background: #f3f4f6;
  }
}

.items-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.items-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 1rem;
}

.gallery-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  text-decoration: none;
  color: inherit;
  transition: box-shadow 0.2s, transform 0.2s;
  display: flex;
  flex-direction: column;

  &:hover {
    box-shadow: 0 6px 16px rgba(0,0,0,0.12);
    transform: translateY(-2px);
  }
}

.gallery-img-wrap {
  width: 100%;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  background: #f3f4f6;
}

.gallery-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.gallery-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #dbeafe;

  span {
    font-size: 1.1rem;
    font-weight: 700;
    color: #3b82f6;
  }
}

.gallery-info {
  padding: 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
  flex: 1;
}

.gallery-id {
  font-size: 0.7rem;
  font-weight: 600;
  color: #3b82f6;
}

.gallery-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1f2937;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.gallery-cat {
  font-size: 0.75rem;
  color: #6b7280;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.gallery-loc {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  font-size: 0.75rem;
  color: #9ca3af;
  margin-top: auto;
  padding-top: 0.25rem;
}

.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  text-align: center;
  
  svg {
    color: #d1d5db;
    margin-bottom: 1rem;
  }
  
  h3 {
    font-size: 1.125rem;
    font-weight: 600;
    margin: 0 0 0.5rem;
  }
  
  p {
    color: #6b7280;
    margin: 0 0 1rem;
  }
}

.spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.table-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
  overflow: hidden;
}

.table-container {
  overflow-x: auto;
}

.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;

  thead tr {
    background: #f9fafb;
    border-bottom: 1px solid #e5e7eb;
  }

  th {
    padding: 0.75rem 1rem;
    text-align: left;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: #9ca3af;
    white-space: nowrap;
  }

  td {
    padding: 0.75rem 1rem;
    vertical-align: middle;
    border-bottom: 1px solid #f3f4f6;
  }

  .table-row {
    transition: background 0.12s;
    &:last-child td { border-bottom: none; }
    &:hover { background: #f9fafb; }
  }
}

.td-thumb { padding: 0.5rem 0.5rem 0.5rem 1rem; }

.row-thumb {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  overflow: hidden;
  background: #dbeafe;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.row-thumb-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.row-thumb-id {
  font-size: 0.65rem;
  font-weight: 700;
  color: #3b82f6;
}

.td-main {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  min-width: 160px;
}

.row-name {
  font-weight: 600;
  color: #111827;
  text-decoration: none;
  &:hover { color: #3b82f6; }
}

.row-id {
  font-size: 0.7rem;
  color: #9ca3af;
  font-weight: 500;
}

.chip {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  background: #f3f4f6;
  color: #374151;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
}

.muted { color: #d1d5db; }

.td-loc { color: #6b7280; white-space: nowrap; }

.condition-badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  border-radius: 99px;
  font-size: 0.75rem;
  font-weight: 500;
}
.cond-new     { background: #d1fae5; color: #065f46; }
.cond-good    { background: #dbeafe; color: #1e40af; }
.cond-used    { background: #fef3c7; color: #92400e; }
.cond-broken  { background: #fee2e2; color: #991b1b; }
.cond-default { background: #f3f4f6; color: #6b7280; }

.td-actions {
  white-space: nowrap;
  display: flex;
  gap: 0.25rem;
  align-items: center;
}

.row-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 6px;
  color: #9ca3af;
  text-decoration: none;
  transition: all 0.15s;
  &:hover { background: #eff6ff; color: #3b82f6; }
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-top: 1.5rem;
}

.page-info {
  font-size: 0.875rem;
  color: #6b7280;
}

/* Mobile card-stack – hidden on desktop */
.mobile-stack { display: none; }

@media (max-width: 767px) {
  .page-header {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }

  .filters-row {
    flex-direction: column;
  }

  .filter-select {
    width: 100%;
    min-height: 44px;
    font-size: 16px;
  }

  .search-field input {
    font-size: 16px;
    min-height: 36px;
  }

  .toggle-btn {
    padding: 0.5rem 0.625rem;
    font-size: 0.8rem;
    gap: 0.35rem;
  }

  /* table → hidden on mobile, card-stack shown */
  .table-container { display: none; }
  .mobile-stack { display: flex; flex-direction: column; }

  .mobile-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.875rem 1rem;
    border-bottom: 1px solid #f3f4f6;
    text-decoration: none;
    color: inherit;
    min-height: 64px;

    &:last-child { border-bottom: none; }
    &:active { background: #f9fafb; }
  }

  .mobile-row-thumb {
    width: 44px;
    height: 44px;
    border-radius: 8px;
    overflow: hidden;
    background: #dbeafe;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }

  .mobile-row-body {
    flex: 1;
    min-width: 0;
  }

  .mobile-row-name {
    font-weight: 600;
    font-size: 0.9rem;
    color: #111827;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .mobile-row-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 0.35rem;
    margin-top: 0.2rem;
  }

  .mobile-row-loc {
    font-size: 0.75rem;
    color: #9ca3af;
    margin-top: 0.15rem;
  }

  .mobile-row-chevron {
    color: #d1d5db;
    flex-shrink: 0;
  }

  /* Gallery shrinks gracefully */
  .items-gallery {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  }
}

/* ── Create Modal ── */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  z-index: 500;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-sheet {
  background: white;
  border-radius: 16px;
  width: 100%;
  max-width: 480px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,0.25);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem 1.25rem 0;
  flex-shrink: 0;
}

.modal-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: #111827;
}

.modal-close {
  width: 36px; height: 36px;
  border: none; background: #f3f4f6; border-radius: 8px;
  color: #6b7280; cursor: pointer; display: flex; align-items: center; justify-content: center;
  &:hover { background: #e5e7eb; }
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 1rem 1.25rem;
}

.modal-footer {
  padding: 1rem 1.25rem;
  border-top: 1px solid #f3f4f6;
  display: flex;
  gap: 0.75rem;
  flex-shrink: 0;

  .btn { flex: 1; justify-content: center; }
}

/* Photo strip */
.photo-row { margin-bottom: 1rem; }

.photo-previews {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.photo-thumb {
  position: relative;
  width: 72px; height: 72px;
  border-radius: 8px; overflow: hidden;
  img { width: 100%; height: 100%; object-fit: cover; display: block; }
}

.photo-remove {
  position: absolute; top: 2px; right: 2px;
  width: 20px; height: 20px; border-radius: 50%;
  background: rgba(239,68,68,0.85); color: #fff;
  border: none; font-size: 0.8rem; cursor: pointer;
  display: flex; align-items: center; justify-content: center; padding: 0;
}

.photo-add-btn {
  width: 72px; height: 72px;
  border: 2px dashed #d1d5db;
  border-radius: 8px;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 4px; cursor: pointer; color: #6b7280; font-size: 0.7rem;
  transition: border-color 0.15s, color 0.15s;
  &:hover { border-color: #3b82f6; color: #3b82f6; }
}

/* Mobile: full-width bottom sheet */
@media (max-width: 767px) {
  .modal-backdrop {
    align-items: flex-end;
  }
  .modal-sheet {
    border-radius: 20px 20px 0 0;
    max-height: 92vh;
    max-width: 100%;
  }
  .modal-header { padding: 1rem 1rem 0; }
  .modal-body { padding: 1rem; }
  .modal-footer { padding: 1rem; padding-bottom: calc(1rem + env(safe-area-inset-bottom, 0px)); }
}
</style>