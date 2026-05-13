import { AtSign, KeyRound, Save, Target } from 'lucide-react'
import { FormEvent, useEffect, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { Button } from '../components/ui/Button'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getClienteMeta, getClientePerfil, getConfiguracoes, trocarSenha, updateClienteMeta, updateClienteTiktok, updateConfiguracoes } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asNumber, asString, currentPeriod, formatMoney, periodLabel } from '../utils/format'
import type { JsonRecord } from '../types/models'

export function ConfiguracoesPage({ clienteMode = false }: { clienteMode?: boolean }) {
  const client = useQueryClient()
  const query = useQuery({ queryKey: ['configuracoes', clienteMode], queryFn: getConfiguracoes, enabled: !clienteMode })
  const period = currentPeriod()
  const perfilQuery = useQuery({ queryKey: ['cliente-perfil'], queryFn: getClientePerfil, enabled: clienteMode })
  const metaQuery = useQuery({ queryKey: ['cliente-meta', period.ano, period.mes], queryFn: () => getClienteMeta(period), enabled: clienteMode })
  const [form, setForm] = useState<JsonRecord>({})
  const [tiktok, setTiktok] = useState('')
  const [metaGmv, setMetaGmv] = useState('')
  const [senha, setSenha] = useState({ senha_atual: '', nova_senha: '' })
  const mutation = useMutation({
    mutationFn: updateConfiguracoes,
    onSuccess: () => client.invalidateQueries({ queryKey: ['configuracoes'] }),
  })
  const tiktokMutation = useMutation({
    mutationFn: updateClienteTiktok,
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: ['cliente-perfil'] })
    },
  })
  const metaMutation = useMutation({
    mutationFn: updateClienteMeta,
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: ['cliente-meta'] })
    },
  })
  const senhaMutation = useMutation({
    mutationFn: trocarSenha,
    onSuccess: () => setSenha({ senha_atual: '', nova_senha: '' }),
  })

  useEffect(() => {
    if (query.data) setForm(query.data)
  }, [query.data])

  useEffect(() => {
    if (perfilQuery.data) setTiktok(asString(perfilQuery.data.tiktok_username, ''))
  }, [perfilQuery.data])

  useEffect(() => {
    if (metaQuery.data) setMetaGmv(String(asNumber(metaQuery.data.meta_gmv)))
  }, [metaQuery.data])

  if (clienteMode) {
    if (perfilQuery.isLoading || metaQuery.isLoading) return <LoadingState />
    if (perfilQuery.isError) return <ErrorState message={extractErrorMessage(perfilQuery.error)} onRetry={() => void perfilQuery.refetch()} />
    if (metaQuery.isError) return <ErrorState message={extractErrorMessage(metaQuery.error)} onRetry={() => void metaQuery.refetch()} />

    const perfil = perfilQuery.data ?? {}

    function onTiktokSubmit(event: FormEvent<HTMLFormElement>) {
      event.preventDefault()
      tiktokMutation.mutate(tiktok ? tiktok.replace(/^@/, '') : null)
    }

    function onMetaSubmit(event: FormEvent<HTMLFormElement>) {
      event.preventDefault()
      metaMutation.mutate({ ano: period.ano, mes: period.mes, meta_gmv: asNumber(metaGmv) })
    }

    function onSenhaSubmit(event: FormEvent<HTMLFormElement>) {
      event.preventDefault()
      senhaMutation.mutate(senha)
    }

    return (
      <div className="space-y-6">
        <PageHeader eyebrow="Cliente" accent="Configurações" title="da conta" subtitle="Dados do perfil e preferências do cliente parceiro." />

        <section className="grid gap-4 lg:grid-cols-[1fr_0.85fr]">
          <Card>
            <CardHeader>
              <p className="text-base font-bold text-ink">Perfil vinculado</p>
              <p className="mt-1 text-xs text-ink-muted">Esses dados vêm de `/cliente/perfil`; edição cadastral completa segue pelo admin da unidade.</p>
            </CardHeader>
            <CardBody className="grid gap-4 md:grid-cols-2">
              {([
                ['Nome', perfil.nome],
                ['Email', perfil.email],
                ['Celular', perfil.celular],
                ['CNPJ', perfil.cnpj],
                ['Razão social', perfil.razao_social],
                ['Site', perfil.site],
                ['Cidade', `${asString(perfil.cidade, '')} ${asString(perfil.estado, '')}`.trim()],
                ['Nicho', perfil.nicho],
              ] as Array<[string, unknown]>).map(([label, value]) => (
                <div key={String(label)} className="rounded-2xl border border-line bg-surface-muted p-4">
                  <p className="text-xs font-semibold uppercase tracking-[0.1em] text-ink-muted">{label}</p>
                  <p className="mt-2 truncate text-sm font-bold text-ink">{asString(value)}</p>
                </div>
              ))}
            </CardBody>
          </Card>

          <div className="space-y-4">
            <Card>
              <CardHeader>
                <p className="text-base font-bold text-ink">Meta do mês</p>
                <p className="mt-1 text-xs text-ink-muted">{periodLabel(period)}</p>
              </CardHeader>
              <CardBody>
                <form className="space-y-4" onSubmit={onMetaSubmit}>
                  <div className="rounded-2xl bg-brand-soft p-4">
                    <p className="text-xs font-semibold uppercase tracking-[0.1em] text-brand">Meta atual</p>
                    <p className="num mt-2 text-2xl font-bold text-ink">{formatMoney(metaQuery.data?.meta_gmv)}</p>
                  </div>
                  <label className="block">
                    <span className="text-sm font-semibold text-ink">Nova meta GMV</span>
                    <input className="design-input mt-2 h-11 w-full px-4" type="number" min="0" step="0.01" value={metaGmv} onChange={(event) => setMetaGmv(event.target.value)} />
                  </label>
                  {metaMutation.isError ? <p className="rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">{extractErrorMessage(metaMutation.error)}</p> : null}
                  {metaMutation.isSuccess ? <p className="rounded-2xl bg-[var(--success-soft)] px-4 py-3 text-sm font-medium text-[var(--success)]">Meta atualizada.</p> : null}
                  <Button type="submit" icon={Target} isLoading={metaMutation.isPending}>
                    Salvar meta
                  </Button>
                </form>
              </CardBody>
            </Card>

            <Card>
              <CardHeader>
                <p className="text-base font-bold text-ink">TikTok</p>
              </CardHeader>
              <CardBody>
                <form className="space-y-4" onSubmit={onTiktokSubmit}>
                  <label className="block">
                    <span className="text-sm font-semibold text-ink">@username</span>
                    <input className="design-input mt-2 h-11 w-full px-4" value={tiktok} onChange={(event) => setTiktok(event.target.value)} placeholder="@sua_marca" />
                  </label>
                  {tiktokMutation.isError ? <p className="rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">{extractErrorMessage(tiktokMutation.error)}</p> : null}
                  {tiktokMutation.isSuccess ? <p className="rounded-2xl bg-[var(--success-soft)] px-4 py-3 text-sm font-medium text-[var(--success)]">TikTok atualizado.</p> : null}
                  <Button type="submit" icon={AtSign} isLoading={tiktokMutation.isPending}>
                    Salvar TikTok
                  </Button>
                </form>
              </CardBody>
            </Card>

            <Card>
              <CardHeader>
                <p className="text-base font-bold text-ink">Senha</p>
              </CardHeader>
              <CardBody>
                <form className="space-y-4" onSubmit={onSenhaSubmit}>
                  <input className="design-input h-11 w-full px-4" type="password" autoComplete="current-password" placeholder="Senha atual" value={senha.senha_atual} onChange={(event) => setSenha((current) => ({ ...current, senha_atual: event.target.value }))} required />
                  <input className="design-input h-11 w-full px-4" type="password" autoComplete="new-password" placeholder="Nova senha" value={senha.nova_senha} onChange={(event) => setSenha((current) => ({ ...current, nova_senha: event.target.value }))} required />
                  {senhaMutation.isError ? <p className="rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">{extractErrorMessage(senhaMutation.error)}</p> : null}
                  {senhaMutation.isSuccess ? <p className="rounded-2xl bg-[var(--success-soft)] px-4 py-3 text-sm font-medium text-[var(--success)]">Senha alterada.</p> : null}
                  <Button type="submit" icon={KeyRound} isLoading={senhaMutation.isPending}>
                    Trocar senha
                  </Button>
                </form>
              </CardBody>
            </Card>
          </div>
        </section>
      </div>
    )
  }

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  function setField(key: string, value: string) {
    setForm((current) => ({ ...current, [key]: value }))
  }

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    mutation.mutate(form)
  }

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Administração" accent="Configurações" title="da unidade" subtitle="Campos principais da franquia e integrações expostos pelo backend." />

      <Card>
        <CardHeader>
          <p className="text-sm font-bold text-ink">Dados da unidade</p>
        </CardHeader>
        <CardBody>
          <form className="grid gap-4 md:grid-cols-2" onSubmit={onSubmit}>
            {['nome_franquia', 'cnpj', 'email', 'telefone', 'cidade', 'estado'].map((key) => (
              <label key={key} className="block">
                <span className="text-sm font-semibold capitalize text-ink">{key.replace(/_/g, ' ')}</span>
                <input
                  className="design-input mt-2 h-11 w-full px-4"
                  value={asString(form[key], '')}
                  onChange={(event) => setField(key, event.target.value)}
                />
              </label>
            ))}
            {mutation.isError ? <p className="md:col-span-2 rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">{extractErrorMessage(mutation.error)}</p> : null}
            {mutation.isSuccess ? <p className="md:col-span-2 rounded-2xl bg-[var(--success-soft)] px-4 py-3 text-sm font-medium text-[var(--success)]">Configurações salvas.</p> : null}
            <div className="md:col-span-2">
              <Button type="submit" icon={Save} isLoading={mutation.isPending}>
                Salvar
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>
    </div>
  )
}
