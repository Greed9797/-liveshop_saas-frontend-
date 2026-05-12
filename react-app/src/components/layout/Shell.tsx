import { LogOut, Menu, Search, X } from 'lucide-react'
import { useState } from 'react'
import { NavLink, Outlet, useLocation } from 'react-router-dom'
import clsx from 'clsx'
import { useAuthStore } from '../../stores/auth-store'
import { menuForUser, roleLabel } from '../../utils/access'
import { Button } from '../ui/Button'

function Sidebar({ onNavigate }: { onNavigate?: () => void }) {
  const user = useAuthStore((state) => state.user)
  const location = useLocation()
  const items = menuForUser(user)

  return (
    <aside className="flex h-full w-64 flex-col border-r border-line bg-white">
      <div className="flex h-20 items-center gap-3 border-b border-line px-5">
        <img src="/images/favicon.png" alt="" className="h-9 w-9 rounded-md object-cover" />
        <div>
          <p className="text-base font-bold text-ink">Livelab</p>
          <p className="text-xs text-ink-muted">{user?.tenant_nome ?? 'LiveShop SaaS'}</p>
        </div>
      </div>

      <nav className="flex-1 overflow-y-auto px-3 py-4 scrollbar-thin">
        {items.map((item) => {
          const Icon = item.icon
          const selected = item.path === '/' ? location.pathname === '/' : location.pathname.startsWith(item.path)
          return (
            <NavLink
              key={item.path}
              to={item.path}
              onClick={onNavigate}
              className={clsx(
                'mb-1 flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-semibold transition',
                selected ? 'bg-brand-soft text-brand' : 'text-ink-muted hover:bg-surface-muted hover:text-ink',
              )}
            >
              <Icon className="h-4 w-4" />
              <span>{item.label}</span>
            </NavLink>
          )
        })}
      </nav>

      <div className="border-t border-line p-4">
        <div className="rounded-lg bg-surface-muted p-3">
          <p className="truncate text-sm font-bold text-ink">{user?.nome}</p>
          <p className="mt-1 truncate text-xs text-ink-muted">{roleLabel(user?.papel)}</p>
        </div>
      </div>
    </aside>
  )
}

export function Shell() {
  const [open, setOpen] = useState(false)
  const logout = useAuthStore((state) => state.logout)

  return (
    <div className="min-h-screen bg-canvas">
      <div className="hidden lg:fixed lg:inset-y-0 lg:left-0 lg:block">
        <Sidebar />
      </div>

      {open ? (
        <div className="fixed inset-0 z-50 lg:hidden">
          <button className="absolute inset-0 bg-black/30" aria-label="Fechar menu" onClick={() => setOpen(false)} />
          <div className="relative h-full">
            <Sidebar onNavigate={() => setOpen(false)} />
          </div>
        </div>
      ) : null}

      <div className="lg:pl-64">
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-line bg-canvas/90 px-4 backdrop-blur md:px-8">
          <div className="flex items-center gap-3">
            <button
              className="rounded-md border border-line bg-white p-2 text-ink-muted lg:hidden"
              aria-label="Abrir menu"
              onClick={() => setOpen(true)}
            >
              {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
            <div className="hidden items-center gap-2 rounded-md border border-line bg-white px-3 py-2 text-sm text-ink-muted md:flex">
              <Search className="h-4 w-4" />
              <span>Buscar no SaaS</span>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="secondary" icon={LogOut} onClick={() => void logout()}>
              Sair
            </Button>
          </div>
        </header>

        <main className="px-4 py-6 md:px-8 lg:px-10">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
