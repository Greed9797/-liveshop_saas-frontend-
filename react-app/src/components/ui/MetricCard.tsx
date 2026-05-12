import type { LucideIcon } from 'lucide-react'
import clsx from 'clsx'
import { Card, CardBody } from './Card'
import type { Metric } from '../../types/models'

const toneClass: Record<NonNullable<Metric['tone']>, string> = {
  brand: 'bg-brand-soft text-brand',
  success: 'bg-emerald-50 text-emerald-700',
  warning: 'bg-amber-50 text-amber-700',
  danger: 'bg-red-50 text-red-700',
  info: 'bg-blue-50 text-blue-700',
  neutral: 'bg-stone-100 text-stone-700',
}

export function MetricCard({ metric, icon: Icon }: { metric: Metric; icon?: LucideIcon }) {
  const tone = metric.tone ?? 'neutral'
  return (
    <Card>
      <CardBody className="flex min-h-32 flex-col justify-between">
        <div className="flex items-start justify-between gap-4">
          <p className="text-sm font-medium text-ink-muted">{metric.label}</p>
          {Icon ? (
            <span className={clsx('rounded-md p-2', toneClass[tone])}>
              <Icon className="h-4 w-4" />
            </span>
          ) : null}
        </div>
        <div>
          <p className="mt-4 text-2xl font-bold tracking-tight text-ink">{metric.value}</p>
          {metric.hint ? <p className="mt-1 text-xs text-ink-muted">{metric.hint}</p> : null}
        </div>
      </CardBody>
    </Card>
  )
}
