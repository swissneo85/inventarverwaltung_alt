import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'

export function useAuth() {
  const authStore = useAuthStore()
  const isAdmin = computed(() => authStore.isAdmin)
  const canEdit = computed(() => authStore.isEditor)
  const canDelete = computed(() => authStore.isAdmin)
  return { isAdmin, canEdit, canDelete }
}
