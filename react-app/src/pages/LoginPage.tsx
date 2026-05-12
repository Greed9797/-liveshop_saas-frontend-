import { Eye, EyeOff, LogIn } from 'lucide-react'
import { FormEvent, useMemo, useState } from 'react'
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom'
import { Button } from '../components/ui/Button'
import { getLastEmail } from '../services/auth-storage'
import { useAuthStore } from '../stores/auth-store'
import { routeForRole } from '../utils/access'

export function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = useAuthStore((state) => state.user)
  const login = useAuthStore((state) => state.login)
  const error = useAuthStore((state) => state.error)
  const isLoading = useAuthStore((state) => state.isLoading)
  const lastEmail = useMemo(() => getLastEmail(), [])
  const [email, setEmail] = useState(lastEmail)
  const [senha, setSenha] = useState('')
  const [showSenha, setShowSenha] = useState(false)
  const [localError, setLocalError] = useState<string | null>(null)

  if (user) return <Navigate to={routeForRole(user.papel, user.onboarding_completed ?? true)} replace />

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const normalizedEmail = email.trim()
    if (!normalizedEmail.includes('@') || !normalizedEmail.includes('.')) {
      setLocalError('E-mail inválido.')
      return
    }
    if (!senha) {
      setLocalError('Informe a senha.')
      return
    }
    setLocalError(null)
    const route = await login(normalizedEmail, senha)
    if (route) {
      const state = location.state as { from?: { pathname?: string } } | null
      navigate(state?.from?.pathname ?? route, { replace: true })
    }
  }

  return (
    <div className="min-h-screen bg-[#fdf6f1] px-4 py-8">
      <div className="fixed inset-x-0 top-0 h-80 bg-[radial-gradient(120%_80%_at_50%_-10%,#ffe8dc_0%,#fdf6f1_55%)]" />
      <main className="relative mx-auto flex min-h-[calc(100vh-4rem)] max-w-xl items-center justify-center">
        <section className="w-full overflow-hidden rounded-2xl border border-black/10 bg-white shadow-2xl shadow-black/10">
          <div className="relative px-6 py-8 sm:px-10 sm:py-10">
            <div className="absolute inset-x-0 -top-28 mx-auto h-72 w-72 rounded-full bg-brand-soft blur-3xl" />
            <div className="relative">
              <div className="mb-8 flex items-center gap-3">
                <img src="/images/favicon.png" alt="" className="h-11 w-11 rounded-lg object-cover" />
                <div>
                  <p className="text-xs font-bold uppercase tracking-[0.18em] text-brand">Livelab</p>
                  <h1 className="text-2xl font-bold tracking-tight text-ink sm:text-3xl">
                    Bem-vindo <span className="font-serif font-normal italic">de volta</span>
                  </h1>
                </div>
              </div>

              <form className="space-y-5" onSubmit={onSubmit}>
                <label className="block">
                  <span className="text-sm font-semibold text-ink">E-mail</span>
                  <input
                    className="mt-2 h-12 w-full rounded-lg border border-line bg-[#f7efe8] px-4 text-ink outline-none transition focus:border-brand focus:bg-white focus:ring-4 focus:ring-brand/10"
                    type="email"
                    autoComplete="email"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    placeholder="voce@empresa.com"
                  />
                </label>

                <label className="block">
                  <span className="text-sm font-semibold text-ink">Senha</span>
                  <div className="mt-2 flex h-12 items-center rounded-lg border border-line bg-[#f7efe8] pr-2 transition focus-within:border-brand focus-within:bg-white focus-within:ring-4 focus-within:ring-brand/10">
                    <input
                      className="h-full min-w-0 flex-1 bg-transparent px-4 text-ink outline-none"
                      type={showSenha ? 'text' : 'password'}
                      autoComplete="current-password"
                      value={senha}
                      onChange={(event) => setSenha(event.target.value)}
                      placeholder="Sua senha"
                    />
                    <button
                      type="button"
                      className="rounded-md p-2 text-ink-muted hover:bg-white"
                      aria-label={showSenha ? 'Ocultar senha' : 'Mostrar senha'}
                      onClick={() => setShowSenha((value) => !value)}
                    >
                      {showSenha ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </button>
                  </div>
                </label>

                {localError || error ? (
                  <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                    {localError ?? error}
                  </div>
                ) : null}

                <Button className="h-12 w-full" type="submit" icon={LogIn} isLoading={isLoading}>
                  Entrar
                </Button>
              </form>

              <div className="mt-6 flex items-center justify-between text-sm">
                <Link className="font-semibold text-brand hover:text-brand-hover" to="/esqueci-senha">
                  Esqueci minha senha
                </Link>
                <span className="text-ink-muted">React/Vercel</span>
              </div>
            </div>
          </div>
        </section>
      </main>
    </div>
  )
}
