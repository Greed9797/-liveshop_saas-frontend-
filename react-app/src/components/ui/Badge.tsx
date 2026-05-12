import clsx from 'clsx'

const toneClass = {
  brand: 'bg-brand-soft text-brand',
  success: 'bg-emerald-50 text-emerald-700',
  warning: 'bg-amber-50 text-amber-700',
  danger: 'bg-red-50 text-red-700',
  info: 'bg-blue-50 text-blue-700',
  neutral: 'bg-stone-100 text-stone-700',
}

export function Badge({
  children,
  tone = 'neutral',
  className,
}: {
  children: React.ReactNode
  tone?: keyof typeof toneClass
  className?: string
}) {
  return (
    <span className={clsx('inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold', toneClass[tone], className)}>
      {children}
    </span>
  )
}

export function statusTone(status?: string): keyof typeof toneClass {
  const normalized = status?.toLowerCase() ?? ''
  if (['ativo', 'aprovada', 'pago', 'ao_vivo', 'em_andamento', 'livre'].includes(normalized)) return 'success'
  if (['pendente', 'reservada', 'em_analise', 'aguardando'].includes(normalized)) return 'warning'
  if (['cancelado', 'recusada', 'vencido', 'inadimplente', 'manutencao'].includes(normalized)) return 'danger'
  if (['encerrada', 'finalizada'].includes(normalized)) return 'info'
  return 'neutral'
}
