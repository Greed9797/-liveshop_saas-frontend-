export type Role =
  | 'franqueador_master'
  | 'admin_master'
  | 'gerente_regional'
  | 'franqueado'
  | 'gerente'
  | 'gerente_comercial'
  | 'financeiro'
  | 'financeiro_readonly'
  | 'operacional'
  | 'auditor'
  | 'suporte'
  | 'produtor_live'
  | 'marketing'
  | 'comercial_readonly'
  | 'apresentador'
  | 'apresentadora'
  | 'cliente_parceiro'
  | string

export type JsonRecord = Record<string, unknown>

export interface User {
  id: string
  nome: string
  email: string
  papel: Role
  tenant_id: string
  tenant_nome: string
  onboarding_completed?: boolean
}

export interface AuthResponse {
  access_token: string
  refresh_token: string
  user: User
}

export interface Session {
  accessToken: string
  refreshToken: string
  user: User
}

export interface Metric {
  label: string
  value: string
  hint?: string
  tone?: 'brand' | 'success' | 'warning' | 'danger' | 'info' | 'neutral'
}

export interface ChartPoint {
  label: string
  value: number
  secondary?: number
}

export interface TableColumn<T> {
  key: keyof T | string
  header: string
  render?: (item: T) => React.ReactNode
  align?: 'left' | 'right' | 'center'
}

export interface Period {
  mes: number
  ano: number
}

export interface Lead {
  id: string
  nome?: string
  nome_cliente?: string
  cliente_nome?: string
  origem?: string
  nicho?: string
  etapa?: string
  status?: string
  valor_estimado?: number | string
  criado_em?: string
}

export interface Cabine {
  id: string
  numero?: number
  status?: string
  cliente_nome?: string
  apresentador_nome?: string
  live_atual_id?: string
  viewer_count?: number
  gmv_atual?: number | string
  total_orders?: number
}

export interface Solicitacao {
  id: string
  status?: string
  cliente_nome?: string
  cabine_numero?: number
  data_solicitada?: string
  hora_inicio?: string
  solicitante_nome?: string
  tipo_live?: string
}

export interface ApiListResponse<T> {
  data?: T[]
  items?: T[]
  rows?: T[]
  results?: T[]
}
