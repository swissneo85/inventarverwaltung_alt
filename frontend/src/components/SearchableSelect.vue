<template>
  <div class="searchable-select" ref="container">

    <!-- Trigger -->
    <button
      type="button"
      class="searchable-select__trigger"
      :class="{ 'is-open': isOpen }"
      @click="toggleOpen"
    >
      <span :class="{ placeholder: !selectedLabel }">{{ selectedLabel || placeholder }}</span>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="16" height="16"
        viewBox="0 0 24 24"
        fill="none" stroke="currentColor" stroke-width="2"
        class="searchable-select__arrow"
        :class="{ rotated: isOpen }"
      >
        <polyline points="6 9 12 15 18 9"/>
      </svg>
    </button>

    <!-- Dropdown Panel -->
    <div v-if="isOpen" class="searchable-select__panel">

      <!-- Suchfeld -->
      <div class="searchable-select__search">
        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          ref="searchInput"
          v-model="searchQuery"
          type="text"
          placeholder="Suchen..."
          @keydown.escape="close"
          @keydown.enter.prevent="selectFirst"
        />
      </div>

      <!-- Optionen-Liste -->
      <ul class="searchable-select__list" role="listbox">
        <li
          v-for="option in filteredOptions"
          :key="option.value"
          class="searchable-select__option"
          :class="{ 'is-selected': option.value === modelValue }"
          role="option"
          :aria-selected="option.value === modelValue"
          @mousedown.prevent="select(option)"
        >
          {{ option.label }}
        </li>

        <li v-if="filteredOptions.length === 0" class="searchable-select__empty">
          Keine Ergebnisse
        </li>
      </ul>

      <!-- "Neu anlegen"-Button -->
      <div v-if="createRoute" class="searchable-select__footer">
        <button
          type="button"
          class="searchable-select__create-btn"
          @mousedown.prevent="navigateToCreate"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
          </svg>
          {{ createLabel }}
        </button>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: null
  },
  options: {
    type: Array,
    required: true
  },
  placeholder: {
    type: String,
    default: 'Bitte wählen...'
  },
  createRoute: {
    type: String,
    default: null
  },
  createLabel: {
    type: String,
    default: 'Neu anlegen'
  },
  returnField: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'before-navigate'])
const router = useRouter()
const route = useRoute()

const isOpen = ref(false)
const searchQuery = ref('')
const container = ref(null)
const searchInput = ref(null)

const selectedLabel = computed(() => {
  const found = props.options.find(o => o.value === props.modelValue)
  return found?.value !== '' && found?.value != null ? found.label : null
})

const filteredOptions = computed(() => {
  if (!searchQuery.value) return props.options
  const q = searchQuery.value.toLowerCase()
  return props.options.filter(o => o.label.toLowerCase().includes(q))
})

function toggleOpen() {
  isOpen.value ? close() : open()
}

function open() {
  isOpen.value = true
  searchQuery.value = ''
  nextTick(() => searchInput.value?.focus())
}

function close() {
  isOpen.value = false
  searchQuery.value = ''
}

function select(option) {
  emit('update:modelValue', option.value)
  close()
}

function selectFirst() {
  if (filteredOptions.value.length > 0) {
    select(filteredOptions.value[0])
  }
}

function navigateToCreate() {
  close()
  emit('before-navigate')
  const returnTo = props.returnField
    ? route.fullPath + (route.fullPath.includes('?') ? '&' : '?') + 'returnField=' + props.returnField
    : route.fullPath
  router.push({
    name: props.createRoute,
    query: { returnTo }
  })
}

function handleClickOutside(event) {
  if (container.value && !container.value.contains(event.target)) {
    close()
  }
}

onMounted(() => document.addEventListener('mousedown', handleClickOutside))
onUnmounted(() => document.removeEventListener('mousedown', handleClickOutside))
</script>

<style scoped>
.searchable-select {
  position: relative;
  width: 100%;
}

.searchable-select__trigger {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  background: white;
  cursor: pointer;
  text-align: left;
  font-size: 16px;
  font-family: inherit;
  color: #111827;
  transition: border-color 0.15s;
  box-sizing: border-box;
  min-height: 38px;
}

.searchable-select__trigger:hover {
  border-color: #9ca3af;
}

.searchable-select__trigger.is-open {
  border-color: #3b82f6;
  outline: none;
}

.searchable-select__trigger .placeholder {
  color: #9ca3af;
}

.searchable-select__arrow {
  flex-shrink: 0;
  color: #9ca3af;
  transition: transform 0.2s;
}

.searchable-select__arrow.rotated {
  transform: rotate(180deg);
}

.searchable-select__panel {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  left: auto;
  min-width: max(200px, 100%);
  z-index: 100;
  background: white;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  overflow: hidden;
}

.searchable-select__search {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid #f3f4f6;
  background: #fafafa;
}

.searchable-select__search svg {
  color: #9ca3af;
  flex-shrink: 0;
}

.searchable-select__search input {
  flex: 1;
  border: none;
  background: transparent;
  outline: none;
  font-size: 0.9rem;
  font-family: inherit;
  color: #111827;
}

.searchable-select__list {
  list-style: none;
  margin: 0;
  padding: 0.25rem 0;
  max-height: 200px;
  overflow-y: auto;
}

.searchable-select__option {
  padding: 0.5rem 0.75rem;
  cursor: pointer;
  font-size: 0.9rem;
  color: #374151;
  transition: background 0.1s;
}

.searchable-select__option:hover {
  background: #f3f4f6;
}

.searchable-select__option.is-selected {
  background: #eff6ff;
  color: #1d4ed8;
  font-weight: 500;
}

.searchable-select__empty {
  padding: 0.625rem 0.75rem;
  color: #9ca3af;
  font-size: 0.875rem;
  text-align: center;
}

.searchable-select__footer {
  border-top: 1px solid #f3f4f6;
  padding: 0.375rem 0.5rem;
}

.searchable-select__create-btn {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 0.375rem;
  padding: 0.5rem 0.5rem;
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 0.875rem;
  font-family: inherit;
  cursor: pointer;
  text-align: left;
  border-radius: 6px;
  transition: background 0.1s;
}

.searchable-select__create-btn:hover {
  background: #eff6ff;
}

@media (max-width: 767px) {
  .searchable-select__trigger {
    min-height: 44px;
  }

  .searchable-select__option {
    padding: 0.625rem 0.75rem;
    min-height: 44px;
    display: flex;
    align-items: center;
  }

  .searchable-select__create-btn {
    min-height: 44px;
  }
}
</style>
