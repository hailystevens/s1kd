import type { ModuleDetail, ModuleSummary } from './types'

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8000'

async function request<T>(path: string): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`)
  if (!response.ok) {
    throw new Error(`Request failed (${response.status}) for ${path}`)
  }
  return (await response.json()) as T
}

export function fetchModules() {
  return request<ModuleSummary[]>('/api/modules')
}

export function fetchModule(moduleId: string) {
  return request<ModuleDetail>(`/api/modules/${encodeURIComponent(moduleId)}`)
}
