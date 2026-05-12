import type { ReactNode } from 'react'

export function PageHeader({
  eyebrow,
  title,
  accent,
  subtitle,
  actions,
}: {
  eyebrow?: string
  title: string
  accent?: string
  subtitle?: string
  actions?: ReactNode
}) {
  return (
    <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
      <div>
        {eyebrow ? <p className="mb-2 text-xs font-bold uppercase tracking-[0.16em] text-brand">{eyebrow}</p> : null}
        <h1 className="text-3xl font-bold tracking-tight text-ink sm:text-4xl">
          {accent ? <span className="font-serif font-normal italic">{accent}</span> : null}
          {accent ? ' ' : null}
          {title}
        </h1>
        {subtitle ? <p className="mt-2 max-w-3xl text-sm text-ink-muted">{subtitle}</p> : null}
      </div>
      {actions ? <div className="flex flex-wrap items-center gap-2">{actions}</div> : null}
    </div>
  )
}
