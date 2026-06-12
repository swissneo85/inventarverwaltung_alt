<template>
  <div class="page">
    <div class="page-header">
      <h1>Einstellungen</h1>
    </div>

    <!-- Profil -->
    <div class="card form-card">
      <h2>Profil</h2>
      <form @submit.prevent="saveProfile">
        <div class="form-group">
          <label>Name</label>
          <input v-model="profile.name" type="text" />
        </div>
        <div class="form-group">
          <label>E-Mail</label>
          <input v-model="profile.email" type="email" placeholder="optional" />
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="savingProfile">
            {{ savingProfile ? 'Wird gespeichert…' : 'Speichern' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Passwort ändern -->
    <div class="card form-card" style="margin-top: 1.5rem;">
      <h2>Passwort ändern</h2>
      <form @submit.prevent="changePassword">
        <div class="form-group">
          <label>Aktuelles Passwort *</label>
          <input v-model="pw.current_password" type="password" required autocomplete="current-password" />
        </div>
        <div class="form-group">
          <label>Neues Passwort *</label>
          <input v-model="pw.password" type="password" required placeholder="Mindestens 8 Zeichen" autocomplete="new-password" />
        </div>
        <div class="form-group">
          <label>Neues Passwort bestätigen *</label>
          <input v-model="pw.password_confirmation" type="password" required autocomplete="new-password" />
          <p v-if="pwMismatch" class="field-error">Passwörter stimmen nicht überein.</p>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="savingPw || pwMismatch">
            {{ savingPw ? 'Wird gespeichert…' : 'Passwort ändern' }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useToast } from 'vue-toastification'
import { useAuthStore } from '@/stores/auth'

const toast = useToast()
const authStore = useAuthStore()

const profile = ref({ name: '', email: '' })
const savingProfile = ref(false)

const pw = ref({ current_password: '', password: '', password_confirmation: '' })
const savingPw = ref(false)

const pwMismatch = computed(() =>
  !!pw.value.password && pw.value.password !== pw.value.password_confirmation
)

onMounted(() => {
  if (authStore.user) {
    profile.value.name = authStore.user.name
    profile.value.email = authStore.user.email || ''
  }
})

async function saveProfile() {
  if (savingProfile.value) return
  savingProfile.value = true
  try {
    const res = await api.put('/profile', { name: profile.value.name, email: profile.value.email || null })
    authStore.user = res.data.data
    toast.success('Profil gespeichert')
  } catch {
    // interceptor shows error
  } finally {
    savingProfile.value = false
  }
}

async function changePassword() {
  if (savingPw.value || pwMismatch.value) return
  savingPw.value = true
  try {
    await api.put('/profile', {
      current_password: pw.value.current_password,
      password: pw.value.password,
      password_confirmation: pw.value.password_confirmation,
    })
    toast.success('Passwort geändert')
    pw.value = { current_password: '', password: '', password_confirmation: '' }
  } catch {
    // interceptor shows error
  } finally {
    savingPw.value = false
  }
}
</script>

<style scoped>
.page { max-width: 600px; margin: 0 auto; }
.page-header { margin-bottom: 1.5rem; }
.page-header h1 { font-size: 1.5rem; font-weight: 600; margin: 0; }

.form-card { padding: 1.5rem; }
.form-card h2 { font-size: 1rem; font-weight: 600; margin: 0 0 1rem; color: #374151; }

.form-group { margin-bottom: 1rem; }
.form-group label {
  display: block; font-size: 0.8rem; font-weight: 500; color: #374151; margin-bottom: 0.3rem;
}
.form-group input {
  width: 100%; padding: 0.5rem 0.75rem; border: 1px solid #d1d5db; border-radius: 8px;
  font-size: 16px; background: white; font-family: inherit; box-sizing: border-box;
}
.form-group input:focus { outline: none; border-color: #3b82f6; }

.field-error { font-size: 0.75rem; color: #dc2626; margin: 0.2rem 0 0; }

.form-actions { display: flex; justify-content: flex-end; margin-top: 1.25rem; }
</style>
