import { describe, expect, it } from 'vitest'
import { menuForUser, routeForRole } from './access'
import type { User } from '../types/models'

const baseUser: User = {
  id: 'user-1',
  nome: 'Teste',
  email: 'teste@livelab.com',
  papel: 'franqueado',
  tenant_id: 'tenant-1',
  tenant_nome: 'Unidade',
  onboarding_completed: true,
}

describe('routeForRole', () => {
  it('routes master users to the master dashboard', () => {
    expect(routeForRole('franqueador_master')).toBe('/master')
    expect(routeForRole('gerente_regional')).toBe('/master')
  })

  it('routes client users according to onboarding state', () => {
    expect(routeForRole('cliente_parceiro', true)).toBe('/cliente')
    expect(routeForRole('cliente_parceiro', false)).toBe('/onboarding')
  })

  it('routes live presenters directly to cabines', () => {
    expect(routeForRole('apresentadora')).toBe('/cabines')
  })
})

describe('menuForUser', () => {
  it('keeps role-specific menus separated', () => {
    const masterMenu = menuForUser({ ...baseUser, papel: 'franqueador_master' }).map((item) => item.path)
    const clientMenu = menuForUser({ ...baseUser, papel: 'cliente_parceiro' }).map((item) => item.path)

    expect(masterMenu).toContain('/master')
    expect(masterMenu).not.toContain('/cliente')
    expect(clientMenu).toContain('/cliente')
    expect(clientMenu).not.toContain('/cabines')
  })
})
