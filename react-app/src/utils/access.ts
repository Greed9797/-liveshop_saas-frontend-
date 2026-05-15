import {
  BookOpen,
  Building2,
  CalendarClock,
  ChartNoAxesCombined,
  CircleDollarSign,
  Gauge,
  Home,
  LayoutDashboard,
  MonitorPlay,
  Presentation,
  Settings,
  Store,
  Users,
  Workflow,
} from 'lucide-react'
import type { Role, User } from '../types/models'

export interface MenuItem {
  label: string
  path: string
  icon: typeof Home
  roles: Role[]
}

export const masterRoles: Role[] = [
  'franqueador_master',
  'admin_master',
  'gerente_regional',
]

export const internalRoles: Role[] = [
  'franqueado',
  'gerente',
  'gerente_comercial',
  'financeiro',
  'financeiro_readonly',
  'operacional',
  'auditor',
  'suporte',
  'produtor_live',
  'marketing',
  'comercial_readonly',
]

export const commercialRoles: Role[] = [
  'franqueado',
  'gerente',
  'gerente_comercial',
  'auditor',
  'suporte',
  'marketing',
  'comercial_readonly',
]

export const financeRoles: Role[] = [
  'franqueado',
  'gerente',
  'financeiro',
  'financeiro_readonly',
  'auditor',
]

export const opsRoles: Role[] = [
  'franqueado',
  'gerente',
  'operacional',
  'auditor',
  'suporte',
  'produtor_live',
  'comercial_readonly',
]

export const cabineRoles: Role[] = [
  'franqueado',
  'gerente',
  'operacional',
  'apresentador',
  'apresentadora',
  'auditor',
  'suporte',
  'produtor_live',
  'marketing',
  'comercial_readonly',
]

export const clienteRoles: Role[] = ['cliente_parceiro']

export function routeForRole(role?: Role, onboardingCompleted = true): string {
  if (!role) return '/login'
  if (masterRoles.includes(role)) return '/master'
  if (role === 'apresentador' || role === 'apresentadora') return '/conteudo'
  if (role === 'cliente_parceiro') return onboardingCompleted ? '/cliente' : '/onboarding'
  if (internalRoles.includes(role)) return '/'
  return '/login'
}

export function hasRole(user: User | null, allowed?: Role[]): boolean {
  if (!allowed || allowed.length === 0) return Boolean(user)
  return Boolean(user && allowed.includes(user.papel))
}

export function needsClientOnboarding(user: User | null): boolean {
  return user?.papel === 'cliente_parceiro' && user.onboarding_completed === false
}

export const menuItems: MenuItem[] = [
  { label: 'Home', path: '/', icon: Home, roles: internalRoles },
  { label: 'Master', path: '/master', icon: LayoutDashboard, roles: masterRoles },
  { label: 'Unidades', path: '/master/unidades', icon: Building2, roles: masterRoles },
  { label: 'Consolidado', path: '/master/consolidado', icon: ChartNoAxesCombined, roles: masterRoles },
  { label: 'Comercial', path: '/comercial', icon: Workflow, roles: [...masterRoles, ...commercialRoles] },
  { label: 'Franqueados', path: '/master/franqueados', icon: Store, roles: ['franqueador_master'] },
  { label: 'Cliente', path: '/cliente', icon: Gauge, roles: clienteRoles },
  { label: 'Lives', path: '/cliente/lives', icon: MonitorPlay, roles: clienteRoles },
  { label: 'Agenda', path: '/cliente/agenda', icon: CalendarClock, roles: clienteRoles },
  { label: 'Financeiro', path: '/financeiro?tab=boletos', icon: CircleDollarSign, roles: clienteRoles },
  { label: 'Configurações', path: '/cliente/configuracoes', icon: Settings, roles: clienteRoles },
  { label: 'Conteúdo', path: '/conteudo', icon: Presentation, roles: cabineRoles },
  { label: 'Apresentadoras', path: '/apresentadoras', icon: Users, roles: opsRoles },
  { label: 'Financeiro', path: '/financeiro', icon: CircleDollarSign, roles: financeRoles },
  { label: 'Base', path: '/conhecimento', icon: BookOpen, roles: [...masterRoles, ...internalRoles, 'apresentador', 'apresentadora', 'cliente_parceiro'] },
  { label: 'Configurações', path: '/configuracoes', icon: Settings, roles: ['franqueador_master', 'admin_master', 'franqueado'] },
]

export function menuForUser(user: User | null): MenuItem[] {
  if (!user) return []
  return menuItems.filter((item) => item.roles.includes(user.papel))
}

export function roleLabel(role?: Role): string {
  const labels: Record<string, string> = {
    franqueador_master: 'Franqueador Master',
    admin_master: 'Admin Master',
    gerente_regional: 'Gerente Regional',
    franqueado: 'Franqueado',
    gerente: 'Gerente',
    gerente_comercial: 'Gerente Comercial',
    financeiro: 'Financeiro',
    financeiro_readonly: 'Financeiro Leitura',
    operacional: 'Operacional',
    auditor: 'Auditor',
    suporte: 'Suporte',
    produtor_live: 'Produtor Live',
    marketing: 'Marketing',
    comercial_readonly: 'Comercial Leitura',
    apresentador: 'Apresentador',
    apresentadora: 'Apresentadora',
    cliente_parceiro: 'Cliente Parceiro',
  }
  return role ? labels[role] ?? role : 'Sem papel'
}
