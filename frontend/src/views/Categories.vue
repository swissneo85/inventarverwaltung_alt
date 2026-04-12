<template>
  <div class="page">
    <div class="page-header">
      <h1>Kategorien</h1>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else class="grid">
      <div v-for="cat in categories" :key="cat.id" class="card cat-card">
        <h3>{{ cat.name }}</h3>
        <p>{{ cat.items_count || 0 }} Items</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const toast = useToast()
const categories = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get('/categories')
    categories.value = res.data.data
  } catch (e) {
    toast.error('Fehler beim Laden')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 1rem; }
.cat-card { padding: 1.25rem; }
.cat-card h3 { font-size: 1rem; font-weight: 600; margin: 0 0 0.5rem; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }
</style>