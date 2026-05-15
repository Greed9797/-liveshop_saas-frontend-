import { create } from 'zustand'

export type ThemeMode = 'light' | 'dark'

const themeStorageKey = 'livelab-theme'

function isThemeMode(value: unknown): value is ThemeMode {
  return value === 'light' || value === 'dark'
}

function readStoredTheme(): ThemeMode {
  if (typeof window === 'undefined') return 'light'

  try {
    const value = window.localStorage.getItem(themeStorageKey)
    return isThemeMode(value) ? value : 'light'
  } catch {
    return 'light'
  }
}

function writeStoredTheme(theme: ThemeMode) {
  if (typeof window === 'undefined') return

  try {
    window.localStorage.setItem(themeStorageKey, theme)
  } catch {
    // Theme persistence is a convenience; the in-memory state still updates.
  }
}

interface ThemeState {
  theme: ThemeMode
  setTheme: (theme: ThemeMode) => void
  toggleTheme: () => void
}

export const useThemeStore = create<ThemeState>((set, get) => ({
  theme: readStoredTheme(),
  setTheme: (theme) => {
    writeStoredTheme(theme)
    set({ theme })
  },
  toggleTheme: () => {
    const theme = get().theme === 'light' ? 'dark' : 'light'
    writeStoredTheme(theme)
    set({ theme })
  },
}))
