import { ref } from 'vue'

const availableThemes = ['light', 'dark', 'system']
const theme = ref('system')
const isDark = ref(false)
let systemPreference
let isInitialized = false

function applyTheme() {
  const shouldUseDark = theme.value === 'dark'
    || (theme.value === 'system' && systemPreference.matches)
  isDark.value = shouldUseDark
  document.documentElement.classList.toggle('dark', shouldUseDark)
}

function initializeTheme() {
  if (isInitialized) return

  const savedTheme = localStorage.getItem('theme')
  theme.value = availableThemes.includes(savedTheme) ? savedTheme : 'system'
  systemPreference = window.matchMedia('(prefers-color-scheme: dark)')
  systemPreference.addEventListener('change', () => {
    if (theme.value === 'system') applyTheme()
  })
  applyTheme()
  isInitialized = true
}

function setTheme(nextTheme) {
  if (!availableThemes.includes(nextTheme)) {
    throw new Error(`Unsupported theme: ${nextTheme}`)
  }

  if (!isInitialized) initializeTheme()
  theme.value = nextTheme
  localStorage.setItem('theme', nextTheme)
  applyTheme()
}

function toggleDark() {
  setTheme(isDark.value ? 'light' : 'dark')
}

export function useDark() {
  initializeTheme()
  return { isDark, theme, setTheme, toggleDark }
}