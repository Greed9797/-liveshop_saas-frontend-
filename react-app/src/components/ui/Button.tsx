import { Loader2, type LucideIcon } from 'lucide-react'
import clsx from 'clsx'
import type { ButtonHTMLAttributes, ReactNode } from 'react'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger'
  icon?: LucideIcon
  isLoading?: boolean
  children: ReactNode
}

export function Button({
  variant = 'primary',
  icon: Icon,
  isLoading,
  className,
  children,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      className={clsx(
        'inline-flex h-10 items-center justify-center gap-2 rounded-md px-4 text-sm font-semibold transition focus:outline-none focus:ring-2 focus:ring-brand/30',
        variant === 'primary' && 'bg-brand text-white shadow-sm hover:bg-brand-hover',
        variant === 'secondary' && 'border border-line bg-surface text-ink hover:bg-surface-muted',
        variant === 'ghost' && 'text-ink-muted hover:bg-surface-muted hover:text-ink',
        variant === 'danger' && 'bg-red-600 text-white hover:bg-red-700',
        (disabled || isLoading) && 'opacity-60',
        className,
      )}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : Icon ? <Icon className="h-4 w-4" /> : null}
      {children}
    </button>
  )
}
