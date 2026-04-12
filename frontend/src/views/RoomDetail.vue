<template>
  <div class="page">
    <div class="page-header">
      <h1>Raum: {{ room?.name }}</h1>
      <span class="badge badge-primary">R{{ room?.id }}</span>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else-if="room">
      <div class="card section">
        <h2>Boxen ({{ room.boxes_count || 0 }})</h2>
        <div v-if="boxes.length === 0" class="empty">Keine Boxen</div>
        <div v-else class="list">
          <div v-for="box in boxes" :key="box.id" class="list-item">
            <span>B{{ box.id }}</span>
            <span>{{ box.name }}</span>
            <span>{{ box.items_count || 0 }} Items</span>
          </div>
        </div>
      </div>
      <div class="card section">
        <h2>Items ({{ room.items_count || 0 }})</h2>
        <div v-if="items.length === 0" class="empty">Keine Items</div>
        <div v-else class="list">
          <div v-for="item in items" :key="item.id" class="list-item">
            <span>I{{ item.id }}</span>
            <span>{{ item.name }}</span>
          </div>
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

const route = useRoute()
const router = useRouter()
const toast = useToast()

const room = ref(null)
const boxes = ref([])
const items = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const id = route.params.id
    const [roomRes, boxesRes, itemsRes] = await Promise.all([
      api.get(`/rooms/${id}`),
      api.get(`/rooms/${id}/boxes`),
      api.get(`/rooms/${id}/items`)
    ])
    room.value = roomRes.data.data
    boxes.value = boxesRes.data.data?.data || boxesRes.data.data
    items.value = itemsRes.data.data?.data || itemsRes.data.data
  } catch (e) {
    toast.error('Nicht gefunden')
    router.push('/rooms')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 1000px; margin: 0 auto; }
.page-header { display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.section { padding: 1.5rem; margin-bottom: 1rem; }
.section h2 { font-size: 1rem; font-weight: 600; margin-bottom: 1rem; }
.list-item { display: flex; gap: 1rem; padding: 0.75rem 0; border-bottom: 1px solid #f3f4f6; }
.list-item span:first-child { font-weight: 600; color: #3b82f6; }
.empty { color: #6b7280; text-align: center; padding: 1rem; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }
</style>