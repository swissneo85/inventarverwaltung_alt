<template>
  <div class="page">
    <div class="page-header">
      <h1>Boxen</h1>
      <router-link to="/inbox" class="btn btn-secondary">Inbox</router-link>
    </div>
    <div v-if="loading" class="loading">Wird geladen...</div>
    <div v-else class="grid">
      <div v-for="box in boxes" :key="box.id" class="card box-card">
        <div class="box-header">
          <span class="badge badge-primary">B{{ box.id }}</span>
          <h3>{{ box.name }}</h3>
        </div>
        <p v-if="box.room">Raum: {{ box.room.name }}</p>
        <p v-else class="muted">In Inbox</p>
        <p>{{ box.items_count || 0 }} Items</p>
        <router-link :to="`/boxes/${box.id}`" class="btn btn-secondary">Details</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'

const toast = useToast()
const boxes = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await api.get('/boxes')
    boxes.value = res.data.data?.data || res.data.data
  } catch (e) {
    toast.error('Fehler beim Laden')
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.page { max-width: 1200px; margin: 0 auto; }
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem; }
.box-card { padding: 1.25rem; }
.box-header { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem; }
.box-header h3 { font-size: 1rem; font-weight: 600; margin: 0; }
.muted { color: #6b7280; }
.loading { padding: 2rem; text-align: center; color: #6b7280; }
</style>