import { ArrowLeft, Mail } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { Link } from 'react-router-dom'
import { Button } from '../components/ui/Button'
import { requestPasswordReset } from '../services/auth'
import { extractErrorMessage } from '../services/api'

export function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [message, setMessage] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setLoading(true)
    setError(null)
    try {
      await requestPasswordReset(email.trim())
      setMessage('Se este email estiver cadastrado, você receberá o link em breve.')
    } catch (err) {
      setError(extractErrorMessage(err))
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="flex min-h-screen items-center justify-center bg-[#fdf6f1] px-4">
      <section className="w-full max-w-md rounded-2xl border border-line bg-white p-8 shadow-xl shadow-black/10">
        <Link to="/login" className="mb-6 inline-flex items-center gap-2 text-sm font-semibold text-ink-muted hover:text-ink">
          <ArrowLeft className="h-4 w-4" />
          Voltar
        </Link>
        <h1 className="text-2xl font-bold text-ink">Recuperar senha</h1>
        <form className="mt-6 space-y-4" onSubmit={onSubmit}>
          <label className="block">
            <span className="text-sm font-semibold text-ink">E-mail</span>
            <input
              className="mt-2 h-11 w-full rounded-lg border border-line bg-surface-muted px-4 outline-none focus:border-brand focus:ring-4 focus:ring-brand/10"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
            />
          </label>
          {message ? <p className="rounded-lg bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">{message}</p> : null}
          {error ? <p className="rounded-lg bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{error}</p> : null}
          <Button className="w-full" type="submit" icon={Mail} isLoading={loading}>
            Enviar link
          </Button>
        </form>
      </section>
    </main>
  )
}
