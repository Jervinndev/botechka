import { ref } from 'vue'

const availableThemes = ['light', 'dark', 'system']
const theme = ref('system')
const isDark = ref(false)
let systemPreference
let isInitialized = false

function updateDomTheme() {
  const shouldUseDark =
    theme.value === 'dark' ||
    (theme.value === 'system' && systemPreference?.matches)

  isDark.value = shouldUseDark
  document.documentElement.classList.toggle('dark', shouldUseDark)
}

function applyTheme(event) {
  if (!document.startViewTransition) {
    updateDomTheme()
    return
  }

  const x = event?.clientX ?? window.innerWidth / 2
  const y = event?.clientY ?? window.innerHeight / 2
  const endRadius = Math.hypot(
    Math.max(x, window.innerWidth - x),
    Math.max(y, window.innerHeight - y)
  )

  const transition = document.startViewTransition(() => {
    updateDomTheme()
  })

  transition.ready.then(() => {
    document.documentElement.animate(
      {
        clipPath: [
          `circle(0px at ${x}px ${y}px)`,
          `circle(${endRadius}px at ${x}px ${y}px)`
        ]
      },
      {
        duration: 450,
        easing: 'ease-in-out',
        pseudoElement: '::view-transition-new(root)'
      }
    )
  })
}

function initializeTheme() {
  if (isInitialized) return

  const savedTheme = localStorage.getItem('theme')
  theme.value = availableThemes.includes(savedTheme) ? savedTheme : 'system'
  systemPreference = window.matchMedia('(prefers-color-scheme: dark)')

  systemPreference.addEventListener('change', () => {
    if (theme.value === 'system') applyTheme()
  })

  updateDomTheme()
  isInitialized = true
}

function setTheme(nextTheme, event) {
  if (!availableThemes.includes(nextTheme)) {
    throw new Error(`Unsupported theme: ${nextTheme}`)
  }

  if (!isInitialized) initializeTheme()
  theme.value = nextTheme
  localStorage.setItem('theme', nextTheme)
  applyTheme(event)
}

function toggleDark(event) {
  setTheme(isDark.value ? 'light' : 'dark', event)
}

export function useDark() {
  initializeTheme()
  return { isDark, theme, setTheme, toggleDark }
}