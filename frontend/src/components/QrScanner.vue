<template>
  <div class="qr-scanner">
    <div v-if="scanning" class="scanner-container">
      <video ref="videoEl" autoplay playsinline class="scanner-video"></video>
      <canvas ref="canvasEl" class="scanner-canvas"></canvas>

      <div class="scanner-overlay">
        <div class="scanner-frame"></div>
        <p class="scanner-hint">QR-Code in den Rahmen halten</p>
      </div>

      <button type="button" @click="stopScanning" class="btn-stop-scan">✕</button>
    </div>

    <button v-else type="button" @click="startScanning" class="btn-start-scan">
      📷 Kamera starten
    </button>

    <p v-if="error" class="scan-error">{{ error }}</p>
  </div>
</template>

<script setup>
import { ref, onUnmounted, nextTick } from 'vue'
import jsQR from 'jsqr'

const emit = defineEmits(['scanned'])

const scanning = ref(false)
const videoEl = ref(null)
const canvasEl = ref(null)
const error = ref('')
let stream = null
let animationFrame = null

async function startScanning() {
  error.value = ''
  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'environment' }
    })
    scanning.value = true
    await nextTick()
    videoEl.value.srcObject = stream
    videoEl.value.play()
    animationFrame = requestAnimationFrame(scan)
  } catch {
    error.value = 'Kamera-Zugriff verweigert. Bitte Berechtigung erteilen.'
  }
}

function scan() {
  if (!scanning.value) return
  const video = videoEl.value
  const canvas = canvasEl.value
  if (!video || !canvas || video.readyState !== video.HAVE_ENOUGH_DATA) {
    animationFrame = requestAnimationFrame(scan)
    return
  }
  canvas.width = video.videoWidth
  canvas.height = video.videoHeight
  const ctx = canvas.getContext('2d')
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height)
  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
  const code = jsQR(imageData.data, imageData.width, imageData.height)
  if (code) {
    stopScanning()
    emit('scanned', code.data)
    return
  }
  animationFrame = requestAnimationFrame(scan)
}

function stopScanning() {
  scanning.value = false
  if (stream) {
    stream.getTracks().forEach(t => t.stop())
    stream = null
  }
  if (animationFrame) {
    cancelAnimationFrame(animationFrame)
    animationFrame = null
  }
}

onUnmounted(stopScanning)
</script>

<style scoped>
.scanner-container {
  position: relative;
  width: 100%;
  max-width: 400px;
  margin: 0 auto;
}

.scanner-video {
  width: 100%;
  border-radius: 0.5rem;
  display: block;
}

.scanner-canvas {
  display: none;
}

.scanner-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.scanner-frame {
  width: 200px;
  height: 200px;
  border: 3px solid #3b82f6;
  border-radius: 0.5rem;
  box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.4);
}

.scanner-hint {
  color: white;
  margin-top: 1rem;
  font-size: 0.875rem;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.8);
}

.btn-stop-scan {
  position: absolute;
  top: 0.5rem;
  right: 0.5rem;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 2rem;
  height: 2rem;
  cursor: pointer;
  font-size: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-start-scan {
  width: 100%;
  padding: 1rem;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.15s;
}

.btn-start-scan:hover {
  background: #2563eb;
}

.scan-error {
  margin-top: 0.75rem;
  color: #dc2626;
  font-size: 0.875rem;
}
</style>
