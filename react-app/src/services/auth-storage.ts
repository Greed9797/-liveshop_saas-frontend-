import type { Session, User } from '../types/models'

const accessKey = 'livelab.react.access_token'
const refreshKey = 'livelab.react.refresh_token'
const userKey = 'livelab.react.user'
const lastEmailKey = 'livelab.react.last_email'

function read(key: string): string | null {
  try {
    return window.localStorage.getItem(key)
  } catch {
    return null
  }
}

function write(key: string, value: string): void {
  try {
    window.localStorage.setItem(key, value)
  } catch {
    // Storage can be unavailable in restricted browsers.
  }
}

function remove(key: string): void {
  try {
    window.localStorage.removeItem(key)
  } catch {
    // ignore
  }
}

export function getAccessToken(): string | null {
  return read(accessKey)
}

export function getRefreshToken(): string | null {
  return read(refreshKey)
}

export function getSavedUser(): User | null {
  const raw = read(userKey)
  if (!raw) return null
  try {
    return JSON.parse(raw) as User
  } catch {
    remove(userKey)
    return null
  }
}

export function saveSession(session: Session): void {
  write(accessKey, session.accessToken)
  write(refreshKey, session.refreshToken)
  write(userKey, JSON.stringify(session.user))
}

export function saveUser(user: User): void {
  write(userKey, JSON.stringify(user))
}

export function updateAccessToken(accessToken: string, refreshToken?: string): void {
  write(accessKey, accessToken)
  if (refreshToken) write(refreshKey, refreshToken)
}

export function clearSession(): void {
  remove(accessKey)
  remove(refreshKey)
  remove(userKey)
}

export function restoreSession(): Session | null {
  const accessToken = getAccessToken()
  const refreshToken = getRefreshToken()
  const user = getSavedUser()
  if (!accessToken || !refreshToken || !user) {
    clearSession()
    return null
  }
  return { accessToken, refreshToken, user }
}

export function saveLastEmail(email: string): void {
  write(lastEmailKey, email)
}

export function getLastEmail(): string {
  return read(lastEmailKey) ?? ''
}
