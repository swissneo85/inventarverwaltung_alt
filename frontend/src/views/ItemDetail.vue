<template>
  <div class="page">
    <div class="page-header">
      <h1>{{ item?.display_id }} - {{ item?.name }}</h1>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else-if="item" class="details">
      <div class="card detail-card">
        <h2>Allgemein</h2>
        <div class="detail-row"><span>Kategorie:</span><span>{{ item.category?.name || '-' }}</span></div>
        <div class="detail-row"><span>Marke:</span><span>{{ item.brand || '-' }}</span></div>
        <div class="detail-row"><span>Modell:</span><span>{{ item.model || '-' }}</span></div>
        <div class="detail-row"><span>Seriennummer:</span><span>{{ item.serial_number || '-' }}</span></div>
        <div class="detail-row"><span>Menge:</span><span>{{ item.quantity }} {{ item.unit || '' }}</span></div>
        <div class="detail-row"><span>Zustand:</span><span>{{ item.condition || '-' }}</span></div>
      </div>
      <div class="card detail-card">
        <h2>Standort</h2>
        <div class="detail-row"><span>Typ:</span><span>{{ locationText }}</span></div>
      </div>
      <div class="card detail-card">
        <ImageGallery type="items" :model-id="id" />
      </div>
      <div class="actions">
        <router-link :to="`/items/${id}/edit`" class="btn btn-primary">Bearbeiten</router-link>
        <button class="btn btn-secondary" @click="$router.back()">Zurück</button>
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
const item = ref(null)
const loading = ref(true)

const locationText = computed(() => {
  if (!item.value) return '-'
  if (item.value.is_in_inbox) return 'Inbox'
  if (item.value.box) return `Box: ${item.value.box.name}`
  if (item.value.room) return `Raum: ${item.value.room.name}`
  return '-'
})

onMounted(async () => {
  try {
    const res = await api.get(`/items/${id}`)
    item.value = res.data.data
  } catch (e) {
    toast.error('Nicht gefunden')
    router.push('/items')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 800px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.detail-card { padding: 1.5rem; margin-bottom: 1rem; }
.detail-card h2 { font-size: 1rem; font-weight: 600; margin-bottom: 1rem; }
.detail-row { display: flex; justify-content: space-between; padding: 0.5rem 0; border-bottom: 1px solid #f3f4f6; gap: 0.5rem; }
.detail-row span:first-child { color: #6b7280; flex-shrink: 0; }
.detail-row span:last-child { text-align: right; }
.actions { display: flex; gap: 1rem; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }

@media (max-width: 767px) {
  .detail-card { padding: 1rem; }
  .actions {
    flex-direction: column;
    .btn { width: 100%; justify-content: center; }
  }
}
</style>