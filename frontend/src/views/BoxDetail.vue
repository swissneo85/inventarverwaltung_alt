<template>
  <div class="page">
    <div class="page-header">
      <h1>Box: {{ box?.name }}</h1>
      <span class="badge badge-primary">B{{ box?.id }}</span>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else-if="box">
      <div class="card section">
        <h2>Details</h2>
        <div class="detail-row"><span>Raum:</span><span>{{ box.room?.name || 'Inbox' }}</span></div>
        <div class="detail-row"><span>Beschreibung:</span><span>{{ box.description || '-' }}</span></div>
      </div>
      <div class="card section">
        <h2>Items ({{ box.items_count || 0 }})</h2>
        <div v-if="items.length === 0" class="empty">Keine Items</div>
        <div v-else class="list">
          <div v-for="item in items" :key="item.id" class="list-item">
            <span>I{{ item.id }}</span>
            <span>{{ item.name }}</span>
            <router-link :to="`/items/${item.id}`" class="btn btn-secondary">Details</router-link>
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

const box = ref(null)
const items = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const id = route.params.id
    const [boxRes, itemsRes] = await Promise.all([
      api.get(`/boxes/${id}`),
      api.get(`/boxes/${id}/items`)
    ])
    box.value = boxRes.data.data
    items.value = itemsRes.data.data?.data || itemsRes.data.data
  } catch (e) {
    toast.error('Nicht gefunden')
    router.push('/boxes')
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
.detail-row { display: flex; justify-content: space-between; padding: 0.5rem 0; border-bottom: 1px solid #f3f4f6; }
.detail-row span:first-child { color: #6b7280; }
.list-item { display: flex; align-items: center; gap: 1rem; padding: 0.75rem 0; border-bottom: 1px solid #f3f4f6; }
.list-item span:first-child { font-weight: 600; color: #3b82f6; }
.empty { color: #6b7280; text-align: center; padding: 1rem; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }
</style>