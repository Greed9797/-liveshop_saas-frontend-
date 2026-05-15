import { beforeEach, describe, expect, it, vi } from 'vitest'
import { iniciarLive } from './domain'
import { apiPost } from './api'

vi.mock('./api', () => ({
  apiDelete: vi.fn(),
  apiGet: vi.fn(),
  apiPatch: vi.fn(),
  apiPost: vi.fn(),
}))

describe('domain live operations', () => {
  beforeEach(() => {
    vi.mocked(apiPost).mockReset()
  })

  it('posts the old start-live flow to /lives', async () => {
    vi.mocked(apiPost).mockResolvedValue({ id: 'live-1' })

    await iniciarLive({
      cabine_id: 'cabine-1',
      cliente_id: 'cliente-1',
      tiktok_username: 'marca_live',
    })

    expect(apiPost).toHaveBeenCalledWith('/lives', {
      cabine_id: 'cabine-1',
      cliente_id: 'cliente-1',
      tiktok_username: 'marca_live',
    })
  })
})
